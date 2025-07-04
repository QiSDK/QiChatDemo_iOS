import Foundation
import Starscream
import SwiftProtobuf
import UIKit
// import Toast

// https://swiftpackageregistry.com/daltoniam/Starscream
// https://www.kodeco.com/861-websockets-on-ios-with-starscream
public protocol teneasySDKDelegate : AnyObject{
    //收到消息
    func receivedMsg(msg: CommonMessage)
    //消息回执
    func msgReceipt(msg: CommonMessage, payloadId: UInt64, errMsg: String?)
    //删除回执
    func msgDeleted(msg: CommonMessage, payloadId: UInt64, errMsg: String?)
    //系统消息，用于显示Tip
    //func systemMsg(msg: String)
    func systemMsg(result: Result)
    //连接状态
    func connected(c: Gateway_SCHi)
    //客服更换回调
    func workChanged(msg: Gateway_SCWorkerChanged)
}

open class ChatLib: NetworkManagerDelegate {
    func networkRechabilityStatus(status: NetworkManagerStatus) {
        switch status {
                    case .notReachable:
                        print("ChatLib:[RECHABILITY] The network is not reachable")
                        //1009 断网了
                        disConnected(code: 1009, msg: "网络中断了")
                    case .unknown :
                        print("ChatLib:[RECHABILITY] It is unknown whether the network is reachable")
                    case .ethernetOrWiFi:
                        print("ChatLib:[RECHABILITY] The network is reachable over the WiFi connection")
                    case .cellular:
                        print("ChatLib:[RECHABILITY] The network is reachable over the WWAN connection")
                }
            
              //  networkManager.stopNetworkReachabilityObserver()
    }
    
    public private(set) var text = "Teneasy Chat SDK 启动"
    private var baseUrl = "wss://csapi.xdev.stream/v1/gateway/h5?token="
    var websocket: WebSocket?
    var isConnected = false
    // weak var delegate: WebSocketDelegate?
    public weak var delegate: teneasySDKDelegate?
    open var payloadId: UInt64 = 0
    public var sendingMsg: CommonMessage?
    private var msgList: [UInt64: CommonMessage] = [:]
    var chatId: Int64 = 0
    public var token: String = ""
    var session = Session()
    
    private var myTimer: Timer?
    private var sessionTime: Int = 0
    //var chooseImg: UIImage?
    private var beatTimes = 0
    private var maxSessionMinutes = 90000000//相当于不设置会话超时时间 //90
    var workId: Int32 = 5
    private var replyMsgId: Int64 = 0
    private var userId: Int32 = 0
    private var custom: String = ""
    private var sign: String = ""
    private var cert: String = ""
    private var networkManager = NetworkManager()
    public static let shared = ChatLib()
    private var withAutoReply: CommonWithAutoReply?

    var consultId: Int64 = 0
    var fileSize: Int32 = 0
    var fileName: String = ""

    public init() {}

    public func myinit(userId:Int32, cert: String, token: String, baseUrl: String, sign: String, chatId: Int64 = 0, custom: String = "", maxSessionMinutes: Int = 90000000) {
        self.chatId = chatId
        self.cert = cert
        self.baseUrl = baseUrl
        self.userId = userId
        self.sign = sign
        self.token = token
        self.custom = custom
        self.maxSessionMinutes = maxSessionMinutes
        beatTimes = 0
        print(text)
        
        networkManager.delegate = self
               networkManager.startNetworkReachabilityObserver()
    }

   public func callWebsocket() {
        let rd = Int.random(in: 1000000..<9999999)
        let date = Date()
        let dt = Int(date.timeIntervalSince1970 * 1000)
       let urlStr = "\(baseUrl)cert=\(cert)&token=\(token)&userid=\(self.userId)&custom=\(custom)&ty=\(Api_Common_ClientType.userAppIos.rawValue)&dt=\(dt)&sign=\(self.sign)&rd=\(rd)"
        print(urlStr)
        guard let url = URL(string: urlStr) else { return }
        var request = URLRequest(url: url)
       let uuid = UUID().uuidString
        request.setValue(uuid, forHTTPHeaderField: "x-trace-id")
       print("x-trace-id：\(uuid)")
        websocket = WebSocket(request: request)
        websocket?.request.timeoutInterval = 5 // Sets the timeout for the connection
        websocket?.delegate = self
        websocket?.connect()
        
        /* 添加header的办法
         request.setValue("someother protocols", forHTTPHeaderField: "Sec-WebSocket-Protocol")
         request.setValue("14", forHTTPHeaderField: "Sec-WebSocket-Version")
         request.setValue("chat,superchat", forHTTPHeaderField: "Sec-WebSocket-Protocol")
         request.setValue("Everything is Awesome!", forHTTPHeaderField: "My-Awesome-Header")
         */
        startTimer()
        print("ChatLib:call web socket - \(Date())")
    }
    
