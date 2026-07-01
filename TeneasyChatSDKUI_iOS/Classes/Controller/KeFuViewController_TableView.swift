import TeneasyChatSDK_iOS
import XMMenuPopover

extension KeFuViewController: UITableViewDelegate, UITableViewDataSource {
    // MARK: - UITableViewDataSource
    
    // tableView(_:cellForRowAt:) -  用于创建和配置表格视图的单元格
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 获取当前行的聊天模型
        let model = datasouceArray[indexPath.row]
        
        // 根据模型确定单元格类型
        switch model.cellType {
        case .TYPE_Tip:
            // 创建提示单元格
            let cell = BWTipCell()
            cell.model = model
            return cell
            
        case .TYPE_File:
            // 创建文件单元格（根据消息方向显示在左侧或右侧）
            let cell: BWFileCell = model.isLeft ? BWFileLeftCell.cell(tableView: tableView) : BWFileRightCell.cell(tableView: tableView)
            cell.model = model
            cell.cellTapedGesture = { [weak self] in
                self?.cellTaped(model: model)
            }
            cell.longGestCallBack = { [weak self] gesure in
                if gesure.state == .began {
                    self?.showMenu(gesure, model: model, indexPath: indexPath)
                }
            }
            cell.showOriginalBack = { [weak self] in
                guard let replyItem = model.replyItem else { return }
                self?.showOriginal(model: replyItem)
            }
            if let leftCell = cell as? BWFileLeftCell {
                leftCell.displayIconImg(path: self.avatarPath)
            }
            (cell as? ChatThemable)?.applyTheme(self.theme)
            return cell
            
        case .TYPE_VIDEO, .TYPE_Image:
            // 创建图片/视频单元格（根据消息方向显示在左侧或右侧）
            let cell: BWImageCell = model.isLeft ? BWImageLeftCell.cell(tableView: tableView) : BWImageRightCell.cell(tableView: tableView)
            cell.model = model
            cell.longGestCallBack = { [weak self] gesure in
                if gesure.state == .began {
                    self?.showMenu(gesure, model: model, indexPath: indexPath)
                }
            }
            cell.playBlock = { [weak self] in
                self?.cellTaped(model: model)
            }
            
            if let imageCell = cell as? BWImageLeftCell {
                imageCell.displayIconImg(path: self.avatarPath)
            }
            
            let uri: String?
            if model.cellType == .TYPE_Image {
                cell.playBtn.isHidden = true
                uri = model.message?.image.uri
                cell.displayThumbnail(path: uri ?? "")
            } else if model.cellType == .TYPE_File {
                cell.playBtn.isHidden = true
                uri = model.message?.file.uri
                cell.displayFileThumbnail(path: uri ?? "")
            } else {
                uri = model.message?.video.thumbnailUri
                cell.displayVideoThumbnail(path: uri ?? "")
            }
            (cell as? ChatThemable)?.applyTheme(self.theme)
            return cell
            
        case .TYPE_QA:
            // 创建QA单元格
            let cell = BWChatQACell.cell(tableView: tableView)
            cell.consultId = Int32(self.consultId)
            cell.heightBlock = { [weak self] (height: Double) in
                guard let self = self else { return }
                // 自动回复来自异步接口，回调时若用户仍在底部，则重新滚到底部；
                // 若用户已经向上翻看历史，保持原位置不动。
                // 首次进入时初始 scrollToBottom 用的是旧 questionViewHeight，
                // 这里靠 needsInitialScrollToBottom 兜底补一次。
                let contentBottom = self.tableView.contentSize.height + self.tableView.contentInset.bottom
                let visibleBottom = self.tableView.contentOffset.y + self.tableView.bounds.height
                let wasNearBottom = (contentBottom - visibleBottom) < 50

                self.questionViewHeight = height
                self.tableView.reloadData()

                if self.needsInitialScrollToBottom || wasNearBottom {
                    self.scrollToBottom()
                    self.needsInitialScrollToBottom = false
                }
            }
            self.currentQAIndexPath = indexPath
            cell.model = model
            
            cell.qaClickBlock = { [weak self] (model: QA) in
                guard let questionTxt = model.question?.content?.data else { return }
                let txtAnswer = model.content ?? ""
                guard let `self` = self else { return }
                
                let q = self.composeALocalTxtMessage(textMsg: questionTxt)
                self.appendDataSource(msg: q, isLeft: false, status: .发送成功)
                
                // 收集用户点击自动回复的记录
                self.withAutoReply = CommonWithAutoReply()
                self.withAutoReply?.id = Int64(model.id ?? 0)
                self.withAutoReply?.title = questionTxt
                self.withAutoReply?.createdTime.seconds = Int64(Date().timeIntervalSince1970)
                
                if !txtAnswer.isEmpty {
                    let a = self.composeALocalTxtMessage(textMsg: txtAnswer)
                    self.appendDataSource(msg: a, isLeft: true, status: .发送成功)
                    
                    var userA = CommonMessageUnion()
                    var uA = CommonMessageContent()
                    uA.data = txtAnswer
                    userA.content = uA
                    self.withAutoReply?.answers.append(userA)
                    tableView.reloadData()
                }
                
                if let multipAnswer = model.answer {
                    for answer in multipAnswer {
                        if let image = answer.image {
                            let a = self.composeALocalImgMessage(url: image.uri ?? "")
                            self.appendDataSource(msg: a, isLeft: true, status: .发送成功, cellType: .TYPE_Image)
                            var userA = CommonMessageUnion()
                            var uA = CommonMessageImage()
                            uA.uri = image.uri ?? ""
                            userA.image = uA
                            self.withAutoReply?.answers.append(userA)
                        } else if let content = answer.content {
                            let a = self.composeALocalTxtMessage(textMsg: content.data ?? "empty")
                            self.appendDataSource(msg: a, isLeft: true, status: .发送成功)
                            
                            var userA = CommonMessageUnion()
                            var uA = CommonMessageContent()
                            uA.data = txtAnswer
                            userA.content = uA
                            self.withAutoReply?.answers.append(userA)
                        }
                    }
                    tableView.reloadData()
                }

            }
            cell.displayIconImg(path: self.avatarPath)
            (cell as? ChatThemable)?.applyTheme(self.theme)
            return cell

        default:
            // 关键词自动卡片（mstAutoCard）：渲染成可点选项卡片
            if model.message?.msgSourceType == CommonMsgSourceType.mstAutoCard {
                let cell = BWAutoCardCell.cell(tableView: tableView)
                cell.model = model
                cell.optionTapBlock = { [weak self] text in
                    // 点击选项 → 当普通消息发送（走 sendMsg，不再触发关键词匹配）
                    self?.sendMsg(textMsg: text)
                }
                cell.jumpTapBlock = { [weak self] jumpUrl, jumpCategory in
                    self?.handleCardJump(jumpUrl: jumpUrl, jumpCategory: jumpCategory)
                }
                cell.displayIconImg(path: self.avatarPath)
                (cell as? ChatThemable)?.applyTheme(self.theme)
                return cell
            }
            //文字和一个图片、视频混合的消息
            if (model.cellType == .TYPE_TEXT_IMAGES){
                let cell: BWTextImagesCell = LeftBWTextImagesCell.cell(tableView: tableView)
                cell.model = model
                cell.longGestCallBack = { [weak self] gesure in
                    if gesure.state == .began {
                        self?.showMenu(gesure, model: model, indexPath: indexPath)
                    }
                }
                
                cell.playBlock = { [weak self] t in
                    var urlcomps = URLComponents(string: baseUrlImage)
                    urlcomps?.path = t

                    guard let imgUrl = urlcomps?.url else {
                        WWProgressHUD.showFailure("无效的图片链接")
                        return
                    }
                    
                    self?.playImageFullScreen(url: imgUrl)
                }
                
                if let leftCell = cell as? LeftBWTextImagesCell {
                    leftCell.displayIconImg(path: self.avatarPath)
                }
                (cell as? ChatThemable)?.applyTheme(self.theme)
                return cell
            }
            //文字和一个图片、视频混合的消息
            //else if ((model.message?.content.data ?? "").contains("\"color\"")){
            else if (model.message?.msgSourceType == CommonMsgSourceType.mstSystemCustomer || model.message?.msgSourceType == CommonMsgSourceType.mstSystemWorker){
                //let cell: BWTextImagesCell = LeftBWTextImagesCell.cell(tableView: tableView)
                let cell: BWTextImagesCell = model.isLeft ? LeftBWTextImagesCell.cell(tableView: tableView) : RightBWTextImagesCell.cell(tableView: tableView)
                cell.model2 = model
                cell.longGestCallBack = { [weak self] gesure in
                    if gesure.state == .began {
                        self?.showMenu(gesure, model: model, indexPath: indexPath)
                    }
                }
                
                cell.playBlock = { [weak self] t in
                    
                    var myUrl = URL(string: t)
                    if !t.contains("http"){
                        var urlcomps = URLComponents(string: baseUrlImage)
                        urlcomps?.path = t
                        myUrl = urlcomps?.url
                    }
                  

                    guard let imgUrl = myUrl else {
                        WWProgressHUD.showFailure("无效的图片链接")
                        return
                    }
                    
                    let ext = t.components(separatedBy: ".").last ?? "#"
                    if videoTypes.contains(ext){
                        self?.playVideoFullScreen(url: imgUrl)
                    }else{
                        self?.playImageFullScreen(url: imgUrl)
                    }
                }
                
                if let leftCell = cell as? LeftBWTextImagesCell {
                    leftCell.displayIconImg(path: self.avatarPath)
                }
                (cell as? ChatThemable)?.applyTheme(self.theme)
                return cell
            } //文字和一个图片、视频混合的消息
//            else if ((model.message?.content.data ?? "").contains("\"color\"")){
//                let cell: BWTextMediaCell = model.isLeft ? LeftBWTextMediaCell.cell(tableView: tableView) : RightBWTextMediaCell.cell(tableView: tableView)
//                cell.model = model
//                cell.longGestCallBack = { [weak self] gesure in
//                    if gesure.state == .began {
//                        self?.showMenu(gesure, model: model, indexPath: indexPath)
//                    }
//                }
//                
//                cell.playBlock = { [weak self] t in
//                   // self?.cellTaped(model: <#T##ChatModel#>)
//                    var dd = t;
//                    print(dd);
//                }
//                if let leftCell = cell as? LeftBWTextMediaCell {
//                    leftCell.displayIconImg(path: self.avatarPath)
//                }
//                return cell
//            }
            else{
                
                
                // 创建默认聊天单元格（根据消息方向显示在左侧或右侧）
                let cell: BWChatCell = model.isLeft ? BWChatLeftCell.cell(tableView: tableView) : BWChatRightCell.cell(tableView: tableView)
                cell.model = model
                cell.longGestCallBack = { [weak self] gesure in
                    if gesure.state == .began {
                        self?.showMenu(gesure, model: model, indexPath: indexPath)
                    }
                }
                if let leftCell = cell as? BWChatLeftCell {
                    leftCell.displayIconImg(path: self.avatarPath)
                }
                cell.showOriginalBack = { [weak self] in
                    guard let replyItem = model.replyItem else { return }
                    self?.showOriginal(model: replyItem)
                }
                
                if let rightCell = cell as? BWChatRightCell {
                    rightCell.resendBlock = { [weak self] _ in
                        self?.datasouceArray[indexPath.row].sendStatus = .发送中
                        if let message = model.message {
                            chatLib.resendMsg(msg: message, payloadId: model.payLoadId)
                        }
                    }
                }
                (cell as? ChatThemable)?.applyTheme(self.theme)
                return cell
            }
        }
    }
    
    // MARK: - showOriginal
    // showOriginal(model: ReplyMessageItem) -  显示原始消息
    func showOriginal(model: ReplyMessageItem) {
        guard let fileName = model.fileName else {
            WWProgressHUD.showFailure("无效的文件名")
            return
        }
        let ext = fileName.split(separator: ".").last?.lowercased() ?? "$"

        var urlcomps = URLComponents(string: baseUrlImage)
        urlcomps?.path = fileName

        guard let url = urlcomps?.url else {
            WWProgressHUD.showFailure("无效的图片链接")
            return
        }

        if (videoTypes.contains(ext)){
            self.playVideoFullScreen(url: url)
        }else{
            self.playImageFullScreen(url: url)
        }
    }

    func showOriginal(model: ChatModel) {
        let myModel = self.datasouceArray.filter { p in
            p.message?.msgID == model.message?.replyMsgID
        }
        cellTaped(model: myModel.first ?? ChatModel())
    }
    
    func cellTaped(textBody: TextBody) {
        print(textBody)
        if let videoURLString = textBody.video, let videoURL = URL(string: videoURLString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)), !videoURLString.isEmpty {
            print(videoURL)
            self.playVideoFullScreen(url: videoURL)
        } else if let imageURLString = textBody.image, let imageURL = URL(string: imageURLString), !imageURLString.isEmpty {
            self.playImageFullScreen(url: imageURL)
        } else {
            print("无效的媒体 URL")
        }
    }

    // MARK: - cellTaped
    // cellTaped(model: ChatModel) -  点击单元格时执行的操作
    func cellTaped(model: ChatModel) {
        guard let msg = model.message else {
            return
        }

        switch model.cellType {
        case .TYPE_Text:
            break

        case .TYPE_Image, .TYPE_File:
            var urlcomps = URLComponents(string: baseUrlImage)
            let uri = model.cellType == .TYPE_File ? msg.file.uri : msg.image.uri
            urlcomps?.path = uri

            guard let imgUrl = urlcomps?.url else {
                WWProgressHUD.showFailure("无效的图片链接")
                return
            }
            self.playImageFullScreen(url: imgUrl)
            print("图片地址:\(imgUrl.absoluteString)")

        default: // .TYPE_VIDEO
            var videoUri = msg.video.uri
            if !msg.video.hlsUri.isEmpty {
                videoUri = msg.video.hlsUri
            }

            var urlcomps = URLComponents(string: baseUrlImage)
            urlcomps?.path = videoUri

            guard let videoUrl = urlcomps?.url else {
                WWProgressHUD.showFailure("无效的播放链接")
                return
            }
            self.playVideoFullScreen(url: videoUrl)
            print("视频地址:\(videoUrl.absoluteString)")
        }
    }

    // MARK: - playVideoFullScreen
    // playVideoFullScreen(url: URL) -  全屏播放视频
    func playVideoFullScreen(url: URL) {
        presentMediaPager(startUrl: url)
    }

    // MARK: - playImageFullScreen
    // playImageFullScreen(url: URL) -  全屏显示图片
    func playImageFullScreen(url: URL) {
        presentMediaPager(startUrl: url)
    }

    // MARK: - 媒体浏览器（横向翻页 + 下拉关闭）

    /// 收集当前会话内的所有图片/视频，按时间正序排列。
    /// 给 KeFuMediaPagerViewController 用作页面数据源。
    func collectMediaItems() -> [KeFuMediaItem] {
        var result: [KeFuMediaItem] = []
        for model in datasouceArray {
            guard let msg = model.message else { continue }

            switch model.cellType {
            case .TYPE_Image:
                if let url = absoluteMediaUrl(from: msg.image.uri) {
                    result.append(.init(url: url, isVideo: false))
                }
            case .TYPE_VIDEO:
                let uri = !msg.video.hlsUri.isEmpty ? msg.video.hlsUri : msg.video.uri
                if let url = absoluteMediaUrl(from: uri) {
                    result.append(.init(url: url, isVideo: true))
                }
            case .TYPE_File:
                let ext = (msg.file.fileName as NSString?)?.pathExtension.lowercased()
                    ?? (msg.file.uri as NSString).pathExtension.lowercased()
                if imageTypes.contains(ext), let url = absoluteMediaUrl(from: msg.file.uri) {
                    result.append(.init(url: url, isVideo: false))
                } else if videoTypes.contains(ext),
                    let url = absoluteMediaUrl(from: msg.file.uri)
                {
                    result.append(.init(url: url, isVideo: true))
                }
            case .TYPE_TEXT_IMAGES:
                let text = msg.content.data
                if let ti = JSONCoding.decode(TextImages.self, from: text) {
                    for path in ti.imgs {
                        guard let url = absoluteMediaUrl(from: path) else { continue }
                        let ext = (path as NSString).pathExtension.lowercased()
                        result.append(
                            .init(url: url, isVideo: videoTypes.contains(ext)))
                    }
                }
            default:
                // 系统下发的图文/视频消息（mstSystemCustomer / mstSystemWorker）
                if msg.msgSourceType == CommonMsgSourceType.mstSystemCustomer
                    || msg.msgSourceType == CommonMsgSourceType.mstSystemWorker
                {
                    let text = msg.content.data
                    if let tb = JSONCoding.decode(TextBody.self, from: text) {
                        // image / video 字段都可能是 ";" 分隔的多个路径
                        for raw in splitMediaPaths(tb.image) {
                            if let url = absoluteMediaUrl(from: raw) {
                                result.append(.init(url: url, isVideo: false))
                            }
                        }
                        for raw in splitMediaPaths(tb.video) {
                            if let url = absoluteMediaUrl(from: raw) {
                                result.append(.init(url: url, isVideo: true))
                            }
                        }
                    }
                }
            }
        }
        return result
    }

    private func splitMediaPaths(_ raw: String?) -> [String] {
        guard let raw = raw?.trimmingCharacters(in: .whitespacesAndNewlines),
            !raw.isEmpty
        else { return [] }
        return raw.components(separatedBy: ";")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }

    private func absoluteMediaUrl(from raw: String) -> URL? {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        if trimmed.contains("http") {
            return URL(string: trimmed)
        }
        var comps = URLComponents(string: baseUrlImage)
        comps?.path = trimmed
        return comps?.url
    }

    private func presentMediaPager(startUrl: URL) {
        let items = collectMediaItems()
        let target = startUrl.absoluteString
        var startIndex = items.firstIndex(where: { $0.url.absoluteString == target }) ?? -1

        let finalItems: [KeFuMediaItem]
        if startIndex < 0 {
            // 兜底：会话列表里找不到这张图（极端情况），就只展示这一张。
            let isVideo =
                videoTypes.contains((startUrl.pathExtension).lowercased())
            finalItems = [.init(url: startUrl, isVideo: isVideo)]
            startIndex = 0
        } else {
            finalItems = items
        }

        let vc = KeFuMediaPagerViewController(items: finalItems, initialIndex: startIndex)
        present(vc, animated: true, completion: nil)
    }
    
    // MARK: - UITableViewDelegate
    
    // tableView(_:numberOfRowsInSection:) -  返回表格视图中section的行数
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datasouceArray.count
    }

    // tableView(_:heightForRowAt:) -  返回指定行的高度
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let model = datasouceArray[indexPath.row]
        if model.cellType == CellType.TYPE_QA {
            return questionViewHeight + 20
        } else if model.cellType == .TYPE_Tip {
            return 80.0
        }
        return UITableView.automaticDimension
    }

    // MARK: - scrollToBottom
    // scrollToBottom() -  滚动到底部，保留与底部 contentInset.bottom（20px）的间距
    func scrollToBottom() {
        // 在主线程更新UI
        DispatchQueue.main.async {
            self.tableView.reloadData()
            guard !self.datasouceArray.isEmpty else { return }

            // estimatedRowHeight 会让 contentSize.height 一开始是估算值，
            // 单独 layoutIfNeeded 只布局可视 cell，非可视区仍是估算。
            // 先 scrollToRow(.bottom) 强制 tableView 出队尾部 cell 计算真实高度，
            // 再用真实 contentSize 精确定位，并保留 bottomInset 间距。
            let lastIndex = IndexPath(row: self.datasouceArray.count - 1, section: 0)
            self.tableView.scrollToRow(at: lastIndex, at: .bottom, animated: false)
            self.tableView.layoutIfNeeded()

            let contentH = self.tableView.contentSize.height
            let frameH = self.tableView.bounds.height
            let bottomInset = self.tableView.contentInset.bottom

            if contentH + bottomInset > frameH {
                let targetY = contentH + bottomInset - frameH
                self.tableView.setContentOffset(CGPoint(x: 0, y: targetY), animated: false)
            } else {
                // 内容不足一屏，回到顶部
                self.tableView.setContentOffset(CGPoint(x: 0, y: -self.tableView.contentInset.top), animated: false)
            }
        }
    }
}

