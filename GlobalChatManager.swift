//
//  GlobalChatManager.swift
//  TeneasyChatSDKUI_iOS
//
//  Created by Claude on 2024/12/27.
//

import Foundation
import TeneasyChatSDK_iOS

// MARK: - 数据结构

/// 未读消息项
public struct UnReadItem {
    var consultId: Int64
    var unReadCount: Int
    
    init(consultId: Int64, unReadCount: Int = 0) {
        self.consultId = consultId
        self.unReadCount = unReadCount
    }
}

// MARK: - 协议定义

/// 全局消息代理协议
public protocol GlobalMessageDelegate: AnyObject {
    func onUnReadCountChanged()
}

// MARK: - 全局ChatLib管理器

/// 全局ChatLib管理器，负责整个应用的聊天连接管理
public class GlobalChatManager: teneasySDKDelegate {
    static public let shared = GlobalChatManager()
    
    private init() {}
    
    private var isInitialized = false
    private var connectionTimer: Timer?
    
    /// 初始化全局聊天管理器
    public func initializeGlobalChat() {
        guard !isInitialized else { return }
        
        chatLib.delegate = self
        isInitialized = true
        print("GlobalChatManager: 全局ChatLib已初始化")
        
        startConnectionMonitoring()
    }
    
    /// 根据需要建立连接
    public func connectIfNeeded() {
        guard isInitialized else { return }
        
        if chatLib.payloadId == 0 {
            print("GlobalChatManager: 初始化SDK连接")
            let wssUrl = "wss://" + domain + "/v1/gateway/h5?"
            chatLib.myinit(
                userId: userId,
                cert: cert,
                token: xToken.isEmpty ? cert : xToken,
                baseUrl: wssUrl,
                sign: "9zgd9YUc",
                custom: getCustomParam(),
                maxSessionMinutes: maxSessionMinus
            )
            chatLib.callWebsocket()
        } else {
            print("GlobalChatManager: 重新连接")
            chatLib.reConnect()
        }
    }
    
    /// 开始连接监控
    private func startConnectionMonitoring() {
        connectionTimer?.invalidate()
        connectionTimer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true) { [weak self] _ in
            self?.checkAndReconnect()
        }
    }
    
    /// 检查并重连
    private func checkAndReconnect() {
        if !domain.isEmpty && chatLib.payloadId == 0 {
            print("GlobalChatManager: 检测到连接断开，尝试重连")
            connectIfNeeded()
        }
    }
    
    /// 停止全局聊天管理器
    func stopGlobalChat() {
        connectionTimer?.invalidate()
        connectionTimer = nil
        isInitialized = false
        print("GlobalChatManager: 全局ChatLib已停止")
    }
    
    // MARK: - teneasySDKDelegate
    
    public func receivedMsg(msg: TeneasyChatSDK_iOS.CommonMessage) {
        print("GlobalChatManager收到消息: consultId=\(msg.consultID), current=\(currentChatConsultId)")
        
        if msg.consultID != currentChatConsultId {
            GlobalMessageManager.shared.addUnReadMessage(consultId: msg.consultID)
        }
        
        NotificationCenter.default.post(
            name: NSNotification.Name("GlobalChatMessageReceived"),
            object: nil,
            userInfo: ["message": msg]
        )
    }
    
    public func msgDeleted(msg: TeneasyChatSDK_iOS.CommonMessage, payloadId: UInt64, errMsg: String?) {
        NotificationCenter.default.post(
            name: NSNotification.Name("GlobalChatMessageDeleted"),
            object: nil,
            userInfo: ["message": msg, "payloadId": payloadId]
        )
    }
    
    public func msgReceipt(msg: TeneasyChatSDK_iOS.CommonMessage, payloadId: UInt64, errMsg: String?) {
        NotificationCenter.default.post(
            name: NSNotification.Name("GlobalChatMessageReceipt"),
            object: nil,
            userInfo: ["message": msg, "payloadId": payloadId]
        )
    }
    
    public func workChanged(msg: Gateway_SCWorkerChanged) {
        NotificationCenter.default.post(
            name: NSNotification.Name("GlobalChatWorkerChanged"),
            object: nil,
            userInfo: ["workerChanged": msg]
        )
    }
    
    public func systemMsg(result: TeneasyChatSDK_iOS.Result) {
        print("GlobalChatManager系统消息: \(result.Message) Code: \(result.Code)")
        NotificationCenter.default.post(
            name: NSNotification.Name("GlobalChatSystemMessage"),
            object: nil,
            userInfo: ["result": result]
        )
    }
    
    public func connected(c: Gateway_SCHi) {
        print("GlobalChatManager连接成功")
        xToken = c.token
        UserDefaults.standard.set(c.token, forKey: PARAM_XTOKEN)
        
        NotificationCenter.default.post(
            name: NSNotification.Name("GlobalChatConnected"),
            object: nil,
            userInfo: ["connection": c]
        )
    }
}

// MARK: - 全局消息管理器

/// 全局消息管理器，负责未读消息的统计和管理
public class GlobalMessageManager {
    static public let shared = GlobalMessageManager()
    
    private init() {}
    
    /// 添加未读消息
    func addUnReadMessage(consultId: Int64) {
        if consultId == currentChatConsultId {
            return
        }
        
        if let index = unReadList.firstIndex(where: { $0.consultId == consultId }) {
            unReadList[index].unReadCount += 1
        } else {
            unReadList.append(UnReadItem(consultId: consultId, unReadCount: 1))
        }
        
        globalMessageDelegate?.onUnReadCountChanged()
    }
    
    /// 清除指定会话的未读数
    func clearUnReadCount(consultId: Int64) {
        if let index = unReadList.firstIndex(where: { $0.consultId == consultId }) {
            unReadList[index].unReadCount = 0
        }
        globalMessageDelegate?.onUnReadCountChanged()
    }
    
    /// 获取总未读数
    public func getTotalUnReadCount() -> Int {
        return unReadList.reduce(0) { $0 + $1.unReadCount }
    }
    
    /// 获取指定会话的未读数
    func getUnReadCount(consultId: Int64) -> Int {
        return unReadList.first(where: { $0.consultId == consultId })?.unReadCount ?? 0
    }
}