    public func reConnect(){
//        if websocket != nil{
//            websocket?.connect()
//        }
        callWebsocket()
    }
    
    deinit {
        print("ChatLib:deinit")
        if websocket != nil{
            disConnected()
        }
    }
    
    func startTimer() {
       //stopTimer()
        if myTimer != nil{
            return
        }
        myTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updataSecond), userInfo: nil, repeats: true)
        myTimer!.fire()
    }

    
    @objc func updataSecond() {
        sessionTime += 1
        if sessionTime % 30 == 0{//每隔30秒发送一个心跳
            beatTimes += 1
            print("ChatLib:心跳第 \(beatTimes) 次 \(Date())")
            sendHeartBeat()
        }
        
        if sessionTime > maxSessionMinutes * 60{//超过最大会话，停止发送心跳
            disConnected(code: 1005, msg: "会话已超时")
            disConnect()
        }
    }

    private func stopTimer() {
        beatTimes = 0
        sessionTime = 0
        if myTimer != nil {
            myTimer!.invalidate() // 销毁timer
            myTimer = nil
        }
    }
    
    public func resetSessionTime(){
        self.sessionTime = 0
    }
    
    ///此接口不支持发视频
    public func sendMessage(msg: String, type: CommonMessageFormat, consultId: Int64, replyMsgId: Int64? = 0, withAutoReply: CommonWithAutoReply? = nil, fileSize: Int32 = 0, fileName: String = "") {
        self.replyMsgId = replyMsgId ?? 0
        self.consultId = consultId;
        self.withAutoReply = withAutoReply
        self.fileName = fileName
        self.fileSize = fileSize
        // 发送信息的封装，有四层
        // payload -> CSSendMessage -> common message -> CommonMessageContent
        switch type{
        case .msgText:
            sendTextMessage(txt: msg)
        case .msgImg:
            sendImageMessage(url: msg)
        case .msgFile:
            sendFileMessage(url: msg)
        default:
            sendTextMessage(txt: msg)
        }

        doSend()
    }
    
    public func deleteMessage(msgId: Int64){
        // 第一层
        //var content = CommonMessageContent()
        //content.data = "d"
        
        var msg = CommonMessage()
        msg.consultID = self.consultId
        //msg.content = content
        msg.chatID = chatId//2692944494609
        msg.msgID = msgId
        msg.msgOp = .msgOpDelete
        // 临时放到一个变量
        sendingMsg = msg
        
        doSend()
    }
    
    private func sendTextMessage(txt: String){
        // 第一层
        var content = CommonMessageContent()
        content.data = txt
        
        // 第二层, 消息主题
        var msg = CommonMessage()
        msg.consultID = self.consultId
        msg.content = content
        msg.sender = 0
        msg.replyMsgID = self.replyMsgId
        msg.msgFmt = CommonMessageFormat.msgText
        msg.chatID = chatId
        msg.payload = .content(content)
        msg.worker = workId
        
        msg.msgTime.seconds = Int64(Date().timeIntervalSince1970)
        
        // 临时放到一个变量
        sendingMsg = msg
    }
    
    private func sendImageMessage(url: String){
        // 第一层
        var content = CommonMessageImage()
        content.uri = url
        
        // 第二层, 消息主题
        var msg = CommonMessage()
        msg.consultID = self.consultId
        msg.image = content
        msg.sender = 0
        msg.replyMsgID = self.replyMsgId
        msg.msgFmt = CommonMessageFormat.msgImg
        msg.chatID = chatId
        msg.payload = .image(content)
        msg.worker = workId
        msg.msgTime.seconds = Int64(Date().timeIntervalSince1970)
        
        // 临时放到一个变量
        sendingMsg = msg
    }
    
    ///此接口专门发视频
    public func sendVideoMessage(url: String, thumbnailUri: String = "", hlsUri: String = "", consultId: Int64, replyMsgId: Int64? = 0, withAutoReply: CommonWithAutoReply? = nil) {
        self.replyMsgId = replyMsgId ?? 0
        self.consultId = consultId;
        self.withAutoReply = withAutoReply
        // 第一层
        var content = CommonMessageVideo()
        content.hlsUri = hlsUri
        content.thumbnailUri = thumbnailUri
        content.uri = url
        
        // 第二层, 消息主题
        var msg = CommonMessage()
        msg.consultID = self.consultId
        msg.video = content
        msg.sender = 0
        msg.replyMsgID = self.replyMsgId
        msg.msgFmt = CommonMessageFormat.msgVideo
        msg.chatID = chatId
        msg.payload = .video(content)
        msg.worker = workId
        msg.msgTime.seconds = Int64(Date().timeIntervalSince1970)
        
        // 临时放到一个变量
        sendingMsg = msg
        doSend()
    }
    
    private func sendAudioMessage(url: String){
        // 第一层
        var content = CommonMessageAudio()
        content.uri = url
        
        // 第二层, 消息主题
        var msg = CommonMessage()
        msg.consultID = self.consultId
        msg.audio = content
        msg.sender = 0
        msg.replyMsgID = self.replyMsgId
        msg.chatID = chatId
        msg.msgFmt = CommonMessageFormat.msgVoice
        msg.payload = .audio(content)
        msg.worker = 5
        msg.msgTime.seconds = Int64(Date().timeIntervalSince1970)
        
        // 临时放到一个变量
        sendingMsg = msg
    }
    
    private func sendFileMessage(url: String){
        // 第一层
        var content = CommonMessageFile()
        content.uri = url
        content.size = self.fileSize
        content.fileName = self.fileName
        
        // 第二层, 消息主题
        var msg = CommonMessage()
        msg.consultID = self.consultId
        msg.file = content
        msg.sender = 0
        msg.replyMsgID = self.replyMsgId
        msg.msgFmt = CommonMessageFormat.msgFile
        msg.chatID = chatId
        msg.payload = .file(content)
        msg.worker = 5
        msg.msgTime.seconds = Int64(Date().timeIntervalSince1970)
        
        // 临时放到一个变量
        sendingMsg = msg
    }
    
    private func doSend(payload_Id: UInt64 = 0){
       guard var msg = sendingMsg else {
            return
        }
        
        if let w = self.withAutoReply{
           // if msgList.count == 0{
                let withAutoReplies = Array(arrayLiteral: w)
                msg.withAutoReplies = withAutoReplies
            //}
        }
        
        // 第三层
        var cSendMsg = Gateway_CSSendMessage()
        cSendMsg.msg = msg
        // Serialize to binary protobuf format:
        let cSendMsgData: Data = try! cSendMsg.serializedData()
        
        // 第四层
        var payLoad = Gateway_Payload()
        payLoad.data = cSendMsgData
        
//        if msg.msgOp == .msgOpDelete{
//            payLoad.act = .csdeleteMsg
//        }else{
            payLoad.act = .cssendMsg
        //}
   
        //payload_id != 0的时候，可能是重发，重发不需要+1
        if (sendingMsg?.msgOp == .msgOpPost && payload_Id == 0){
            payloadId += 1
            print("ChatLib:payloadID + 1:" + String(payloadId))
            msgList[payloadId] = msg
        }
        
        if payload_Id != 0{
            payLoad.id = payload_Id
        }else{
            payLoad.id = payloadId
        }
        let binaryData: Data = try! payLoad.serializedData()
        send(binaryData: binaryData)
    }
    
   public func resendMsg(msg: CommonMessage, payloadId: UInt64) {
        // 临时放到一个变量
        sendingMsg = msg
        doSend(payload_Id: payloadId)
    }
 
    private func sendHeartBeat() {
        let array: [UInt8] = [0]

        let myData = Data(bytes: array)
        send(binaryData: myData)
        //print("ChatLib:sending heart beat")
    }
    
    private func send(binaryData: Data) {
        if websocket == nil || !isConnected{
            callWebsocket()
        } else {
            print("ChatLib:开始发送")
            websocket?.write(data: binaryData, completion: ({
                print("ChatLib:msg sent")
            }))
        }
    }
    
    private func failedToSend(){
        if let msg = sendingMsg{
            delegate?.msgReceipt(msg: msg, payloadId: payloadId, errMsg: nil)
            sendingMsg = nil
        }
    }
    
    private func disConnected(code: Int = 1006, msg: String = "已断开通信") {
        //stopTimer()
        var result = Result()
        result.Code = code
        result.Message = msg
        delegate?.systemMsg(result: result)
        isConnected = false
        sendingMsg = nil
        print("ChatLib:\(code) \(msg))")
    }
    
    public func disConnect() {
        stopTimer()
        if let socket = websocket {
            socket.disconnect()
            socket.delegate = nil
            websocket = nil
        }

        isConnected = false
        sendingMsg = nil
        payloadId = 0
        //msgList.removeAll()
        networkManager.stopNetworkReachabilityObserver()
        print("ChatLib:退出了Chat SDK")
    }
}



