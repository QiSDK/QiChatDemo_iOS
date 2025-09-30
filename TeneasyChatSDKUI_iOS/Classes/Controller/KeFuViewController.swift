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
import MobileCoreServices
    


//客服聊天页面
open class KeFuViewController: UIViewController, UploadListener{
    
    // MARK: - 属性
    
    /// 消息数据源
    var datasouceArray: [ChatModel] = []
    
    /// 咨询类型ID
    var consultId: Int64 = 0
    
    /// 聊天SDK实例
    //private(set) var lib: ChatLib = ChatLib.shared
    
    /// 连接状态标记
   var isConnected: Bool = false
    
    /// 首次加载标记
   var isFirstLoad: Bool = true
    
    /// 客服信息
   var workerName: String = ""
   var avatarPath: String = ""
   
    //自动回复消息区域的高度，根据自动回复列表的高度动态调整
    var questionViewHeight: Double = 0
    
    var currentQAIndexPath: IndexPath?
    
    var withAutoReply: CommonWithAutoReply? = nil
    var downloadFile: String? = nil
    
    /// 弱引用持有的定时器
    /// 一个定时器，每隔几秒检查连接状态，如果状态不是在连接状态，就重新连接
      private weak var myTimer: Timer?
      
      /// 消息处理队列
      private lazy var messageQueue: DispatchQueue = {
          return DispatchQueue(label: "com.teneasy.chat.messageQueue")
      }()

    //当前选择的图片
    var chooseImg: UIImage?
    lazy var imagePickerController: UIImagePickerController = {
        let pick = UIImagePickerController()
        pick.delegate = self
        return pick
    }()
    
    var documentPicker = UIDocumentPickerViewController(documentTypes: [String(kUTTypeData)], in: .open)
    

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
        view.estimatedRowHeight = 60
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

        // 使用全局ChatLib管理连接
        initSDK(baseUrl: domain)
        if (chatLib.isConnected){
            self.assignWorker()
        }
        initView()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame(node:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)

        let leftBarItem = UIBarButtonItem(title: "", style: .done, target: self, action: nil)
        navigationItem.leftBarButtonItem = leftBarItem

