//
//  KeFuViewController_ChatSDK.swift
//  TeneasyChatSDKUI_iOS
//
//  Created by Xuefeng on 20/5/24.
//

import Foundation
import TeneasyChatSDK_iOS
import Toast_Swift

extension KeFuViewController: teneasySDKDelegate {
    
    //初始化聊天SDK
    func initSDK(baseUrl: String) {
        let wssUrl = "wss://" + baseUrl + "/v1/gateway/h5?"
        // 第一次cert必填，之后token必填
        lib = ChatLib(userId: userId, cert: cert, token: xToken, baseUrl: wssUrl, sign: "9zgd9YUc")
        
        lib.callWebsocket()
        lib.delegate = self
    }
    
    //收到客服发来的消息
    public func receivedMsg(msg: TeneasyChatSDK_iOS.CommonMessage) {
        print("receivedMsg\(msg)")
        if msg.consultID != consultId{
            //以消息的形式提示：
           // let msg = composeALocalTxtMessage(textMsg: "其他客服有新消息！")
           // appendDataSource(msg: msg, isLeft: false, cellType: .TYPE_Tip)
            
            //以Toast的形式提示
            self.view.makeToast("其他客服有新消息！")
        }else{
            
            if msg.replyMsgID > 0{
                let model = datasouceArray.first { ChatModel in
                    ChatModel.message?.msgID == msg.replyMsgID
                }
                var txt = (model?.message?.content.data ?? "")
                var referMsg = "回复：\(txt)"
                if !(model?.message?.video.uri ?? "").isEmpty {
                    referMsg = "回复：[视频]"
                }else if !(model?.message?.image.uri ?? "").isEmpty {
                    referMsg = "回复：[图片]"
                }
                let newText = "\(msg.content.data)\n\(referMsg)"
                let newMsg = composeALocalTxtMessage(textMsg: newText)
                appendDataSource(msg: newMsg, isLeft: true, cellType: .TYPE_Text)
            }else{
                
                //如果是视频消息，cellType是TYPE_VIDEO
                if !msg.video.uri.isEmpty {
                    appendDataSource(msg: msg, isLeft: true, cellType: .TYPE_VIDEO)
                }else{
                    //其余当作普通消息，文字或图片
                    appendDataSource(msg: msg, isLeft: true)
                }
            }
        }
    }
    
    //如果客服那边撤回了消息，这个函数会被调用
    public func msgDeleted(msg: TeneasyChatSDK_iOS.CommonMessage, payloadId: UInt64, errMsg: String?) {
        datasouceArray = datasouceArray.filter { modal in modal.message?.msgID != msg.msgID}
        //用一个本地Tip消息提醒用户
        let msg = composeALocalTxtMessage(textMsg: "对方撤回了一条消息")
        appendDataSource(msg: msg, isLeft: false, cellType: .TYPE_Tip)
    }
    
    //发送消息后，会收到回执，然后根据payloadId从列表查询指定消息，然后更新消息状态
    public func msgReceipt(msg: TeneasyChatSDK_iOS.CommonMessage, payloadId: UInt64, errMsg: String?) {
        print("msgReceipt" + WTimeConvertUtil.displayLocalTime(from: msg.msgTime.date))
        print("回执:\(payloadId)")
        let index = datasouceArray.firstIndex { model in
            model.payLoadId == payloadId
        }
        if (index ?? -1) > -1 {
            if msg.msgID == 0 {
                datasouceArray[index!].sendStatus = .发送失败
                print("状态更新 -> 发送失败")
            } else {
                datasouceArray[index!].sendStatus = .发送成功
                datasouceArray[index!].message = msg
                print("状态更新\(msg.msgID) -> 发送成功")
            }
            
            UIView.performWithoutAnimation {
                let loc = tableView.contentOffset
                tableView.reloadRows(at: [IndexPath(row: index!, section: 0)], with: UITableView.RowAnimation.none)
                tableView.contentOffset = loc
            }
        }
    }

    //客服更换后，这个函数会被回调，并及时更新客服信息
    public func workChanged(msg: Gateway_SCWorkerChanged) {
        consultId = msg.consultID
        workerId = msg.workerID
        print(msg.workerName)
        NetworkUtil.getHistory(consultId: Int32(self.consultId )) { success, data in
          //构建历史消息
            self.buildHistory(history:  data ?? HistoryModel())
        }
        updateWorker(workerName: msg.workerName, avatar: msg.workerAvatar)
    }
    
