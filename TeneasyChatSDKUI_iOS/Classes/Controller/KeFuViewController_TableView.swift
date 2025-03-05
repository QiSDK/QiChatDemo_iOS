import TeneasyChatSDK_iOS
import XMMenuPopover

extension KeFuViewController: UITableViewDelegate, UITableViewDataSource {
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = datasouceArray[indexPath.row]
        if model.cellType == .TYPE_Tip {
            let cell = BWTipCell()
            cell.model = model
            return cell
        } else if model.cellType == .TYPE_File {
            if model.isLeft {
                let cell = BWFileLeftCell.cell(tableView: tableView)
                cell.model = model
                return cell
            } else {
                let cell = BWFileRightCell.cell(tableView: tableView)
                cell.model = model
                return cell
            }
        } else if model.cellType == .TYPE_VIDEO || model.cellType == .TYPE_Image {
            if model.isLeft {
                let cell = BWImageLeftCell.cell(tableView: tableView)
                cell.longGestCallBack = { [weak self] gesure in
                    if gesure.state == .began {
                        self?.showMenu(gesure, model: model, indexPath: indexPath)
                    }
                }
                cell.model = model
                cell.playBlock = { [weak self] in
                    self?.cellTaped(model: model)
                }
                if model.cellType == .TYPE_Image {
                    cell.playBtn.isHidden = true
                    cell.displayThumbnail(path: model.message?.image.uri ?? "")
                } else if model.cellType == .TYPE_File {
                    cell.playBtn.isHidden = true
                    cell.displayFileThumbnail(path: model.message?.file.uri ?? "")
                } else {
                    cell.displayVideoThumbnail(path: model.message?.video.thumbnailUri ?? "")
                }
                return cell
            } else {
                let cell = BWImageRightCell.cell(tableView: tableView)
                cell.longGestCallBack = { [weak self] gesure in
                    if gesure.state == .began {
                        self?.showMenu(gesure, model: model, indexPath: indexPath)
                    }
                }
                cell.model = model
                cell.playBlock = { [weak self] in
                    self?.cellTaped(model: model)
                }
                
                if model.cellType == .TYPE_Image {
                    cell.playBtn.isHidden = true
                    cell.displayThumbnail(path: model.message?.image.uri ?? "")
                } else if model.cellType == .TYPE_File {
                    cell.playBtn.isHidden = true
                    cell.displayFileThumbnail(path: model.message?.file.uri ?? "")
                } else {
                    // cell.thumbnail.image = UIImage(named: "imgloading", in: BundleUtil.getCurrentBundle(), compatibleWith: nil)
                    cell.displayVideoThumbnail(path: model.message?.video.thumbnailUri ?? "")
                }
                return cell
            }
        } else if model.cellType == CellType.TYPE_QA {
            let cell = BWChatQACell.cell(tableView: tableView)
            cell.consultId = Int32(self.consultId)
            cell.heightBlock = { [weak self] (height: Double) in
                self?.questionViewHeight = height + 20
                print("questionViewHeight:\(height + 20)")
                self?.tableView.reloadData()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self?.scrollToBottom()
                }
            }
            cell.model = model
      
