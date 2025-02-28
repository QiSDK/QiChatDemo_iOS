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
// import TeneasyChatSDKUI_iOS
import UIKit

open class KeFuViewController: UIViewController{

    lazy var imagePickerController: UIImagePickerController = {
        let pick = UIImagePickerController()
        pick.delegate = self
        return pick
    }()

    lazy var headerView: UIView = {
        let v = UIView(frame: CGRect.zero)
        v.backgroundColor = .white
        return v
    }()

    lazy var systemInfoView: UIView = {
        let v = UIView(frame: CGRect.zero)
        return v
    }()

    lazy var timeLabel: UILabel = {
        let label = UILabel(frame: CGRect.zero)
        label.textAlignment = .center
        label.textColor = .gray
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()

    lazy var systemMsgLabel: UILabel = {
        let label = UILabel(frame: CGRect.zero)
        label.textAlignment = .center
        label.textColor = .gray
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

    lazy var headerClose: UIButton = {
        let btn = UIButton(frame: CGRect.zero)
        btn.setImage(UIImage.svgInit("close", size: CGSize(width: 20, height: 20)), for: UIControl.State.normal)
        btn.addTarget(self, action: #selector(closeClick), for: UIControl.Event.touchUpInside)
        return btn
    }()

    lazy var headerTitle: UILabel = {
        let v = UILabel(frame: CGRect.zero)
        v.text = "--"
        return v
    }()

    /// 输入框工具栏
    lazy var toolBar: BWKeFuChatToolBar = {
        let toolBar = BWKeFuChatToolBar()
        toolBar.delegate = self
        return toolBar
    }()

    lazy var tableView: UITableView = {
        let view = UITableView()
        view.delegate = self
        view.dataSource = self
        view.backgroundColor = .groupTableViewBackground
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
            // 回复的Model置空
//            self?.viewModel.replyOriginChatModel = nil
            // 隐藏回复bar,改变floatButton位置
            UIView.animate(withDuration: 0.3) {
                bar.snp.updateConstraints { make in
                    make.top.equalTo(self!.toolBar.snp.top)
                }
//                self?.floatButton.snp.updateConstraints { make in
//                    make.bottom.equalTo(self!.toolBar.snp.top).offset(0)
//                }
            }
        }
        return bar
    }()

    var questionViewHeight: Double = 0

    var datasouceArray: [ChatModel] = []
    var retryTimes = 0
    var consultId: Int64 = 0
    var lib = ChatLib()
    var chooseImg: UIImage?
    internal var isFirstLoad = true
    var isConnected: Bool = false
    //static var sharedData: String = "Initial Value"
    private var myTimer: Timer?

    override open func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = kBgColor

        xToken = UserDefaults.standard.string(forKey: PARAM_XTOKEN) ?? ""

        initSDK(baseUrl: domain)
        initView()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame(node:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)

        let leftBarItem = UIBarButtonItem(title: "", style: .done, target: self, action: nil)
        navigationItem.leftBarButtonItem = leftBarItem
        // self.navigationItem.setHidesBackButton(true, animated: false)
//
        let rightBarItem = UIBarButtonItem(title: "退出", style: .done, target: self, action: #selector(goBack))
        navigationItem.rightBarButtonItem = rightBarItem
    }

    @objc func closeClick() {
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

        view.addSubview(headerView)
        headerView.snp.makeConstraints { make in
            make.width.equalTo(kScreenWidth)
            make.height.equalTo(60)
            make.left.equalToSuperview()
            make.top.equalToSuperview().offset(kDeviceTop)
        }
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(self.headerView.snp.bottom)
            make.bottom.equalTo(toolBar.snp.top).offset(-10)
        }

        headerView.addSubview(headerImg)
        headerImg.snp.makeConstraints { make in
            make.width.height.equalTo(50)
            make.left.equalToSuperview().offset(12)
            make.top.equalToSuperview().offset(5)
        }
        headerView.addSubview(headerTitle)
        headerTitle.snp.makeConstraints { make in
            make.centerY.equalTo(self.headerImg.snp.centerY)
            make.left.equalTo(self.headerImg.snp.right).offset(12)
        }
        headerView.addSubview(headerClose)
        headerClose.snp.makeConstraints { make in
            make.centerY.equalTo(self.headerImg.snp.centerY)
            make.right.equalToSuperview().offset(-16)
        }
        tableView.tableHeaderView = systemInfoView

        systemInfoView.addSubview(timeLabel)
        systemInfoView.snp.makeConstraints { make in
            make.width.equalTo(kScreenWidth - 24)
            make.leading.equalTo(12)
            make.top.equalToSuperview().offset(12)
        }
        timeLabel.snp.makeConstraints { make in
            make.width.equalTo(kScreenWidth)
            make.left.equalToSuperview()
            make.top.equalToSuperview().offset(6)
        }
        systemInfoView.addSubview(systemMsgLabel)
        systemMsgLabel.snp.makeConstraints { make in
            make.width.equalTo(kScreenWidth)
            make.left.equalToSuperview()
            make.top.equalTo(self.timeLabel.snp.bottom)
        }

        toolBar.textView.placeholder = "请输入想咨询的问题"
        headerTitle.text = "连接客服中..."
    }

    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func appendDataSource(msg: CommonMessage, isLeft: Bool, payLoadId: UInt64 = 0, status: MessageSendState = .发送中, cellType: CellType = .TYPE_Text) {
        let model = ChatModel()
        model.isLeft = isLeft
        model.cellType = cellType
        model.message = msg
        model.payLoadId = payLoadId
        if !isLeft {
            model.sendStatus = status
        }
        datasouceArray.append(model)
        tableView.reloadData()
        scrollToBottom()
    }

   /* public func showTipMsg(msg: String) {
        print("systemMsg")
        print(msg)
        timeLabel.text = WTimeConvertUtil.displayLocalTime(from: Date())
        systemMsgLabel.text = msg
    }
*/
    
    func buildHistory(history: HistoryModel){
        guard let historyList = history.list?.reversed() else { return } //获取自动回复后return
        print("获取历史记录")
            for item in historyList {
                var isLeft = true
                if (item.sender == item.chatId){
                    isLeft = false
                }
                
                let chatModel = ChatModel()
                chatModel.isLeft = isLeft
                chatModel.sendStatus = .发送成功
                if item.workerChanged != nil{
                    chatModel.cellType = .TYPE_Tip
                    chatModel.message = composeALocalTxtMessage(textMsg: item.workerChanged?.greeting ?? "no greeting", timeInS: item.msgTime)
                    datasouceArray.append(chatModel)
                }
                else if item.msgFmt == "MSG_TEXT"{
                    chatModel.message = composeALocalTxtMessage(textMsg: item.content?.data ?? "no txt", timeInS: item.msgTime)
                    datasouceArray.append(chatModel)
                }else if item.msgFmt == "MSG_IMG"{
                    chatModel.message = composeALocalImgMessage(url: item.image?.uri ?? "", timeInS: item.msgTime)
                    datasouceArray.append(chatModel)
                }else if item.msgFmt == "MSG_VIDEO"{
                    chatModel.cellType = .TYPE_VIDEO
                    chatModel.message = composeALocalVideoMessage(url: item.video?.uri ?? "", timeInS: item.msgTime)
                    datasouceArray.append(chatModel)
                }
            }
        
        let chatModel = ChatModel()
        chatModel.isLeft = true
        chatModel.message = composeALocalTxtMessage(textMsg:  "no txt")
        chatModel.sendStatus = .发送成功
        chatModel.cellType = .TYPE_QA
        datasouceArray.append(chatModel)
        tableView.reloadData()
        scrollToBottom()
    }

    func updateWorker(workerName:String, avatar: String){
        self.headerTitle.text = "客服\(workerName)"
        print("baseUrlImage:" + baseUrlImage)
        let url = baseUrlImage + avatar
        print("avatar:" + url)
        self.headerImg.kf.setImage(with: URL(string: url))

        if isFirstLoad{
            isFirstLoad = false
            let greetingMsg = lib.composeALocalMessage(textMsg: "您好，\(workerName)为您服务！")
            appendDataSource(msg: greetingMsg, isLeft: true)
        }else{
            let greetingMsg = lib.composeALocalMessage(textMsg: "您好，\(workerName)为您服务！")
            appendDataSource(msg: greetingMsg, isLeft: true, cellType: .TYPE_Tip)
        }
    }
    
    func sendMsg(textMsg: String) {
        print("sendMsg:\(textMsg)")
        if replyBar.superview != nil{
            if let msg = replyBar.msg{
                lib.sendMessage(msg: textMsg + "\n回复：" + msg.content.data, type: .msgText, consultId: consultId, replyMsgId: msg.msgID)
            }
            replyBar.removeFromSuperview()
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
//                print(WTimeConvertUtil.displayLocalTime(from: Double(cMsg.msgTime.seconds)))
//                print(WTimeConvertUtil.displayLocalTime(from: cMsg.msgTime.date))
            appendDataSource(msg: cMsg, isLeft: false, payLoadId: lib.payloadId)
        }
    }
    
    func sendVideo(url: String) {
        lib.sendMessage(msg: url, type: .msgVideo, consultId: consultId)
        if let cMsg = lib.sendingMsg {
            appendDataSource(msg: cMsg, isLeft: false, payLoadId: lib.payloadId, cellType: .TYPE_VIDEO)
        }
    }
    
   @objc func checkSDK(){
       print("sdk status:\(isConnected)")
       if !isConnected{
           initSDK(baseUrl: domain)
       }
    }

    //定时检查SDK连接状态
    @objc func startTimer() {
       stopTimer()
        myTimer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(checkSDK), userInfo: nil, repeats: true)
        myTimer!.fire()
    }