        let rightBarItem = UIBarButtonItem(title: "退出", style: .done, target: self, action: #selector(goBack))
        navigationItem.rightBarButtonItem = rightBarItem
        
        // 全局ChatLib已经在GlobalChatManager中管理，不需要局部监控
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
    
    /// 标记消息为已读的通用方法
    private func markMessagesAsRead() {
        NetworkUtil.markRead(consultId: Int32(consultId)) { [weak self] success, data in
            guard let self = self else { return }
            if success {
                print("消息已标记为已读")
                // 清除本地未读数并通知UI更新
                GlobalMessageManager.shared.clearUnReadCount(consultId: self.consultId)
            } else {
                print("标记已读失败")
            }
        }
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

    func appendDataSource(msg: CommonMessage, isLeft: Bool, payLoadId: UInt64 = 0, status: MessageSendState = .发送中, cellType: CellType = .TYPE_Text, replayQuote: ReplyMessageItem? = nil) {
     
        
        // 使用消息队列确保线程安全
               messageQueue.async { [weak self] in
                   guard let self = self else { return }
                   
                   let model = ChatModel()
                   model.isLeft = isLeft
                   model.cellType = cellType
                   model.message = msg
                   model.payLoadId = payLoadId
                   if !isLeft {
                       model.sendStatus = status
                   }
                   if let replayQuote = replayQuote{
                       model.replyItem = replayQuote
                   }
                   
                   self.datasouceArray.append(model)
                   
                   // 在主线程更新UI
                   DispatchQueue.main.async {
                       self.tableView.reloadData()
                       print("tableView.reloadData()")
                       self.scrollToBottom()
                   }
               }
    }
    
    func buildHistory(history: HistoryModel){
        //guard let historyList = history.list?.reversed() else { return } //获取自动回复后return
        datasouceArray.removeAll()
        chatId = history.request?.chatId ?? "0"
        if let historyList = history.list?.reversed(){
            print("获取历史记录")
                
             let replyList = history.replyList
          
            for item in historyList {
                
                var isLeft = true
                if (item.sender == item.chatId || item.msgSourceType == "MST_SYSTEM_WORKER"){
                    isLeft = false
                }
                
                if (item.msgSourceType == "MST_SYSTEM_CUSTOMER"){
                    isLeft = true
                }
                
                if item.msgOp == "MSG_OP_DELETE"{
                    continue
                }
                
                let msgId = Int64(item.msgId ?? "0") ?? 0
                
                let chatModel = ChatModel()
                chatModel.isLeft = isLeft
                chatModel.sendStatus = .发送成功
               
               
                let replyMsgId = Int64(item.replyMsgId ?? "0") ?? 0
                let oriMsg = replyList?.first(where: { Message in
                    Int64(Message.msgId ?? "0") ?? 0 == replyMsgId
                   
                })
                
                if item.workerChanged != nil{
                    chatModel.cellType = .TYPE_Tip
                    chatModel.message = composeALocalTxtMessage(textMsg: item.workerChanged?.greeting ?? "no greeting", timeInS: item.msgTime, msgId: msgId)
                    datasouceArray.append(chatModel)
                }
                else if item.msgFmt == "MSG_FILE"{
                    chatModel.cellType = .TYPE_File
                    chatModel.message = composeALocalFileMessage(url: item.file?.uri ?? "unknown_default", timeInS: item.msgTime, msgId: msgId, replyMsgId: replyMsgId, fileSize: item.file?.size ?? 0, fileName: item.file?.fileName ?? "")
                    datasouceArray.append(chatModel)
                    
                    if replyMsgId > 0{
                        chatModel.replyItem = getReplyItem(oriMsg: oriMsg)
                    }
                }
                else if item.msgFmt == "MSG_TEXT"{
                    chatModel.cellType = .TYPE_Text
                    
                    chatModel.message = composeALocalTxtMessage(textMsg: item.content?.data ?? "no txt", timeInS: item.msgTime, msgId: msgId, replyMsgId: replyMsgId)
                    
                    if ((item.content?.data ?? "").contains("\"imgs\"")){
                        chatModel.cellType = .TYPE_TEXT_IMAGES
                    }
                                                     
                    datasouceArray.append(chatModel)
                    
                    if replyMsgId > 0{
                        chatModel.replyItem = getReplyItem(oriMsg: oriMsg)
                    }
                }else if item.msgFmt == "MSG_IMG"{
                    chatModel.cellType = .TYPE_Image
                    //print(item.image?.uri ?? "")
                    chatModel.message = composeALocalImgMessage(url: item.image?.uri ?? "", timeInS: item.msgTime, msgId: msgId, replyMsgId: replyMsgId)
                    datasouceArray.append(chatModel)
                    
                    if replyMsgId > 0{
                        chatModel.replyItem = getReplyItem(oriMsg: oriMsg)
                    }
                }else if item.msgFmt == "MSG_VIDEO"{
                    chatModel.cellType = .TYPE_VIDEO
                    chatModel.message = composeALocalVideoMessage(url:  item.video?.uri ?? "", thumb: item.video?.thumbnailUri ?? "", hls: item.video?.hlsUri ?? "", timeInS: item.msgTime, msgId: msgId, replyMsgId: replyMsgId)
                    datasouceArray.append(chatModel)
                    
                    if replyMsgId > 0{
                        chatModel.replyItem = getReplyItem(oriMsg: oriMsg)
                    }
                }
            }
        }
        
        if isFirstLoad{
            //打招呼
            let greetingMsg = chatLib.composeALocalMessage(textMsg: "您好，\(workerName)为您服务！")
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
    
    func getReplyItem(oriMsg: Message?) -> ReplyMessageItem{
        let replyItem = ReplyMessageItem()
        if (oriMsg?.msgFmt == "MSG_TEXT"){
            var text = oriMsg?.content?.data ?? ""
            let result = TextImages.deserialize(from: text)
            text = result?.message ?? ""
            replyItem.content = text
        }
        else if (oriMsg?.msgFmt == "MSG_IMG"){
            replyItem.fileName = oriMsg?.image?.uri ?? ""
        }else if (oriMsg?.msgFmt == "MSG_VIDEO"){
            replyItem.fileName =  oriMsg?.video?.uri ?? ""
            
            if (!(oriMsg?.video?.hlsUri ?? "").isEmpty){
                replyItem.fileName =  oriMsg?.video?.hlsUri ?? ""
            }
        }else if (oriMsg?.msgFmt == "MSG_FILE"){
            replyItem.size = oriMsg?.file?.size ?? 0
            replyItem.fileName = oriMsg?.file?.uri ?? ""
        }
        return replyItem
    }
    
    func getReplyItem(oriMsg: CommonMessage?) -> ReplyMessageItem{
       let replyItem = ReplyMessageItem()
       if (oriMsg?.msgFmt == CommonMessageFormat.msgText){
           var text = oriMsg?.content.data ?? ""
           let result = TextImages.deserialize(from: text)
           text = result?.message ?? ""
           replyItem.content = text
       }
       else if (oriMsg?.msgFmt == CommonMessageFormat.msgImg){
           replyItem.fileName = oriMsg?.image.uri ?? ""
       }else if (oriMsg?.msgFmt == CommonMessageFormat.msgVideo){
           replyItem.fileName =  oriMsg?.video.uri ?? ""
           
           if (!(oriMsg?.video.hlsUri ?? "").isEmpty){
               replyItem.fileName =  oriMsg?.video.hlsUri ?? ""
           }
       }else if (oriMsg?.msgFmt == CommonMessageFormat.msgFile){
           replyItem.size = oriMsg?.file.size ?? 0
           replyItem.fileName = oriMsg?.file.uri ?? ""
       }
       return replyItem
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
        if textMsg.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty{
            WWProgressHUD.showInfoMsg("消息不能为空")
            return
        }
        chatLib.sendMessage(msg: textMsg, type: .msgText, consultId: consultId, replyMsgId: replyBar.msg?.msgID ?? 0, withAutoReply: self.withAutoReply)
        
        if replyBar.superview != nil && replyBar.msg != nil{
            replyBar.snp.updateConstraints { make in
                make.top.equalTo(self.toolBar.snp.top)
            }
            replyBar.msg = nil
        }
        if let cMsg = chatLib.sendingMsg {
            appendDataSource(msg: cMsg, isLeft: false, payLoadId: chatLib.payloadId)
        }
    }

    func sendImage(url: String) {
        chatLib.sendMessage(msg: url, type: .msgImg, consultId: consultId, withAutoReply: self.withAutoReply)
        if let cMsg = chatLib.sendingMsg {
            appendDataSource(msg: cMsg, isLeft: false, payLoadId: chatLib.payloadId, cellType: .TYPE_Image)
        }
    }
    
    func sendVideoMessage(url: String, thumb: String, hls: String) {
        chatLib.sendVideoMessage(url: url, thumbnailUri: thumb, hlsUri: hls, consultId: consultId, withAutoReply: self.withAutoReply)
        if let cMsg = chatLib.sendingMsg {
            appendDataSource(msg: cMsg, isLeft: false, payLoadId: chatLib.payloadId, cellType: .TYPE_VIDEO)
        }
    }
    
    // checkSDK方法已移除，全局ChatLib自动管理连接状态
    // 上传进度更新逻辑保留
    @objc func updateUploadProgressIfNeeded(){
       //上传视频的时候，在这里更新上传进度，对接开发人员可以有自己的办法，和聊天sdk无关。
       if (uploadProgress > 0 && (uploadProgress < 67 || uploadProgress >= 70) && uploadProgress < 96){
           uploadProgress += 5
           updateProgress(progress: uploadProgress)
       }
    }

    //停止定时器
    func stopLocalTimer() {
        //if myTimer != nil {
        myTimer?.invalidate() // 销毁timer
        myTimer = nil
            print("KeFu页面计时器销毁")
        //}
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        currentChatConsultId = consultId
        GlobalMessageManager.shared.clearUnReadCount(consultId: consultId)
        
        // 全局ChatLib自动管理连接，不需要局部检查
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        currentChatConsultId = 0
        
        // 离开聊天页面时标记消息为已读
//        NetworkUtil.markRead(consultId: Int32(consultId)) { [weak self] success, data in
//            guard let self = self else { return }
//            if success {
//                print("离开聊天页面，消息已标记为已读")
//                // 清除本地未读数并通知UI更新
//                GlobalMessageManager.shared.clearUnReadCount(consultId: self.consultId)
//            } else {
//                print("标记已读失败")
//            }
//        }
        
        self.markMessagesAsRead()
        
        //离开聊天页面，如果有错误日志，上报日志。
        NetworkUtil.doReportError()
    }
    
    deinit {
        // 移除通知监听
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - 聊天SDK管理
    
    /// 退出聊天（清理资源）
    func quitChat() {
        stopLocalTimer()
        //workerId = 0
        // 关闭前标记消息为已读
        markMessagesAsRead()
        // 不断开ChatLib连接，因为它是全局管理的
        // chatLib.disConnect()  
        // chatLib.delegate = nil
        print("已退出聊天页面，ChatLib保持全局连接")
    }
    
//    deinit {
//        quitChat()
//        print("deinit")
//    }
    
    
    // MARK: - 定时器管理（仅用于上传进度）
        
    /// 开启上传进度监控
    @objc private func startUploadProgressMonitoring() {
        guard myTimer == nil else { return }
        let timer = Timer.scheduledTimer(
            timeInterval: 5,
            target: self,
            selector: #selector(self.updateUploadProgressIfNeeded),
            userInfo: nil,
            repeats: true
        )
        myTimer = timer
    }
    
    //上传媒体文件
    func upload(imgData: Data, isVideo: Bool, filePath: String, size: Int32 = 0) {
        WWProgressHUD.showLoading("正在上传...")
        startUploadProgressMonitoring()
        UploadUtil(listener: self, filePath: filePath, fileData: imgData, xToken: xToken, baseUrl: getbaseApiUrl()).upload()
    }
    
    public func uploadSuccess(paths: Urls, filePath: String, size: Int) {
        uploadProgress = 0
         let ext = paths.uri?.split(separator: ".").last?.lowercased() ?? "#"
         if imageTypes.contains(ext){
             self.sendImage(url: paths.uri ?? "")
         }else if videoTypes.contains(ext){
             self.sendVideoMessage(url: paths.uri ?? "", thumb: paths.thumbnailUri, hls: paths.hlsUri ?? "")
         }else{
             chatLib.sendMessage(msg: paths.uri ?? "", type: .msgFile, consultId: consultId, withAutoReply: self.withAutoReply, fileSize: Int32(size), fileName: filePath)
             if let cMsg = chatLib.sendingMsg {
                 appendDataSource(msg: cMsg, isLeft: false, payLoadId: chatLib.payloadId, cellType: .TYPE_File)
             }
         }
         print("上传进度：100% \(Date())")
         WWProgressHUD.dismiss()
        stopLocalTimer()
    }
   
    public func updateProgress(progress: Int) {
        WWProgressHUD.showLoading("上传进度：\(progress)%")
        print("上传进度：\(progress)% \(Date())")
    }
    
    public func uploadFailed(msg: String) {
        WWProgressHUD.showFailure(msg)
        uploadProgress = 0
        stopLocalTimer()
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
