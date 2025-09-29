//
//  KeFuViewController_ChatSDK.swift
//  TeneasyChatSDKUI_iOS
//
//  Created by Xuefeng
//

import Foundation
import TeneasyChatSDK_iOS
import Toast_Swift

// MARK: - SDK代理实现
extension KeFuViewController: teneasySDKDelegate {
    
    /// 初始化聊天SDK
    /// - Parameter baseUrl: 服务器基础URL
    func initSDK(baseUrl: String) {
        // 使用全局ChatLib，确保连接
        GlobalChatManager.shared.connectIfNeeded()
        
        // 注册通知监听
        setupNotificationObservers()
    }
    
    /// 设置通知监听
    private func setupNotificationObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleGlobalMessage(_:)),
            name: NSNotification.Name("GlobalChatMessageReceived"),
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleGlobalMessageDeleted(_:)),
            name: NSNotification.Name("GlobalChatMessageDeleted"),
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleGlobalMessageReceipt(_:)),
            name: NSNotification.Name("GlobalChatMessageReceipt"),
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleGlobalWorkerChanged(_:)),
            name: NSNotification.Name("GlobalChatWorkerChanged"),
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleGlobalSystemMessage(_:)),
            name: NSNotification.Name("GlobalChatSystemMessage"),
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleGlobalConnected(_:)),
            name: NSNotification.Name("GlobalChatConnected"),
            object: nil
        )
    }
    
    /// 移除通知监听
    private func removeNotificationObservers() {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - 通知处理方法
    @objc private func handleGlobalMessage(_ notification: Notification) {
        guard let msg = notification.userInfo?["message"] as? CommonMessage else { return }
        receivedMsg(msg: msg)
    }
    
    @objc private func handleGlobalMessageDeleted(_ notification: Notification) {
        guard let msg = notification.userInfo?["message"] as? CommonMessage,
              let payloadId = notification.userInfo?["payloadId"] as? UInt64 else { return }
        msgDeleted(msg: msg, payloadId: payloadId, errMsg: nil)
    }
    
    @objc private func handleGlobalMessageReceipt(_ notification: Notification) {
        guard let msg = notification.userInfo?["message"] as? CommonMessage,
              let payloadId = notification.userInfo?["payloadId"] as? UInt64 else { return }
        msgReceipt(msg: msg, payloadId: payloadId, errMsg: nil)
    }
    
    @objc private func handleGlobalWorkerChanged(_ notification: Notification) {
        guard let workerChanged = notification.userInfo?["workerChanged"] as? Gateway_SCWorkerChanged else { return }
        workChanged(msg: workerChanged)
    }
    
    @objc private func handleGlobalSystemMessage(_ notification: Notification) {
        guard let result = notification.userInfo?["result"] as? Result else { return }
        systemMsg(result: result)
    }
    
    @objc private func handleGlobalConnected(_ notification: Notification) {
        guard let connection = notification.userInfo?["connection"] as? Gateway_SCHi else { return }
        connected(c: connection)
    }
    
    // MARK: - 消息接收处理
    
    /// 处理收到的客服消息
    /// - Parameter msg: 消息对象
    public func receivedMsg(msg: TeneasyChatSDK_iOS.CommonMessage) {
        print("KeFuViewController收到消息: \(msg)")
        
        // 判断消息是否来自当前会话
        if msg.consultID != consultId {
            handleOtherConsultMessage()
            return
        }
        
        if (msg.msgSourceType == CommonMsgSourceType.mstAi){
            
        }
        
        if (msg.msgSourceType == CommonMsgSourceType.mstSystemAutoTransfer){
            print("这种消息是自动分配客服的消息，不会计入未读消息")
        }
        
        // 根据消息类型分别处理
        switch msg.msgOp {
        case .msgOpEdit:
            handleEditMessage(msg)
        case _ where msg.replyMsgID > 0:
            handleReplyMessage(msg)
        default:
            handleNormalMessage(msg)
        }
    }
    
    /// 处理消息编辑
    private func handleEditMessage(_ msg: CommonMessage) {
        // 查找需要更新的消息
        guard let index = datasouceArray.firstIndex(where: { $0.message?.msgID == msg.msgID }) else {
            print("未找到匹配的消息ID")
            return
        }
        
        // 更新消息内容
        datasouceArray[index].message = msg
        print("消息内容已更新")
        
        // 更新UI时保持滚动位置
        updateMessageUI(at: index)
    }
    
    /// 处理回复消息
    private func handleReplyMessage(_ msg: CommonMessage) {
        // 处理消息文本
        let newText = msg.content.data.trimmingCharacters(in: .whitespacesAndNewlines)
        let newMsg = composeALocalTxtMessage(textMsg: newText, msgId: msg.msgID)
        
        // 查找原始消息并处理
        if let model = datasouceArray.first(where: { $0.message?.msgID == msg.replyMsgID }) {
            appendDataSource(
                msg: newMsg,
                isLeft: true,
                cellType: .TYPE_Text,
                replayQuote: getReplyItem(oriMsg: model.message)
            )
        } else {
            // 本地未找到原始消息，从服务器查询
            queryReplyMessage(msg, newMsg)
        }
    }
    
    /// 从服务器查询回复消息
    private func queryReplyMessage(_ msg: CommonMessage, _ newMsg: CommonMessage) {
        NetworkUtil.queryMessage(msgIds: [String(msg.replyMsgID)]) { [weak self] success, data in
            guard let self = self,
                  let replyList = data?.replyList,
                  !replyList.isEmpty else { return }
            
            self.appendDataSource(
                msg: newMsg,
                isLeft: true,
                cellType: .TYPE_Text,
                replayQuote: self.getReplyItem(oriMsg: replyList[0])
            )
        }
    }
    
    /// 处理普通消息
    private func handleNormalMessage(_ msg: CommonMessage) {
        // 根据消息内容类型确定展示样式
        let cellType = determineCellType(for: msg)
        
        var left = true;
        if (msg.msgSourceType == CommonMsgSourceType.mstSystemWorker){
            left = false;
        }
        appendDataSource(msg: msg, isLeft: left, cellType: cellType)
    }
    
    /// 确定消息单元格类型
    private func determineCellType(for msg: CommonMessage) -> CellType {
        switch true {
        case !msg.file.uri.isEmpty:
            return .TYPE_File
        case !msg.video.uri.isEmpty:
            return .TYPE_VIDEO
        case !msg.image.uri.isEmpty:
            return .TYPE_Image
        default:
            if (msg.content.data.contains("\"imgs\"")){
                return .TYPE_TEXT_IMAGES
            }
            return .TYPE_Text
        }
    }
    
    /// 处理其他会话的消息提醒
    private func handleOtherConsultMessage() {
        let tempStr = systemMsgLabel.text
        systemMsgLabel.text = "其他客服有新消息！"
        
        // 3秒后恢复原来的文本
        delayExecution(seconds: 3) { [weak self] in
            self?.systemMsgLabel.text = tempStr
        }
    }
    
    // MARK: - 消息状态处理
    
    /// 处理消息删除（撤回）
    public func msgDeleted(msg: TeneasyChatSDK_iOS.CommonMessage, payloadId: UInt64, errMsg: String?) {
        // 从数据源中移除被删除的消息
        datasouceArray.removeAll { $0.message?.msgID == msg.msgID }
        
        // 显示撤回提示消息
        let tipMsg = composeALocalTxtMessage(textMsg: "对方撤回了一条消息")
        appendDataSource(msg: tipMsg, isLeft: false, cellType: .TYPE_Tip)
    }
    
    /// 处理消息回执
    public func msgReceipt(msg: TeneasyChatSDK_iOS.CommonMessage, payloadId: UInt64, errMsg: String?) {
        print("收到消息回执: \(msg.msgTime.date.toString(format: "yyyy-MM-dd HH:mm:ss"))")
        print("回执ID: \(payloadId)")
        
        // 查找对应消息并更新状态
        guard let index = datasouceArray.firstIndex(where: { $0.payLoadId == payloadId }) else { return }
        
        updateMessageStatus(at: index, with: msg)
        refreshMessageUI()
    }
    
    /// 更新消息状态
    private func updateMessageStatus(at index: Int, with msg: CommonMessage) {
        if msg.msgID == 0 {
            // 消息发送失败
            datasouceArray[index].sendStatus = .发送失败
            print("消息状态更新: 发送失败")
        } else {
            // 消息发送成功
            datasouceArray[index].message = msg
            datasouceArray[index].sendStatus = .发送成功
            
            // 处理回复消息
            if msg.replyMsgID > 0 {
                handleReplyMessageUpdate(at: index, with: msg)
            }
            
            // 重置自动回复设置
            withAutoReply = nil
            print("消息状态更新 \(msg.msgID): 发送成功")
        }
    }
    
    /// 处理回复消息更新
    private func handleReplyMessageUpdate(at index: Int, with msg: CommonMessage) {
        if let replyIndex = datasouceArray.firstIndex(where: { $0.message?.msgID == msg.replyMsgID }) {
            let oriMsg = datasouceArray[replyIndex].message
            let newText = msg.content.data.trimmingCharacters(in: .whitespacesAndNewlines)
            
            datasouceArray[index].replyItem = getReplyItem(oriMsg: oriMsg)
            datasouceArray[index].message?.content.data = newText
        }
    }
    
    // MARK: - 客服状态处理
    
    /// 处理客服更换
    public func workChanged(msg: Gateway_SCWorkerChanged) {
        consultId = msg.consultID
        
        // 检查是否需要更新客服信息
        guard msg.workerID != workerId else { return }
        
        print("客服更换: \(msg.workerName) at \(Date())")
        workerId = msg.workerID
        isFirstLoad = true
        
        // 获取新会话历史记录
        refreshChatHistory()
        updateWorker(workerName: msg.workerName, avatar: msg.workerAvatar)
    }
    
    /// 刷新聊天历史记录
    private func refreshChatHistory() {
        NetworkUtil.getHistory(consultId: Int32(consultId)) { [weak self] success, data in
            guard let self = self else { return }
            self.buildHistory(history: data ?? HistoryModel())
        }
    }
    
    // MARK: - 系统消息处理
    
    /// 处理系统消息
    public func systemMsg(result: TeneasyChatSDK_iOS.Result) {
        print("系统消息: \(result.Message) Code: \(result.Code)")
        
        // 只处理特定范围的错误码
        guard (1000...1010).contains(result.Code) else { return }
        
        isConnected = false
        handleSystemError(result)
    }
    
    /// 处理系统错误
    private func handleSystemError(_ result: Result) {
        // 处理特殊错误码, 1002无效Token, 1010在别处登录了，1005超过会话时间
        if [1002, 1010, 1005].contains(result.Code) {
            WWProgressHUD.showInfoMsg(result.Message)
            
            // 处理会话超时
            //if result.Code == 1005 {
                handleSessionTimeout()
            //}
        } else {
            //getUnSendMsg()
        }
        
        // 上报错误日志（会话超时除外）
        if result.Code != 1005 {
            reportErrorLog(result)
        }
    }
    
    /// 处理会话超时
    private func handleSessionTimeout() {
        quitChat()
        dismiss(animated: true)
    }
    
    /// 上报错误日志
    private func reportErrorLog(_ result: Result) {
        let wssUrl = "wss://" + domain + "/v1/gateway/h5?"
        NetworkUtil.logError(
            request: "userId: \(userId), cert: \(cert), token: \(xToken), sign: 9zgd9YUc",
            header: "x-token:\(xToken)",
            resp: result.Message,
            code: result.Code,
            url: wssUrl
        )
    }
    
    // MARK: - 连接状态处理
    
    /// 处理连接成功
    public func connected(c: Gateway_SCHi) {
        // 更新连接状态和Token
        updateConnectionState(with: c.token)
        
        // 显示连接状态
        if !isFirstLoad {
            WWProgressHUD.showLoading("连接中...")
        }
        
        print("连接成功: token:\(xToken) 正在分配客服")
        
        // 分配客服
        assignWorker()
    }
    
    /// 更新连接状态
    private func updateConnectionState(with token: String) {
        xToken = token
        isConnected = true
        UserDefaults.standard.set(token, forKey: PARAM_XTOKEN)
    }
    
    /// 分配客服
    func assignWorker() {
        NetworkUtil.assignWorker(consultId: Int32(consultId)) { [weak self] success, model in
            guard let self = self, success else {
                WWProgressHUD.dismiss()
                return
            }
            
            self.handleWorkerAssignment(model)
        }
    }
    
    /// 处理客服分配结果
    private func handleWorkerAssignment(_ model: AssignWorker?) {
        workerId = model?.workerId ?? 2
        
        // 首次加载时获取历史记录
        if isFirstLoad {
            refreshChatHistory()
        }
        
        // 处理未发送消息
        handleUnsentMessages()
        
        print("分配客服成功 \(Date()), Worker Id：\(model?.workerId ?? 0)")
        updateWorker(workerName: model?.nick ?? "", avatar: model?.avatar ?? "")
        
        WWProgressHUD.dismiss()
    }
    
    /// 处理未发送的消息
    private func handleUnsentMessages() {
        getUnSendMsg()
        _ = handleUnSendMsg()
    }
}

