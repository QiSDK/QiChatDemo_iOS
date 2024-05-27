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
    
    func initSDK(baseUrl: String) {
        let wssUrl = "wss://" + baseUrl + "/v1/gateway/h5?"
        // 第一次cert必填，之后token必填
        lib = ChatLib(userId: userId, cert: cert, token: xToken, baseUrl: wssUrl, sign: "9zgd9YUc")
        
        lib.callWebsocket()
        lib.delegate = self
    }
    
    public func receivedMsg(msg: TeneasyChatSDK_iOS.CommonMessage) {
        print("receivedMsg\(msg)")
        if msg.consultID != CONSULT_ID{
           // let msg = composeALocalTxtMessage(textMsg: "其他客服有新消息！")
           // appendDataSource(msg: msg, isLeft: false, cellType: .TYPE_Tip)
            self.view.makeToast("其他客服有新消息！")
        }else{
            if !msg.video.uri.isEmpty {
                appendDataSource(msg: msg, isLeft: true, cellType: .TYPE_VIDEO)
            }else{
                appendDataSource(msg: msg, isLeft: true)
            }
        }
    }
    
    public func msgDeleted(msg: TeneasyChatSDK_iOS.CommonMessage, payloadId: UInt64, errMsg: String?) {

        datasouceArray = datasouceArray.filter { modal in modal.message?.msgID != msg.msgID}
        
        let msg = composeALocalTxtMessage(textMsg: "对方撤回了一条消息")
        appendDataSource(msg: msg, isLeft: false, cellType: .TYPE_Tip)
    }
    
    public func msgReceipt(msg: TeneasyChatSDK_iOS.CommonMessage, payloadId: UInt64, errMsg: String?) {
        print("msgReceipt" + WTimeConvertUtil.displayLocalTime(from: msg.msgTime.date))
        // 通过payloadId从DataSource里面找对应记录，并更新状态和时间
        print("------\(payloadId)")
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
                print(msg.msgID)
                print("状态更新 -> 发送成功")
            }
            
            UIView.performWithoutAnimation {
                let loc = tableView.contentOffset
                tableView.reloadRows(at: [IndexPath(row: index!, section: 0)], with: UITableView.RowAnimation.none)
                tableView.contentOffset = loc
            }
        }

        /*let arr = datasouceArray.filter { modal in modal.message.msgID == 0 && modal.isLeft == false }
        for p in arr {
            print(p.message.msgID)
            p.sendStatus = .发送失败
            tableView.reloadData()
        }*/
        //tableView.reloadData()
        //scrollToBottom()
    }


    public func workChanged(msg: Gateway_SCWorkerChanged) {
        consultId = msg.consultID
        workerId = msg.workerID
        print(msg.workerName)
        updateWorker(workerName: msg.workerName, avatar: msg.workerAvatar)
    }
    
    public func systemMsg(result: TeneasyChatSDK_iOS.Result) {
        print("systemMsg")
        print(result.Message)
         if(result.Code >= 1000 && result.Code <= 1010){
             isConnected = false
             if result.Code == 1002 || result.Code == 1010{
                 //WWProgressHUD.showInfoMsg(result.Message)
                 //由于后端运信和起聊有冲突，所以这里错误码不一定对，不做任何处理
                 //stopTimer()
                 //isConnected = false
                 //navigationController?.popToRootViewController(animated: true)
             }
        }
    }
    
    public func connected(c: Gateway_SCHi) {
        xToken = c.token
        isConnected = true
        UserDefaults.standard.set(c.token, forKey: PARAM_XTOKEN)
        let f = self.isFirstLoad
        if f == false{
            WWProgressHUD.showLoading("连接中...")
        }
        
         print("连接成功：token:\(xToken)assign work")
         NetworkUtil.assignWorker(consultId: CONSULT_ID) { [weak self]success, model in
             if success {
                 print("assign work 成功, Worker Id：\(model?.workerId ?? 0)")
                 if f == false{
                     WWProgressHUD.dismiss()
                     return
                 }
                 self?.updateWorker(workerName: model?.nick ?? "", avatar: model?.avatar ?? "")
                 workerId = model?.workerId ?? 2
               
               NetworkUtil.getHistory(consultId: CONSULT_ID) { success, data in
                   //构建历史消息
                   self?.buildHistory(history:  data ?? HistoryModel())
                 }
             }
             WWProgressHUD.dismiss()
         }
    }
    
    //产生一个本地文本消息
    func composeALocalTxtMessage(textMsg: String, timeInS: String? = nil) -> CommonMessage {
        // 第一层
        var content = CommonMessageContent()
        content.data = textMsg
        
        // 第二层, 消息主题
        var msg = CommonMessage()
        msg.content = content
        msg.sender = 0
        msg.chatID = 0
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
    func composeALocalImgMessage(url: String, timeInS: String? = nil) -> CommonMessage {
        // 第一层
        var content = CommonMessageImage()
        content.uri = url
        
        // 第二层, 消息主题
        var msg = CommonMessage()
        msg.consultID = self.consultId
        msg.image = content
        msg.sender = 0

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
    
    //产生一个本地图片消息
    func composeALocalVideoMessage(url: String, timeInS: String? = nil) -> CommonMessage {
        // 第一层
        var content = CommonMessageVideo()
        content.uri = url
        
        // 第二层, 消息主题
        var msg = CommonMessage()
        msg.consultID = self.consultId
        msg.video = content
        msg.sender = 0

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