// MARK: - Extension
extension KeFuViewController {
    // MARK: - showMenu
    // showMenu(_:model:indexPath:) -  显示菜单
    func showMenu(_ guesture: UILongPressGestureRecognizer, model: ChatModel?, indexPath: IndexPath) {
        let menu = XMMenuPopover.shared
        menu.style = .system
        let item1 = XMMenuItem(title: "回复") {
            self.toolBar.textView.becomeFirstResponder()
            self.replyBar.updateUI(with: model!)
            if self.replyBar.superview == nil {
                self.view.addSubview(self.replyBar)
                self.view.bringSubviewToFront(self.toolBar)
                self.replyBar.snp.makeConstraints { make in
                    make.left.right.equalToSuperview()
                    make.top.equalTo(self.toolBar.snp.top)
                }
            }
            self.toolBar.setTextInputModel()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.replyBar.snp.updateConstraints { make in
                    make.top.equalTo(self.toolBar.snp.top).offset(-37)
                }
            }
        }
        let item2 = XMMenuItem(title: "复制") {
            self.copyData(model: model, indexPath: indexPath)
        }
       
        if (model?.message?.msgSourceType == CommonMsgSourceType.mstSystemCustomer || model?.message?.msgSourceType == CommonMsgSourceType.mstSystemWorker){
            menu.menuItems = [item2]
        }
        else if model?.cellType == .TYPE_Image || model?.cellType == .TYPE_VIDEO || model?.cellType == .TYPE_File {
            var imgUrl = ""
            if model?.cellType == .TYPE_File {
                imgUrl = model?.message?.file.uri ?? ""
            } else if model?.cellType == .TYPE_Image {
                imgUrl = model?.message?.image.uri ?? ""
            } else {
                imgUrl = model?.message?.video.uri ?? ""
            }
            let item3 = XMMenuItem(title: "下载") {
                if model?.cellType == .TYPE_File{
                    if let link = URL(string: baseUrlImage + imgUrl) {
                      UIApplication.shared.open(link)
                    }
                }else{
                    WWProgressHUD.showLoading()
                    self.startToDownload(imgUrl: imgUrl);
                }
            }
            menu.menuItems = [item1, item3]
        } else {
            menu.menuItems = [item1, item2]
        }
        guard let targetView = guesture.view else { return }
        menu.show(from: targetView, rect: CGRect(x: 0, y: 20, width: targetView.bounds.width, height: targetView.bounds.height), animated: true)
    }
    
    // MARK: - startToDownload
    // startToDownload(imgUrl:toDirectory:) -  开始下载
    func startToDownload(imgUrl: String, toDirectory: URL? = nil){
        NetRequest.standard.downloadAndSaveVideoToPhotoLibrary(from: baseUrlImage + imgUrl, toDirectory: toDirectory) { result in
            switch result {
            case .success(let filePath):
                print(filePath)
                WWProgressHUD.showSuccessWith("已保存到相册")
            case .failure(let error):
                WWProgressHUD.showFailure("下载失败")
                print(error)
            }
        }
    }

    // MARK: - copyData
    // copyData(model:indexPath:) -  复制数据
    func copyData(model: ChatModel?, indexPath: IndexPath) {
        var msgText = model?.message?.content.data ?? ""
        if model?.cellType == .TYPE_Image {
            let cell = self.tableView.cellForRow(at: indexPath) as! BWImageCell as BWImageCell
            UIPasteboard.general.image = cell.thumbnail.image
        } else {
            if (model?.message?.msgSourceType == CommonMsgSourceType.mstSystemCustomer || model?.message?.msgSourceType == CommonMsgSourceType.mstSystemWorker){
                let result = JSONCoding.decode(TextBody.self, from: msgText)
                msgText = result?.content ?? ""
            }
            let pastboard = UIPasteboard.general
            pastboard.string = msgText
        }
        WChatPasteToastView.show(inView: nil)
    }

    /// 处理带 jumpUrl 的卡片按钮点击。
    ///
    /// 宿主注册了处理器 → 交给宿主全权决定怎么打开（小程序 / 原生页 / H5）。
    /// 未注册时 SDK 兜底：H5 → 系统浏览器打开；其余类型 → 内置模拟页。
    func handleCardJump(jumpUrl: String, jumpCategory: Int?) {
        if let handler = cardJumpHandler {
            handler(jumpUrl, jumpCategory)
            return
        }
        if jumpCategory == ServiceKeyword.jumpH5, let url = URL(string: jumpUrl) {
            UIApplication.shared.open(url, options: [:]) { [weak self] ok in
                // 打开失败兜底到模拟页，避免用户点击无反应。
                if !ok { self?.pushMiniProgramMock(jumpUrl: jumpUrl, jumpCategory: jumpCategory) }
            }
            return
        }
        pushMiniProgramMock(jumpUrl: jumpUrl, jumpCategory: jumpCategory)
    }

    private func pushMiniProgramMock(jumpUrl: String, jumpCategory: Int?) {
        let vc = MiniProgramMockViewController(jumpUrl: jumpUrl, jumpCategory: jumpCategory, theme: self.theme)
        if let nav = navigationController {
            nav.pushViewController(vc, animated: true)
        } else {
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: true)
        }
    }
}