// MARK: - 辅助方法
extension KeFuViewController {
    /// 更新消息UI
    func updateMessageUI(at index: Int) {
        UIView.performWithoutAnimation {
            let currentOffset = tableView.contentOffset
            tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
            tableView.contentOffset = currentOffset
        }
    }
    
    /// 刷新消息列表UI
    func refreshMessageUI() {
        tableView.reloadData()
        print("已刷新消息列表")
    }
    
    
    //产生一个本地文本消息
    func composeALocalTxtMessage(textMsg: String, timeInS: String? = nil, msgId: Int64 = 0, replyMsgId: Int64 = 0) -> CommonMessage {
        // 第一层
        var content = CommonMessageContent()
        content.data = textMsg
        
        // 第二层, 消息主题
        var msg = CommonMessage()
        msg.content = content
        msg.sender = 0
        msg.chatID = 0
        msg.replyMsgID = replyMsgId
        msg.msgID = msgId
        msg.msgFmt = CommonMessageFormat.msgText
        msg.payload = .content(content)
        msg.worker = 0
        if timeInS == nil{
            msg.msgTime = intervalToTimeStamp(timeInterval: Date().timeIntervalSince1970)
        }else{
            msg.msgTime = stringToTimeStamp(datStr: timeInS!)
        }
        
        return msg
    }
    