    func stopTimer() {
        if myTimer != nil {
            myTimer!.invalidate() // 销毁timer
            myTimer = nil
        }
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        if isFirstLoad{
            delayExecution(seconds: 5) {
                print("开始定时检查")
                self.checkSDK()
            }
        }
    }
    
    func quitChat(){
        stopTimer()
        workerId = 0
        isConnected = false
        lib.disConnect()
        lib.delegate = nil
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
    
    func upload(imgData: Data, isVideo: Bool) {
        // Set Your URL
        let api_url = baseUrlApi + "/v1/assets/upload/"
        guard let url = URL(string: api_url) else {
            return
        }
        
        var urlRequest = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 10.0 * 1000)
        urlRequest.httpMethod = "POST"
        // urlRequest.addValue("application/json", forHTTPHeaderField: "Accept")
        let boundary = "Boundary-\(UUID().uuidString)"
        let contentType = "multipart/form-data; " + boundary
        
        urlRequest.addValue(contentType, forHTTPHeaderField: "Content-Type")
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
                multiPart.append(imgData, withName: "myFile", fileName: "file.mp4", mimeType: "video/mp4")
            } else {
                multiPart.append(imgData, withName: "myFile", fileName: "file.png", mimeType: "image/png")
            }
        }, with: urlRequest)
        .uploadProgress(queue: .main, closure: { progress in
            // Current upload progress of file
            print("Upload Progress: \(progress.fractionCompleted)")
        })
        .response(completionHandler: { data in
            switch data.result {
            case .success:
                
                if let filePath = data.data {
                    let path = String(data: filePath, encoding: String.Encoding.utf8)
                    //let imgUrl = baseUrlImage + (path ?? "")
                    let filePath = (path ?? "")
                    if filePath.contains(".png") || filePath.contains(".jpg"){
                        self.sendImage(url: path ?? "")
                    }else{
                        self.sendVideo(url: path ?? "")
                    }
                   
                    print(filePath)
                   
                } else {
                    print("图片上传失败：")
                }
                
            case .failure(let error):
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
}
