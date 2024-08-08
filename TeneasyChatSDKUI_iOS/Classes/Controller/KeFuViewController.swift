//
//  ChatViewController.swift
//  TeneasyChatSDK_iOS
//
//  Created by XiaoFu on 01/19/2023.
//  Copyright (c) 2023 XiaoFu. All rights reserved.
//

import Alamofire
import Network
import PhotosUI
import TeneasyChatSDK_iOS
import UIKit

//客服聊天页面
open class KeFuViewController: UIViewController{
    //消息列表的数据源
    var datasouceArray: [ChatModel] = []
    //所选择的咨询类型Id
    var consultId: Int64 = 0
    //聊天SDK库
    var lib = ChatLib.shared
    //是否第一次加载页面，历史记录和自动回复列表只是在第一次加载页面的时候调用
    internal var isFirstLoad = true
    //是否在已经连接状态的标记
    var isConnected: Bool = false
   
    //自动回复消息区域的高度，根据自动回复列表的高度动态调整
    var questionViewHeight: Double = 0
    var workerName: String = ""
     var avatarPath: String = ""
    
    //一个定时器，每隔几秒检查连接状态，如果状态不是在连接状态，就重新连接
    //private var myTimer: Timer?
    //static let shared = KeFuViewController()
       var myTimer: Timer?

    //当前选择的图片
    var chooseImg: UIImage?
    lazy var imagePickerController: UIImagePickerController = {
        let pick = UIImagePickerController()
        pick.delegate = self
        return pick
    }()

    lazy var headerView: UIView = {
        let v = UIView(frame: CGRect.zero)
        if #available(iOS 13.0, *) {
            v.backgroundColor = UIColor.tertiarySystemBackground
        } else {
            // Fallback on earlier versions
        }
        return v
    }()

    lazy var systemInfoView: UIView = {
        let v = UIView(frame: CGRect.zero)
        return v
    }()

    lazy var timeLabel: UILabel = {
        let label = UILabel(frame: CGRect.zero)
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()

    lazy var systemMsgLabel: UILabel = {
        let label = UILabel(frame: CGRect.zero)
        label.textAlignment = .center
        label.textColor = kHexColor(0x228AFE)
        label.font = UIFont.systemFont(ofSize: 13)
        return label
    }()

    lazy var headerImg: UIImageView = {
        let img = UIImageView(frame: CGRect.zero)
        img.layer.cornerRadius = 25
        img.layer.masksToBounds = true
        img.image = UIImage.svgInit("com_moren")
        return img
    }()

    lazy var headerTitle: UILabel = {
        let v = UILabel(frame: CGRect.zero)
        v.text = "--"
        if #available(iOS 13.0, *) {
            v.textColor = UIColor.label
        } else {
            // Fallback on earlier versions
        }
        return v
    }()

    lazy var headerClose: UIButton = {
        let btn = UIButton(frame: CGRect.zero)
        btn.setImage(UIImage.svgInit("backicon", size: CGSize(width: 40, height: 40)), for: UIControl.State.normal)
        if #available(iOS 13.0, *) {
            btn.setImage(UIImage.svgInit("backicon", size: CGSize(width: 40, height: 40))?.withTintColor(UIColor.systemGray), for: UIControl.State.normal)
        } else {
            // Fallback on earlier versions
        }
        btn.addTarget(self, action: #selector(closeClick), for: UIControl.Event.touchUpInside)
        return btn
    }()
    

    /// 输入框工具栏
    lazy var toolBar: BWKeFuChatToolBarV2 = {
        let toolBar = BWKeFuChatToolBarV2()
        toolBar.delegate = self
        return toolBar
    }()

    lazy var tableView: UITableView = {
        let view = UITableView()
        view.delegate = self
        view.dataSource = self
        view.separatorStyle = .none
        view.estimatedRowHeight = 50
        view.rowHeight = UITableView.automaticDimension
        view.contentInset = UIEdgeInsets.init(top: 0, left: 0, bottom: 20, right: 0)
        return view
    }()
    
    var popMenu: SwiftPopMenu?
    
    /// 消息回复框，回复时显示出来
    lazy var replyBar: WChatReplyBar = {
        let bar = WChatReplyBar()
        bar.closeButton.addActionBlock { [weak self] _ in
            // 隐藏回复bar,改变floatButton位置
            UIView.animate(withDuration: 0.3) {
                bar.snp.updateConstraints { make in
                    make.top.equalTo(self!.toolBar.snp.top)
                }
            }
            self?.replyBar.titleLabel.text = ""
            self?.replyBar.contentLabel.text = ""
            self?.replyBar.msg = nil
        }
        return bar
    }()

    override open func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            tableView.backgroundColor = UIColor.secondarySystemBackground
        } else {
            // Fallback on earlier versions
        }

        xToken = UserDefaults.standard.string(forKey: PARAM_XTOKEN) ?? ""

        initSDK(baseUrl: domain)
        initView()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame(node:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)

        let leftBarItem = UIBarButtonItem(title: "", style: .done, target: self, action: nil)
        navigationItem.leftBarButtonItem = leftBarItem

        let rightBarItem = UIBarButtonItem(title: "退出", style: .done, target: self, action: #selector(goBack))
        navigationItem.rightBarButtonItem = rightBarItem
        
        //delayExecution(seconds: 5) { //会导致退出页面后仍然开启chatSDK!
            print("开始定时检查")
            self.startTimer()
        //}
    }

    @objc func closeClick() {
        getUnSendMsg()
        quitChat()
        dismiss(animated: true)
    }

    @objc func goBack() {
        quitChat()
        navigationController?.popToRootViewController(animated: true)
    }

    func initView() {
        view.addSubview(toolBar)
        toolBar.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-kDeviceBottom)
        }