    //SDK里面遇到的错误，会从这个回调告诉前端
    public func systemMsg(result: TeneasyChatSDK_iOS.Result) {
        print("systemMsg")
        print("\(result.Message) Code:\(result.Message)")
         if(result.Code >= 1000 && result.Code <= 1010){
             isConnected = false
             //1002是在别处登录了，1010是无效的Token
             if result.Code == 1002 || result.Code == 1010{
                 WWProgressHUD.showInfoMsg(result.Message)
                 stopTimer()
                 //navigationController?.popToRootViewController(animated: true)
             }
        }
    }
    
    //SDK成功连接的回调
    public func connected(c: Gateway_SCHi) {
        xToken = c.token
        isConnected = true
        //把获取到的Token保存到用户设置
        UserDefaults.standard.set(c.token, forKey: PARAM_XTOKEN)
        
        
        let f = self.isFirstLoad
        if f == false{
            WWProgressHUD.showLoading("连接中...")
        }
        
         print("连接成功：token:\(xToken)assign work")
        
        //SDK连接成功之后，分配客服
        NetworkUtil.assignWorker(consultId: Int32(self.consultId)) { [weak self]success, model in
             if success {
                 print("assign work 成功, Worker Id：\(model?.workerId ?? 0)")
                 if f == false{
                     WWProgressHUD.dismiss()
                     return
                 }
                 self?.updateWorker(workerName: model?.nick ?? "", avatar: model?.avatar ?? "")
                 workerId = model?.workerId ?? 2
               
                 NetworkUtil.getHistory(consultId: Int32(self?.consultId ?? 0)) { success, data in
                   //构建历史消息
                   self?.buildHistory(history:  data ?? HistoryModel())
                 }
             }
             WWProgressHUD.dismiss()
         }
    }
    
    //产生一个本地文本消息
    func composeALocalTxtMessage(textMsg: String, timeInS: String? = nil, msgId: Int64 = 0) -> CommonMessage {
        // 第一层
        var content = CommonMessageContent()
        content.data = textMsg
        
        // 第二层, 消息主题
        var msg = CommonMessage()
        msg.content = content
        msg.sender = 0
        msg.chatID = 0
        msg.msgID = msgId
        msg.payload = .content(content)
        msg.worker = 0
        if timeInS == nil{
            msg.msgTime.seconds = Int64(Date().timeIntervalSince1970)
        }else{
           //2024-05-23T08:52:25.417927678Z
            msg.msgTime.seconds = Int64(stringToDate(datStr: timeInS!, format: serverTimeFormat).timeIntervalSince1970)
        }
        
        return msg
    }
    
    //产生一个本地图片消息
    func composeALocalImgMessage(url: String, timeInS: String? = nil, msgId: Int64 = 0)  -> CommonMessage {
        // 第一层
        var content = CommonMessageImage()
        content.uri = url
        
        // 第二层, 消息主题
        var msg = CommonMessage()
        msg.consultID = self.consultId
        msg.image = content
        msg.sender = 0
        msg.msgID = msgId

        msg.chatID = 0
        msg.payload = .image(content)
        msg.worker = 0
        if timeInS == nil{
            msg.msgTime.seconds = Int64(Date().timeIntervalSince1970)
        }else{
           //2024-05-23T08:52:25.417927678Z
            msg.msgTime.seconds = Int64(stringToDate(datStr: timeInS!, format: serverTimeFormat).timeIntervalSince1970)
        }
        
        return msg
    }
    
    //产生一个本地视频消息
    func composeALocalVideoMessage(url: String, timeInS: String? = nil, msgId: Int64 = 0) -> CommonMessage {
        // 第一层
        var content = CommonMessageVideo()
        content.uri = url
        
        // 第二层, 消息主题
        var msg = CommonMessage()
        msg.consultID = self.consultId
        msg.video = content
        msg.sender = 0
        msg.msgID = msgId

        msg.chatID = 0
        msg.payload = .video(content)
        msg.worker = 0
        if timeInS == nil{
            msg.msgTime.seconds = Int64(Date().timeIntervalSince1970)
        }else{
           //2024-05-23T08:52:25.417927678Z
            msg.msgTime.seconds = Int64(stringToDate(datStr: timeInS!, format: serverTimeFormat).timeIntervalSince1970)
        }
        
        return msg
    }
}