// MARK: - WebSocketDelegate
extension ChatLib: WebSocketDelegate {
    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        print("ChatLib:got some text: \(text)")
    }

    public func didReceive(event: WebSocketEvent, client: WebSocket) {
        switch event {

        case .connected:
            // print("ChatLib:connected" + headers.description)
//            if self.websocket !== client {
//                return
//            }
            isConnected = true
            var result = Result()
            result.Code = 0
            result.Message = "已连接上"
            delegate?.systemMsg(result: result)
        case .disconnected(let reason, let closeCode):
//            if self.websocket !== client {
//                return
//            }
            print("ChatLib:disconnected \(reason) \(closeCode)")
            isConnected = false
            disConnected()
            failedToSend()
        case .text(let text):
            print("ChatLib:received text: \(text)")
        case .binary(let data):
            /*
            walter, [17 May 2024 at 3:32:00 PM (17 May 2024 at 3:32:23 PM)]:
    ...HeartBeatFlag         = 0x0
    KickFlag              = 0x1
    InvalidTokenFlag      = 0x2
    PermChangedFlag       = 0x3
    EntranceNotExistsFlag = 0x4

    如果这个字节的值是 0 ，表示心跳...
             */
//            if self.websocket !== client {
//                return
//            }
            if data.count == 1 {
                    if let d = String(data: data, encoding: .utf8) {
                        if d.contains("\u{00}") {
                            print("ChatLib:收到心跳回执\(beatTimes)\n")
                        }  else if d.contains("\u{03}") {
                            //disConnect(code: 1003, msg: "无效的Token\n")
                            print("ChatLib:收到1字节回执\(d) PermChangedFlag 0x3\n")
                        }else if d.contains("\u{02}") {
                            disConnected(code: 1002, msg: "无效的Token\n")
                            print("ChatLib:收到1字节回执\(d) 无效的Token 0x2\n")
                        } else if d.contains("\u{01}") {
                            disConnected(code: 1010, msg: "在别处登录了\n")
                            print("ChatLib:收到1字节回执\(d) 在别处登录了\n")
                        } else {
                            print("ChatLib:收到1字节回执\(d)\n")
                        }
                    }
            } else {
                guard let payLoad = try? Gateway_Payload(serializedBytes: data) else { return }
                let msgData = payLoad.data
//                if sendingMsg?.msgOp != .msgOpDelete{
//                    payloadId = payLoad.id
//                }
                print("ChatLib:new payloadID:" + String(payLoad.id))
                //有收到消息，就重设超时时间。
                resetSessionTime()
                if payLoad.act == .screcvMsg {
                    let scMsg = try? Gateway_SCRecvMessage(serializedBytes: msgData)
                    let msg = scMsg?.msg
                    if msg != nil {
                        if (msg!.msgOp == .msgOpDelete){
                            //msg?.msgID = -1
                            print("ChatLib:对方撤回了消息 payloadID:" + String(payLoad.id))
                            delegate?.msgDeleted(msg: msg!, payloadId: payLoad.id, errMsg: nil)
                        }else{
                            delegate?.receivedMsg(msg: msg!)
                        }
                    }
                } else if payLoad.act == .schi { // 连接成功后收到的信息，会返回clientId, Token
                    if let msg = try? Gateway_SCHi(serializedBytes: msgData) {
                        //print("ChatLib:chatID:" + String(msg.id))
                        delegate?.connected(c: msg)
                        payloadId = payLoad.id
                        print("ChatLib:初始payloadId:" + String(payloadId))
                    }
                } else if payLoad.act == .scworkerChanged {
                    if let msg = try? Gateway_SCWorkerChanged(serializedBytes: msgData) {
                        consultId = msg.consultID
                        delegate?.workChanged(msg: msg)
                        print(msg)
                    }
                }
                
                /*
                 else if(payLoad.act == GAction.Action.ActionSCDeleteMsgACK) {
                                 val msg = GGateway.SCSendMessage.parseFrom(msgData)
                                 Log.i(TAG, "删除回执收到：消息ID: ${msg.msgId}")
                             }  else if(payLoad.act == GAction.Action.ActionSCDeleteMsg) {
                                 val msg = GGateway.SCRecvMessage.parseFrom(msgData)
                                 Log.i(TAG, "对方删除了消息：消息ID: ${msg.msg.msgId}")
                             }
                 */
                else if payLoad.act == .scdeleteMsgAck {
                    let cMsg = try? Gateway_SCReadMessage(serializedBytes: msgData)
                    print("ChatLib:删除消息回执A，payloadId:\(payLoad.id) msgId:\(cMsg?.msgID ?? 0)")
                    if let cMsg = cMsg{
                        //delegate?.msgReceipt(msg: msg, payloadId: payLoad.id)
                        // 第二层, 消息主题
                        var msg = CommonMessage()
                        //msg.msgID = -1
                        msg.msgID = Int64(cMsg.msgID)
                        msg.msgOp = .msgOpDelete
                        msg.chatID = cMsg.chatID
                        delegate?.msgDeleted(msg: msg, payloadId: payLoad.id, errMsg: nil)
                        print(msg)
                    }
                }
                else if payLoad.act == .scdeleteMsg {
                    let cMsg = try? Gateway_CSRecvMessage(serializedBytes: msgData)
                    if let cMsg = cMsg{
                        //delegate?.msgReceipt(msg: msg, payloadId: payLoad.id)
                        // 第二层, 消息主题
                        var msg = CommonMessage()
                        //msg.msgID = -1
                        msg.msgID = Int64(cMsg.msgID)
                        msg.msgOp = .msgOpDelete
                        msg.chatID = cMsg.chatID
                        delegate?.msgDeleted(msg: msg, payloadId: payLoad.id, errMsg: nil)
                        print(msg)
                    }
                }
                else if payLoad.act == .forward {
                    let msg = try? Gateway_CSForward(serializedBytes: msgData)
                    print(msg!)
                } else if payLoad.act == .scsendMsgAck { // 服务器告诉此条信息是否发送成功
                    if let scMsg = try? Gateway_SCSendMessage(serializedBytes: msgData) {
                        print("ChatLib:消息回执Step 1，payloadId:\(payLoad.id) msgId:\(scMsg.msgID)")

                        if msgList[payLoad.id] != nil{
                            var cMsg = msgList[payLoad.id]
                            cMsg?.msgID = Int64(scMsg.msgID)
                            cMsg?.msgTime = scMsg.msgTime
                            chatId = scMsg.chatID
                            print("ChatLib:消息回执Step 2")
                            if cMsg != nil{
                                if (sendingMsg?.msgOp == .msgOpDelete){
                                    //cMsg!.msgID = -1
                                    cMsg!.msgOp = .msgOpDelete
                                    print("ChatLib:删除消息成功");
                                    delegate?.msgDeleted(msg: cMsg!, payloadId: payLoad.id, errMsg: scMsg.errMsg)
                                    return
                                }else if(!scMsg.errMsg.isEmpty){
                                    cMsg!.msgID = -2
                                }
                                delegate?.msgReceipt(msg: cMsg!, payloadId: payLoad.id, errMsg: scMsg.errMsg)
                            }
                        }
                    }
                } else {
                    print("ChatLib:received data: \(data)")
                }
            }

        case .pong(let pongData):
            print("ChatLib:received pong: \(String(describing: pongData))")
        case .ping(let pingData):
            print("ChatLib:received ping: \(String(describing: pingData))")
        case .error(let error):
            print("ChatLib:socket error \(String(describing: error))")
            disConnected()
            failedToSend()
            isConnected = false
        case .viabilityChanged:
            print("ChatLib:viabilityChanged")
        case .reconnectSuggested:
            print("ChatLib:reconnectSuggested")
        case .cancelled:
//            if self.websocket !== client {
//                return
//            }
            disConnected(code: 1007)
            failedToSend()
            print("ChatLib:cancelled")
            isConnected = false
        }
    }
    
    ///显示一个文本消息，无需经过服务器
    public func composeALocalMessage(textMsg: String) -> CommonMessage {
        // 第一层
        var content = CommonMessageContent()
        content.data = textMsg
        
        // 第二层, 消息主题
        var msg = CommonMessage()
        msg.content = content
        msg.sender = 0
        msg.chatID = chatId
        msg.payload = .content(content)
        msg.worker = 5
        msg.msgTime.seconds = Int64(Date().timeIntervalSince1970)
        
        return msg
    }
}