    //产生一个本地图片消息
    func composeALocalImgMessage(url: String, timeInS: String? = nil, msgId: Int64 = 0, replyMsgId: Int64 = 0)  -> CommonMessage {
        // 第一层
        var content = CommonMessageImage()
        content.uri = url
        
        // 第二层, 消息主题
        var msg = CommonMessage()
        msg.consultID = self.consultId
        msg.image = content
        msg.sender = 0
        msg.msgID = msgId
        msg.msgFmt = CommonMessageFormat.msgImg
        msg.replyMsgID = replyMsgId
        msg.chatID = 0
        msg.payload = .image(content)
        msg.worker = 0
        if timeInS == nil{
            msg.msgTime = intervalToTimeStamp(timeInterval: Date().timeIntervalSince1970)
        }else{
            msg.msgTime = stringToTimeStamp(datStr: timeInS!)
        }
        
        return msg
    }
    
    //产生一个本地文件消息
    func composeALocalFileMessage(url: String, timeInS: String? = nil, msgId: Int64 = 0, replyMsgId: Int64 = 0, fileSize: Int32, fileName: String)  -> CommonMessage {
        // 第一层
        var content = CommonMessageFile()
        content.uri = url
        content.fileName = fileName
        content.size = fileSize
        
        // 第二层, 消息主题
        var msg = CommonMessage()
        msg.consultID = self.consultId
        msg.file = content
        msg.sender = 0
        msg.msgID = msgId
        msg.msgFmt = CommonMessageFormat.msgFile
        msg.replyMsgID = replyMsgId
        msg.chatID = 0
        msg.payload = .file(content)
        msg.msgFmt = CommonMessageFormat.msgFile
        msg.worker = 0
        if timeInS == nil{
            msg.msgTime = intervalToTimeStamp(timeInterval: Date().timeIntervalSince1970)
        }else{
            msg.msgTime = stringToTimeStamp(datStr: timeInS!)
        }
        
        return msg
    }
    
    
    //产生一个本地视频消息
    func composeALocalVideoMessage(url: String, thumb: String, hls: String, timeInS: String? = nil, msgId: Int64 = 0, replyMsgId: Int64 = 0) -> CommonMessage {
        // 第一层
        var content = CommonMessageVideo()
        content.uri = url
        content.thumbnailUri = thumb
        content.hlsUri = hls
        
        // 第二层, 消息主题
        var msg = CommonMessage()
        msg.consultID = self.consultId
        msg.video = content
        msg.sender = 0
        msg.msgID = msgId
        msg.msgFmt = CommonMessageFormat.msgVideo
        msg.replyMsgID = replyMsgId
        msg.chatID = 0
        msg.payload = .video(content)
        msg.worker = 0
        if timeInS == nil{
            msg.msgTime = intervalToTimeStamp(timeInterval: Date().timeIntervalSince1970)
        }else{
            msg.msgTime = stringToTimeStamp(datStr: timeInS!)
        }
        
        return msg
    }
    
    func handleUnSendMsg() -> Bool {
        //let filteredList = datasouceArray.filter { $0.sendStatus != .发送成功 && $0.isLeft == false }
        //print("handleUnSendMsg: \(filteredList.count)")
        
        if let filteredList = unSentMessage[consultId]{
            print("准备发未发出去的消息：\(filteredList)")
            for item in filteredList {
                if item.sendStatus != .发送成功 {
                    //DispatchQueue.global().asyncAfter(deadline: .now() + 1.0) {
                    print("resend payloadId: \(item.payLoadId)")
                    Thread.sleep(forTimeInterval: 0.3)
                    if let cMsg = item.message {
                       chatLib.resendMsg(msg: cMsg, payloadId: item.payLoadId)
                    }
                    
                    //}
                }
            }
        }
        
        return true
    }
    
    func getUnSendMsg(){
        if (datasouceArray.count == 0){
            return
        }
        
        let filteredList =
        datasouceArray.filter { $0.sendStatus != MessageSendState.发送成功 && $0.isLeft == false }
        unSentMessage[consultId] = filteredList
        print("未发出去的消息\(filteredList)")
    }
}
