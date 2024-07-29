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
        if lib.payloadId == 0{
            print("initSDK 初始化SDK")
            // 第一次cert必填，之后token必填
//            lib = ChatLib(userId: userId, cert: cert, token: xToken, baseUrl: wssUrl, sign: "9zgd9YUc")
//            
//            lib.callWebsocket()
//            lib.delegate = self
            
            
            lib.myinit(userId: userId, cert: cert, token: xToken, baseUrl: wssUrl, sign: "9zgd9YUc")
            
            lib.callWebsocket()
            lib.delegate = self
        }else{
            print("initSDK 重新连接")
            lib.reConnect()
            lib.delegate = self
        }
    }
    
    //收到客服发来的消息
    public func receivedMsg(msg: TeneasyChatSDK_iOS.CommonMessage) {
        print("receivedMsg\(msg)")
        if msg.consultID != consultId{
            //以消息的形式提示：
           // let msg = composeALocalTxtMessage(textMsg: "其他客服有新消息！")
           // appendDataSource(msg: msg, isLeft: false, cellType: .TYPE_Tip)
            
            //以Toast的形式提示
            //self.view.makeToast("其他客服有新消息！")
            let tempStr = self.systemMsgLabel.text
            self.systemMsgLabel.text = "其他客服有新消息！"
            delayExecution(seconds: 3, completion: {
                self.systemMsgLabel.text = tempStr
            })
        }else{
            
            if msg.msgOp == .msgOpEdit{
                if let index = datasouceArray.firstIndex(where: { $0.message?.msgID == msg.msgID }) {
                       // Update the content of the found ChatModel
                    //datasouceArray[index].message?.content.data = msg.content.data
                    datasouceArray[index].message = msg
                       // Print a confirmation message
                       print("消息内容更新了")
                       
                       // Reload the table view to reflect the changes
                       //tableView.reloadData()
                    
                    UIView.performWithoutAnimation {
                        let loc = tableView.contentOffset
                        tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: UITableView.RowAnimation.none)
                        tableView.contentOffset = loc
                    }
                    
                   } else {
                       // Print an error message if no matching ChatModel is found
                       print("未找到匹配的消息ID")
                   }
            }
            else if msg.replyMsgID > 0{
                if let model = datasouceArray.first(where: { ChatModel in
                    ChatModel.message?.msgID == msg.replyMsgID
                }){
                    var replayQuote = model.message?.content.data.components(separatedBy: "回复：")[0]
                    if !(model.message?.video.uri ?? "").isEmpty {
                        replayQuote = "[视频]"
                    }else if !(model.message?.image.uri ?? "").isEmpty {
                        replayQuote = "[图片]"
                    }
                    let newText = "\(msg.content.data)".trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                    let newMsg = composeALocalTxtMessage(textMsg: newText, msgId: msg.msgID)
                    //model.replayQuote = replayQuote ?? ""
                    appendDataSource(msg: newMsg, isLeft: true, cellType: .TYPE_Text, replayQuote: replayQuote)
                }else{
                    appendDataSource(msg: msg, isLeft: true, cellType: .TYPE_Text)
                }
            }else{
                
                //如果是视频消息，cellType是TYPE_VIDEO
                if !msg.video.uri.isEmpty {
                    appendDataSource(msg: msg, isLeft: true, cellType: .TYPE_VIDEO)
                }else  if !msg.image.uri.isEmpty {
                    appendDataSource(msg: msg, isLeft: true, cellType: .TYPE_Image)
                }else{
                    //其余当作普通消息
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
        print("msgReceipt" + msg.msgTime.date.toString(format: "yyyy-MM-dd HH:mm:ss"))
        print("回执:\(payloadId)")
        let index = datasouceArray.firstIndex { model in
            model.payLoadId == payloadId
        }
        if (index ?? -1) > -1 {
            if msg.msgID == 0 {
                datasouceArray[index!].sendStatus = .发送失败
                print("状态更新 -> 发送失败")
            } else {
                datasouceArray[index!].message = msg
                datasouceArray[index!].sendStatus = .发送成功
                if (msg.replyMsgID > 0){
                    if let x = datasouceArray.firstIndex(where: { $0.message?.msgID == msg.replyMsgID }) {
                        // Update the content of the found ChatModel
                        //datasouceArray[index].message?.content.data = msg.content.data
                        let model = datasouceArray[x]
                        //let txt = (model.message?.content.data ?? "")
                        var replyQuote = model.message?.content.data.components(separatedBy: "回复：")[0]
                        
                        if !(model.message?.video.uri ?? "").isEmpty {
                            replyQuote = "[视频]"
                        }else if !(model.message?.image.uri ?? "").isEmpty {
                            replyQuote = "[图片]"
                        }
                        let newText = "\(msg.content.data)"
                        datasouceArray[index!].replayQuote = replyQuote ?? ""
                        datasouceArray[index!].message?.content.data = newText.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                    }
                }
                print("状态更新\(msg.msgID) -> 发送成功")
            }
            
           /* UIView.performWithoutAnimation {
                let loc = tableView.contentOffset
                tableView.reloadRows(at: [IndexPath(row: index!, section: 0)], with: UITableView.RowAnimation.none)
                tableView.contentOffset = loc
            }
            */
            
            tableView.reloadData()
            print("tableView.reloadData()")
        }
    }

    //客服更换后，这个函数会被回调，并及时更新客服信息
    public func workChanged(msg: Gateway_SCWorkerChanged) {
        consultId = msg.consultID
  
        if msg.workerID != workerId{
            print(msg.workerName)
            print("客服更换了\(Date())")
            workerId = msg.workerID
            isFirstLoad = true
            NetworkUtil.getHistory(consultId: Int32(self.consultId )) { success, data in
                //构建历史消息
                self.buildHistory(history:  data ?? HistoryModel())
            }
            updateWorker(workerName: msg.workerName, avatar: msg.workerAvatar)
        }
    }
    
    //SDK里面遇到的错误，会从这个回调告诉前端
    public func systemMsg(result: TeneasyChatSDK_iOS.Result) {
        print("systemMsg")
        print("\(result.Message) Code:\(result.Code)")
         if(result.Code >= 1000 && result.Code <= 1010){
             isConnected = false
             //1002是在别处登录了，1010是无效的Token
             if result.Code == 1002 || result.Code == 1010{
                 WWProgressHUD.showInfoMsg(result.Message)
                 stopTimer()
                 //navigationController?.popToRootViewController(animated: true)
             }else{
                 getUnSendMsg()
             }
        }
    }
    
    //SDK成功连接的回调
    public func connected(c: Gateway_SCHi) {
        xToken = c.token
        isConnected = true
        //把获取到的Token保存到用户设置
        UserDefaults.standard.set(c.token, forKey: PARAM_XTOKEN)
        
        
        //let f = self.isFirstLoad
        if !isFirstLoad{
            WWProgressHUD.showLoading("连接中...")
        }
        
         print("连接成功：token:\(xToken) 分配客服")
        
        //SDK连接成功之后，分配客服
        NetworkUtil.assignWorker(consultId: Int32(self.consultId)) { [weak self]success, model in
             if success {

                 workerId = model?.workerId ?? 2
               
                 if self?.isFirstLoad ?? false{
                     print("获取聊天记录")
                     NetworkUtil.getHistory(consultId: Int32(self?.consultId ?? 0)) { success, data in
                         //构建历史消息
                         self?.buildHistory(history:  data ?? HistoryModel())
                     }
                 }//else{
                     print("处理未发出去的消息")
                         self?.getUnSendMsg()
                     _ = self?.handleUnSendMsg()
                 //}
                 print("分配客服成功\(Date()), Worker Id：\(model?.workerId ?? 0)")
  
                 self?.updateWorker(workerName: model?.nick ?? "", avatar: model?.avatar ?? "")
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
            msg.msgTime = intervalToTimeStamp(timeInterval: Date().timeIntervalSince1970)
        }else{
            msg.msgTime = stringToTimeStamp(datStr: timeInS!)
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
            msg.msgTime = intervalToTimeStamp(timeInterval: Date().timeIntervalSince1970)
        }else{
            msg.msgTime = stringToTimeStamp(datStr: timeInS!)
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
                        self.lib.resendMsg(msg: cMsg, payloadId: item.payLoadId)
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
