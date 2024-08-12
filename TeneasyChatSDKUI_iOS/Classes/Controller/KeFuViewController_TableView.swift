import XMMenuPopover

extension KeFuViewController: UITableViewDelegate, UITableViewDataSource {
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = datasouceArray[indexPath.row]
        if model.cellType == .TYPE_Tip {
            let cell = BWTipCell()
            cell.model = model
            return cell
        } else if model.cellType == .TYPE_VIDEO || model.cellType == .TYPE_Image{
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
                if model.cellType == .TYPE_Image{
                    cell.playBtn.isHidden = true
                    cell.displayThumbnail(path: model.message?.image.uri ?? "")
                }else{
                    cell.displayVideoThumbnail(path: model.message?.video.uri ?? "")
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
                
                if model.cellType == .TYPE_Image{
                    cell.playBtn.isHidden = true
                    cell.displayThumbnail(path: model.message?.image.uri ?? "")
                }else{
                    //cell.thumbnail.image = UIImage(named: "imgloading", in: BundleUtil.getCurrentBundle(), compatibleWith: nil)
                    cell.displayVideoThumbnail(path: model.message?.video.uri ?? "")
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

                if !txtAnswer.isEmpty {
                    let a = self?.composeALocalTxtMessage(textMsg: txtAnswer)
                    self?.appendDataSource(msg: a!, isLeft: true, status: .发送成功)
                }

                for answer in multipAnswer {
                    if answer.image != nil {
                        let a = self?.composeALocalImgMessage(url: answer.image?.uri ?? "")
                        self?.appendDataSource(msg: a!, isLeft: true, status: .发送成功, cellType: .TYPE_Image)
                    } else if answer.content != nil {
                        let a = self?.composeALocalTxtMessage(textMsg: answer.content?.data ?? "empty")
                        self?.appendDataSource(msg: a!, isLeft: true, status: .发送成功)
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
               
                return cell
            }
        }
    }
    
    func cellTaped(model: ChatModel){
        guard let msg = model.message else {
            return
        }
        
        if model.cellType == .TYPE_Image{
            //let imgUrl = URL(string: "\(baseUrlImage)\(msg.image.uri)")
            var urlcomps = URLComponents(string: baseUrlImage)
            urlcomps?.path = msg.image.uri
            
            guard let imgUrl = urlcomps?.url else {
                WWProgressHUD.showFailure("无效的图片链接")
                return
            }
            playImageFullScreen(url: imgUrl)
            print("图片地址:\(imgUrl.absoluteString )")
            
        }else{
            let videoUrl = URL(string: "\(baseUrlImage)\(msg.video.uri)")
            
            if videoUrl == nil {
                WWProgressHUD.showFailure("无效的播放链接")
            }else{
                playVideoFullScreen(url: videoUrl!)
                print("视频地址:\(videoUrl?.absoluteString ?? "")")
            }
        }
    }

    func playVideoFullScreen(url: URL) {
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

//    public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
//
//    }

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
        menu.menuItems = [item1, item2]
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