            cell.qaClickBlock = { [weak self] (model: QA) in

                let questionTxt = model.question?.content?.data ?? ""
                let txtAnswer = model.content ?? ""
                let multipAnswer = model.answer ?? []
                let q = self?.composeALocalTxtMessage(textMsg: questionTxt)
                self?.appendDataSource(msg: q!, isLeft: false, status: .发送成功)
                
                // 收集用户点击自动回复的记录
                
                self?.withAutoReply = CommonWithAutoReply()
                self?.withAutoReply?.id = Int64(model.id ?? 0)
                self?.withAutoReply?.title = questionTxt
                self?.withAutoReply?.createdTime.seconds = Int64(Date().timeIntervalSince1970)

                if !txtAnswer.isEmpty {
                    let a = self?.composeALocalTxtMessage(textMsg: txtAnswer)
                    self?.appendDataSource(msg: a!, isLeft: true, status: .发送成功)

                    var userA = CommonMessageUnion()
                    var uA = CommonMessageContent()
                    uA.data = txtAnswer
                    userA.content = uA
                    self?.withAutoReply?.answers.append(userA)
                }

                for answer in multipAnswer {
                    if answer.image != nil {
                        let a = self?.composeALocalImgMessage(url: answer.image?.uri ?? "")
                        self?.appendDataSource(msg: a!, isLeft: true, status: .发送成功, cellType: .TYPE_Image)
                        var userA = CommonMessageUnion()
                        var uA = CommonMessageImage()
                        uA.uri = answer.image?.uri ?? ""
                        userA.image = uA
             
                        self?.withAutoReply?.answers.append(userA)
                    } else if answer.content != nil {
                        let a = self?.composeALocalTxtMessage(textMsg: answer.content?.data ?? "empty")
                        self?.appendDataSource(msg: a!, isLeft: true, status: .发送成功)
                        
                        var userA = CommonMessageUnion()
                        var uA = CommonMessageContent()
                        uA.data = txtAnswer
                        userA.content = uA

                        self?.withAutoReply?.answers.append(userA)
                    }
                }
                tableView.reloadData()
            }
            cell.displayIconImg(path: self.avatarPath)
            return cell
        } else {
            if model.isLeft {
                let cell = BWChatLeftCell.cell(tableView: tableView)
                cell.model = model
                cell.longGestCallBack = { [weak self] gesure in
                    if gesure.state == .began {
                        self?.showMenu(gesure, model: model, indexPath: indexPath)
                    }
                }
                cell.displayIconImg(path: self.avatarPath)
                cell.showOriginalBack = {
                    print(model.replayQuote)
                    // WWProgressHUD.showLoading()
                    self.showOriginal(model: model)
                }
                return cell
            } else {
                let cell = BWChatRightCell.cell(tableView: tableView)
                cell.model = model
                cell.resendBlock = { [weak self] _ in
                    self?.datasouceArray[indexPath.row].sendStatus = .发送中
                    self?.lib.resendMsg(msg: model.message!, payloadId: model.payLoadId)
                }
                cell.longGestCallBack = { [weak self] gesure in
                    if gesure.state == .began {
                        self?.showMenu(gesure, model: model, indexPath: indexPath)
                    }
                }
                cell.showOriginalBack = {
                    print(model.replayQuote)
                    // WWProgressHUD.showLoading()
                    self.showOriginal(model: model)
                }
               
                return cell
            }
        }
    }
    
    func showOriginal(model: ChatModel) {
        let myModel = self.datasouceArray.filter { p in
            p.message?.msgID == model.message?.replyMsgID
        }
        
        if let m = myModel.first, let path = m.message?.file.uri, !path.isEmpty {
            if let imgUrl = URL(string: "\(baseUrlImage)\(path)") {
                self.playImageFullScreen(url: imgUrl)
            }
        }
        
        if let m = myModel.first, let path = m.message?.image.uri, !path.isEmpty {
            if let imgUrl = URL(string: "\(baseUrlImage)\(path)") {
                self.playImageFullScreen(url: imgUrl)
            }
        }
        
        if let m = myModel.first, let path = m.message?.video.uri, !path.isEmpty {
            if let imgUrl = URL(string: "\(baseUrlImage)\(path)") {
                self.playVideoFullScreen(url: imgUrl)
            }
        }
    }
    
    func cellTaped(model: ChatModel) {
        guard let msg = model.message else {
            return
        }
        
        if model.cellType == .TYPE_Image || model.cellType == .TYPE_File {
            // let imgUrl = URL(string: "\(baseUrlImage)\(msg.image.uri)")
            var urlcomps = URLComponents(string: baseUrlImage)
            urlcomps?.path = msg.image.uri
            
            if model.cellType == .TYPE_File {
                urlcomps?.path = msg.file.uri
            }
            
            guard let imgUrl = urlcomps?.url else {
                WWProgressHUD.showFailure("无效的图片链接")
                return
            }
            self.playImageFullScreen(url: imgUrl)
            print("图片地址:\(imgUrl.absoluteString)")
            
        } else {
            var m3u8 = msg.video.uri
            if !msg.video.hlsUri.isEmpty {
                m3u8 = msg.video.hlsUri
            }
            let videoUrl = URL(string: "\(baseUrlImage)\(m3u8)")
            
            if videoUrl == nil {
                WWProgressHUD.showFailure("无效的播放链接")
            } else {
                // 写死一个，仅测试
                // videoUrl =  URL(string:"https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8")
                self.playVideoFullScreen(url: videoUrl!)
                print("视频地址:\(videoUrl?.absoluteString ?? "")")
            }
        }
    }

    func playVideoFullScreen(url: URL) {
        print(url.absoluteString)
        let vc = KeFuVideoViewController()
        vc.configure(with: url, workerName: workerName)
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: false, completion: nil)
    }
    
    func playImageFullScreen(url: URL) {
        let vc = KeFuWebViewController()
        vc.configure(with: url, workerName: workerName)
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: false, completion: nil)
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datasouceArray.count
    }

    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let model = datasouceArray[indexPath.row]
        if model.cellType == CellType.TYPE_QA {
            return questionViewHeight + 20
        } else if model.cellType == .TYPE_Tip {
            return 80.0
        }
