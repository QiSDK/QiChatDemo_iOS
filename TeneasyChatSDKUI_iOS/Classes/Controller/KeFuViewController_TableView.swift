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
            if let leftCell = cell as? BWFileLeftCell {
                leftCell.displayIconImg(path: self.avatarPath)
            }
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
            return cell
            
        case .TYPE_QA:
            // 创建QA单元格
            let cell = BWChatQACell.cell(tableView: tableView)
            cell.consultId = Int32(self.consultId)
            cell.heightBlock = { [weak self] (height: Double) in
                //self?.questionViewHeight = height + 20
                print("questionViewHeight:\(height + 20)")
                //                if let indexPath = self?.currentQAIndexPath {
                //                    self?.tableView.reloadRows(at: [indexPath], with: .automatic)
                //                }
                self?.questionViewHeight = height
                self?.tableView.reloadData()
//                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//                    self?.scrollToBottom()
//                }
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
            return cell
            
        default:
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
                
                cell.displayIconImg(path: self.avatarPath)
                return cell
            }
            //文字和一个图片、视频混合的消息
            else if ((model.message?.content.data ?? "").contains("\"color\"")){
                let cell: BWTextMediaCell = model.isLeft ? LeftBWTextMediaCell.cell(tableView: tableView) : RightBWTextMediaCell.cell(tableView: tableView)
                cell.model = model
                cell.longGestCallBack = { [weak self] gesure in
                    if gesure.state == .began {
                        self?.showMenu(gesure, model: model, indexPath: indexPath)
                    }
                }
                
                cell.playBlock = { [weak self] t in
                   // self?.cellTaped(model: <#T##ChatModel#>)
                    var dd = t;
                    print(dd);
                }
                
                cell.displayIconImg(path: self.avatarPath)
                return cell
            }else{
                
                
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
                            lib.resendMsg(msg: message, payloadId: model.payLoadId)
                        }
                    }
                }
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
        print(url.absoluteString)
        let vc = KeFuVideoViewController()
        vc.configure(with: url, workerName: workerName)
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: false, completion: nil)
    }
    
    // MARK: - playImageFullScreen
    // playImageFullScreen(url: URL) -  全屏显示图片
    func playImageFullScreen(url: URL) {
        let vc = KeFuWebViewController()
        vc.configure(with: url, workerName: workerName)
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: false, completion: nil)
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
    // scrollToBottom() -  滚动到底部
    func scrollToBottom() {
        if datasouceArray.count > 1 {
            self.tableView.scrollToRow(at: IndexPath(row: datasouceArray.count - 1, section: 0), at: UITableView.ScrollPosition.bottom, animated: true)
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
       
        if (model?.message?.content.data ?? "").contains("\"color\""){
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
                WWProgressHUD.showSuccessWith("下载成功")
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
            if (msgText.contains("\"color\"")){
                let result = TextBody.deserialize(from: msgText)
                msgText = result?.content ?? ""
            }
            let pastboard = UIPasteboard.general
            pastboard.string = msgText
        }
        WChatPasteToastView.show(inView: nil)
    }
}