//        if #available(iOS 13.0, *) {
//            toolBar.backgroundColor = UIColor.label
//        } else {
//            // Fallback on earlier versions
//        }

        view.addSubview(headerView)
        headerView.snp.makeConstraints { make in
            make.width.equalTo(kScreenWidth)
            make.height.equalTo(50)
            make.left.equalToSuperview()
            make.top.equalToSuperview().offset(kDeviceTop)
        }
        
        view.addSubview(systemMsgLabel)
        systemMsgLabel.snp.makeConstraints { make in
            make.width.equalTo(kScreenWidth)
            make.left.equalToSuperview()
            make.height.equalTo(30)
            make.bottom.equalTo(self.toolBar.snp.top)
        }
        if #available(iOS 13.0, *) {
            systemMsgLabel.backgroundColor = UIColor.secondarySystemBackground
        } else {
            // Fallback on earlier versions
        }
        systemMsgLabel.text = ""
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(self.headerView.snp.bottom)
            make.bottom.equalTo(systemMsgLabel.snp.top)
        }

        headerView.addSubview(headerImg)
        headerImg.snp.makeConstraints { make in
            make.width.height.equalTo(50)
            make.left.equalToSuperview().offset(12)
            make.top.equalToSuperview().offset(5)
        }
        headerImg.isHidden = true
        
        headerView.addSubview(headerTitle)
        headerTitle.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.centerX.equalToSuperview()
            make.width.equalTo(260)
        }
        headerTitle.textAlignment = .center
        
        headerView.addSubview(headerClose)
        headerClose.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.centerY.equalToSuperview()
        }

        
        toolBar.textView.placeholder = "请输入想咨询的问题"
        headerTitle.text = "连接客服中..."
        
        if #available(iOS 13.0, *) {
            view.backgroundColor = UIColor.secondarySystemBackground
            setStatusBar(backgroundColor: UIColor.tertiarySystemBackground)
        } else {
            // Fallback on earlier versions
        }
        
        //addShadowToTableView()
    }

    func appendDataSource(msg: CommonMessage, isLeft: Bool, payLoadId: UInt64 = 0, status: MessageSendState = .发送中, cellType: CellType = .TYPE_Text, replayQuote: String? = nil) {
        let model = ChatModel()
        model.isLeft = isLeft
        model.cellType = cellType
        model.message = msg
        model.payLoadId = payLoadId
        if !isLeft {
            model.sendStatus = status
        }
        if let replayQuote = replayQuote{
            model.replayQuote = replayQuote
        }
        datasouceArray.append(model)
        tableView.reloadData()
        print("tableView.reloadData()")
        scrollToBottom()
    }
    
    func buildHistory(history: HistoryModel){
        //guard let historyList = history.list?.reversed() else { return } //获取自动回复后return
        datasouceArray.removeAll()
        if let historyList = history.list?.reversed(){
            print("获取历史记录")
            
             let replyList = history.replyList
          
            for item in historyList {
                var isLeft = true
                if (item.sender == item.chatId){
                    isLeft = false
                }
                
                if item.msgOp == "MSG_OP_DELETE"{
                    continue
                }
                
                let msgId = Int64(item.msgId ?? "0") ?? 0
                
                let chatModel = ChatModel()
                chatModel.isLeft = isLeft
                chatModel.sendStatus = .发送成功
               
               
                let replyMsgId = Int64(item.replyMsgId ?? "0") ?? 0
                
                if replyMsgId > 0{
                    let replyText = item.content?.data ?? "no txt"
                    var replayQuote = ""
                    let oriMsg = replyList?.first(where: { Message in
                        Int64(Message.msgId ?? "0") ?? 0 == replyMsgId
                    })
                    
                    if oriMsg != nil{
                        if oriMsg?.msgFmt == "MSG_TEXT"{
                            replayQuote = "\(oriMsg!.content?.data ?? "")"
                        }else if(oriMsg?.msgFmt == "MSG_IMG"){
                            replayQuote = "[图片]"
                        }else if(oriMsg?.msgFmt == "MSG_VIDEO"){
                            replayQuote = "[视频]"
                        }
                    }
                    chatModel.message = composeALocalTxtMessage(textMsg: replyText, timeInS: item.msgTime, msgId: msgId)
                    chatModel.replayQuote = replayQuote
                    datasouceArray.append(chatModel)
                }
                else if item.workerChanged != nil{
                    chatModel.cellType = .TYPE_Tip
                    chatModel.message = composeALocalTxtMessage(textMsg: item.workerChanged?.greeting ?? "no greeting", timeInS: item.msgTime, msgId: msgId)
                    datasouceArray.append(chatModel)
                }
                else if item.msgFmt == "MSG_TEXT"{
                    chatModel.message = composeALocalTxtMessage(textMsg: item.content?.data ?? "no txt", timeInS: item.msgTime, msgId: msgId)
                    datasouceArray.append(chatModel)
                }else if item.msgFmt == "MSG_IMG"{
                    chatModel.cellType = .TYPE_Image
                    //print(item.image?.uri ?? "")
                    chatModel.message = composeALocalImgMessage(url: item.image?.uri ?? "", timeInS: item.msgTime, msgId: msgId)
                    datasouceArray.append(chatModel)
                }else if item.msgFmt == "MSG_VIDEO"{
                    chatModel.cellType = .TYPE_VIDEO
                    chatModel.message = composeALocalVideoMessage(url: item.video?.uri ?? "", timeInS: item.msgTime, msgId: msgId)
                    datasouceArray.append(chatModel)
                }
            }
        }
        
        if isFirstLoad{
            //打招呼
            let greetingMsg = lib.composeALocalMessage(textMsg: "您好，\(workerName)为您服务！")
            appendDataSource(msg: greetingMsg, isLeft: true)
            print("第一次打招呼")
            
            //自动回复的Cell
            let chatModel = ChatModel()
            chatModel.isLeft = true
            chatModel.message = composeALocalTxtMessage(textMsg:  "no txt")
            chatModel.sendStatus = .发送成功
            chatModel.cellType = .TYPE_QA
            datasouceArray.append(chatModel)
            isFirstLoad = false
            //systemMsgLabel.text = "您好，\(workerName)为您服务！"
        }else{
            //服务器会自动生成这个，所以不用
            /*let greetingMsg = lib.composeALocalMessage(textMsg: "您好，\(workerName)为您服务！")
            appendDataSource(msg: greetingMsg, isLeft: true, cellType: .TYPE_Tip)
            print("打Tip招呼")
             */
        }
        
        tableView.reloadData()
        scrollToBottom()
    }

    func updateWorker(workerName:String, avatar: String){
        self.workerName = workerName
        self.headerTitle.text = "客服\(workerName)"
        print("baseUrlImage:" + baseUrlImage)
        let url = baseUrlImage + avatar
        print("avatar:" + url)
        //self.headerImg.kf.setImage(with: URL(string: url))
        avatarPath = avatar
        
        /*if isFirstLoad{
            self.systemMsgLabel.text = ""
        }else{*/
            self.systemMsgLabel.text = "您好：\(workerName)为您服务！"
        delayExecution(seconds: 5, completion: {
            self.systemMsgLabel.text = ""
        })
        //}
    }
    
    func sendMsg(textMsg: String) {
        print("sendMsg:\(textMsg)")
        if replyBar.superview != nil && replyBar.msg != nil{
            if let msg = replyBar.msg{
                if !msg.image.uri.isEmpty{
                    lib.sendMessage(msg: textMsg, type: .msgText, consultId: consultId, replyMsgId: replyBar.msg?.msgID ?? 0)
                }else if !msg.video.uri.isEmpty{
                    lib.sendMessage(msg: textMsg , type: .msgText, consultId: consultId, replyMsgId: replyBar.msg?.msgID ?? 0) //+ "\n 回复：视频"
                }else{
                    lib.sendMessage(msg: textMsg, type: .msgText, consultId: consultId, replyMsgId: replyBar.msg?.msgID ?? 0)
                }
            }
            //replyBar.removeFromSuperview()
            replyBar.snp.updateConstraints { make in
                make.top.equalTo(self.toolBar.snp.top)
            }
            replyBar.msg = nil
        }else{
            lib.sendMessage(msg: textMsg, type: .msgText, consultId: consultId)
        }
        if let cMsg = lib.sendingMsg {
            appendDataSource(msg: cMsg, isLeft: false, payLoadId: lib.payloadId)
        }
    }

    func sendImage(url: String) {
        // lib.sendMessageImage(url: "https://www.bing.com/th?id=OHR.SunriseCastle_ROW9509100997_1920x1080.jpg&rf=LaDigue_1920x1080.jpg")
        lib.sendMessage(msg: url, type: .msgImg, consultId: consultId)
        if let cMsg = lib.sendingMsg {
            appendDataSource(msg: cMsg, isLeft: false, payLoadId: lib.payloadId, cellType: .TYPE_Image)
        }
    }
    
    func sendVideo(url: String) {
        lib.sendMessage(msg: url, type: .msgVideo, consultId: consultId)
        if let cMsg = lib.sendingMsg {
            appendDataSource(msg: cMsg, isLeft: false, payLoadId: lib.payloadId, cellType: .TYPE_VIDEO)
        }
    }
    
    //检查聊天SDK的连接状态
   @objc func checkSDK(){
       print("sdk status:\(isConnected) \(Date())")
       if !isConnected{
           initSDK(baseUrl: domain)
       }
    }

    //定时检查SDK连接状态
    @objc func startTimer() {
        if myTimer != nil{
            return
        }
        
        self.myTimer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(self.checkSDK), userInfo: nil, repeats: true)
        delayExecution(seconds: 10) {
            print("KeFu计时器开始")
            self.myTimer?.fire()
        }
    }

    //停止定时检查
    func stopTimer() {
        //if myTimer != nil {
        myTimer?.invalidate() // 销毁timer
        myTimer = nil
            print("KeFu计时器销毁")
        //}
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        if !isFirstLoad && !(myTimer?.isValid ?? false){
            delayExecution(seconds: 2) {
                print("页面恢复，检查SDK")
                self.checkSDK()
            }
        }
    }
    
    //关闭聊天页面之前，与SDK断开聊天
    func quitChat(){
        stopTimer()
        workerId = 0
        isConnected = false
        lib.disConnect()
        lib.delegate = nil
        print("已退出聊天")
    }
    
    /**
     * 上传图片。上传成功后，会直接调用socket进行消息发送。
     *  @param filePath
     *  // 文件类型类型 0 ～ 4
     * enum AssetKind {
     *   ASSET_KIND_NONE = 0;
     *   // 商户公共文件
     *   ASSET_KIND_PUBLIC = 1;
     *   // 商户私有文件
     *   ASSET_KIND_PRIVATE = 2;
     *   // 头像
     *   ASSET_KIND_AVATAR = 3;
     *   // 会话私有文件
     *   ASSET_KIND_SESSION = 4;
     * }
     */
    //上传媒体文件
    func upload(imgData: Data, isVideo: Bool) {
        WWProgressHUD.showLoading("正在上传...")
        // Set Your URL
        let api_url = baseUrlApi + "/v1/assets/upload-v3"
        guard let url = URL(string: api_url) else {
            return
        }
        
        var urlRequest = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 10.0 * 1000)
        urlRequest.httpMethod = "POST"
        // urlRequest.addValue("application/json", forHTTPHeaderField: "Accept")
        //let boundary = "Boundary-\(UUID().uuidString)"
        //let contentType = "multipart/form-data; " + boundary
        
        //urlRequest.addValue(contentType, forHTTPHeaderField: "Content-Type")
        urlRequest.addValue("multipart/form-data", forHTTPHeaderField: "Accept")
        urlRequest.httpBody = imgData
        
        urlRequest.addValue(xToken, forHTTPHeaderField: "X-Token")
        
        // Set Your Parameter
        let parameterDict = NSMutableDictionary()
        parameterDict.setValue(4, forKey: "type")
        // parameterDict.setValue("phot.png", forKey: "myFile")
        
        // Now Execute
        AF.upload(multipartFormData: { multiPart in
            for (key, value) in parameterDict {
                if let temp = value as? String {
                    multiPart.append(temp.data(using: .utf8)!, withName: key as! String)
                }
                if let temp = value as? Int {
                    multiPart.append("\(temp)".data(using: .utf8)!, withName: key as! String)
                }
            }
            if (isVideo) {
                multiPart.append(imgData, withName: "myFile", fileName:  "\(Date().milliStamp)file.mp4", mimeType: "video/mp4")
            } else {
                multiPart.append(imgData, withName: "myFile", fileName: "\(Date().milliStamp)file.png", mimeType: "image/png")
            }
        }, with: urlRequest)
        .uploadProgress(queue: .main, closure: { progress in
            // Current upload progress of file
            print("Upload Progress: \(progress.fractionCompleted)")
        })
        .response(completionHandler: { data in
            WWProgressHUD.dismiss()
            switch data.result {
            case .success:
                if let resData = data.data {
                    let path = String(data: resData, encoding: String.Encoding.utf8)
                    #if DEBUG
                    print(path ?? "")
                    #endif
                    let myResult = try? JSONDecoder().decode(UploadResult.self, from: resData)
                    
                    if myResult == nil {
                        WWProgressHUD.showFailure("数据返回不对，解析失败！")
                        return
                    }
                    
                    if myResult?.code != 200 && myResult?.code != 0 {
                        WWProgressHUD.showFailure(myResult?.message)
                        return
                    }
                    
                    print(myResult?.data?.filepath ?? "filePath is null")

                    /*if filePath.contains(".png") || filePath.contains(".tiff") || filePath.contains(".gif") || filePath.contains(".tif") || filePath.contains(".jpg") || filePath.contains(".jpeg"){
                        self.sendImage(url: path ?? "")
                    }else{
                        self.sendVideo(url: path ?? "")
                    }*/
                    
                    if !isVideo{
                        self.sendImage(url: myResult?.data?.filepath ?? "")
                    }else{
                        self.sendVideo(url: myResult?.data?.filepath ?? "")
                    }
                } else {
                    print("图片上传失败：")
                    WWProgressHUD.showFailure("上传失败！")
                }
            case .failure(let error):
                WWProgressHUD.showFailure("上传失败！")
                print("图片上传失败：" + error.localizedDescription)
            }
        })
        
    }

    @objc func keyboardWillChangeFrame(node: Notification) {
        // 1.获取动画执行的时间
        let duration = node.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as! TimeInterval

        // 2.获取键盘最终 Y值
        let endFrame = (node.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let y = endFrame.origin.y

        // 3计算工具栏距离底部的间距
        let margin = UIScreen.main.bounds.height - y

        // 4.执行动画
        UIView.animate(withDuration: duration) { [weak self] in
            self?.toolBar.snp.updateConstraints { make in
                if margin == 0 {
                    make.bottom.equalToSuperview().offset(-kDeviceBottom)
                } else {
                    make.bottom.equalToSuperview().offset(-margin)
                }
            }
            self?.view.layoutIfNeeded()
        }
    }
    
    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func setStatusBar(backgroundColor: UIColor) {
        let statusBarFrame: CGRect
        if #available(iOS 13.0, *) {
            //statusBarFrame = view.window?.windowScene?.statusBarManager?.statusBarFrame ?? CGRect.zero
            statusBarFrame = CGRectMake(0, 0, kScreenWidth, kDeviceTop)
        } else {
            statusBarFrame = UIApplication.shared.statusBarFrame
        }
        let statusBarView = UIView(frame: statusBarFrame)
        statusBarView.backgroundColor = backgroundColor
        view.addSubview(statusBarView)
    }
}