//        else if model.cellType == .TYPE_VIDEO || model.cellType == .TYPE_Image{
//            return 114 + 10 + 20
//        }
        
        /*
         else if model.message?.image.uri.isEmpty == false {
             return 170
         }
         */
        return UITableView.automaticDimension
    }

    func scrollToBottom() {
        if datasouceArray.count > 1 {
            // tableView.scrollToRow(at: IndexPath(row: datasouceArray.count - 1, section: 0), at: UITableView.ScrollPosition.none, animated: true)

            self.tableView.scrollToRow(at: IndexPath(row: datasouceArray.count - 1, section: 0), at: UITableView.ScrollPosition.bottom, animated: true)
        }
    }
}

extension KeFuViewController {
    func showMenu(_ guesture: UILongPressGestureRecognizer, model: ChatModel?, indexPath: IndexPath) {
//        toolBar.resetStatus()
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
                // 此处写要延迟的东西
                self.replyBar.snp.updateConstraints { make in
                    make.top.equalTo(self.toolBar.snp.top).offset(-37)
                }
            }
        }
        let item2 = XMMenuItem(title: "复制") {
            self.copyData(model: model, indexPath: indexPath)
        }
       
        if model?.cellType == .TYPE_Image || model?.cellType == .TYPE_VIDEO || model?.cellType == .TYPE_File {
            var imgUrl = ""
            if model?.cellType == .TYPE_File {
                imgUrl = model?.message?.file.uri ?? ""
            } else if model?.cellType == .TYPE_Image {
                imgUrl = model?.message?.image.uri ?? ""
            } else {
                imgUrl = model?.message?.video.uri ?? ""
            }
            let item3 = XMMenuItem(title: "下载") {
                WWProgressHUD.showLoading()
                NetRequest.standard.downloadAndSaveVideoToPhotoLibrary(from: baseUrlImage + imgUrl) { result in
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
            menu.menuItems = [item1, item3]
        } else {
            menu.menuItems = [item1, item2]
        }
        guard let targetView = guesture.view else { return }
        menu.show(from: targetView, rect: CGRect(x: 0, y: 20, width: targetView.bounds.width, height: targetView.bounds.height), animated: true)
    }

    func copyData(model: ChatModel?, indexPath: IndexPath) {
        let msgText = model?.message?.content.data ?? ""
        if model?.cellType == .TYPE_Image {
            /* guard let msg = model?.message else {
                 return
             }*/

            let cell = self.tableView.cellForRow(at: indexPath) as! BWImageCell as BWImageCell
            UIPasteboard.general.image = cell.thumbnail.image

            /*  let imgUrl = URL(string: "\(baseUrlImage)\(msg.image.uri)")
             print(imgUrl?.absoluteString ?? "")
             let imageView = UIImageView()
                imageView.kf.setImage(with: imgUrl, placeholder: nil, options: nil, progressBlock: nil) { result in
                    switch result {
                    case .success(let value):
                        print("Image successfully loaded: \(value.image)")
                        UIPasteboard.general.image = value.image
                    case .failure(let error):
                        print("Error loading image: \(error)")
                    }
                }*/
        } else {
            let pastboard = UIPasteboard.general
            pastboard.string = msgText
        }
        WChatPasteToastView.show(inView: nil)
    }
}
