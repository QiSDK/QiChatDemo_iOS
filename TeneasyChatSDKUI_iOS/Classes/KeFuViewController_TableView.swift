
extension KeFuViewController: UITableViewDelegate, UITableViewDataSource {
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = datasouceArray[indexPath.row]
        if model.cellType == .TYPE_Tip {
            let cell = BWTipCell()
            cell.model = model
            return cell
        } else if model.cellType == .TYPE_VIDEO {
            if model.isLeft {
                let cell = BWVideoLeftCell.cell(tableView: tableView)
                cell.model = model
                cell.playBlock = { [weak self] in
                    guard let msg = model.message else {
                        return
                    }
                    let videoUrl = URL(string: "\(baseUrlImage)\(msg.video.uri)")
                    self?.playVideoFullScreen(url: videoUrl!)
                }
                return cell
            } else {
                let cell = BWVideoRightCell.cell(tableView: tableView)
                cell.model = model
                cell.playBlock = { [weak self] in
                    guard let msg = model.message else {
                        return
                    }
                    let videoUrl = URL(string: "\(baseUrlImage)\(msg.video.uri)")
                    if videoUrl == nil{
                        WWProgressHUD.showFailure("无效的播放链接")
                    }else{
                        self?.playVideoFullScreen(url: videoUrl!)
                    }
                }
                return cell
            }
        } else if model.isLeft {
            if model.cellType == CellType.TYPE_QA {
                let cell = BWChatQuestionCell.cell(tableView: tableView)
                cell.consultId = Int32(self.consultId)
                cell.heightBlock = { [weak self] (height: Double) in
                    self?.questionViewHeight = height + 100
                    print("questionViewHeight:\(height + 100)")
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
                return cell
            }
            let cell = BWChatLeftCell.cell(tableView: tableView)
            cell.model = model
            cell.longGestCallBack = { [weak self] gesure in
                if gesure.state == .began {
                    self?.showMenu(gesure, model: model, indexPath: indexPath)
                }
            }
            return cell
        }
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
    func playVideoFullScreen(url: URL) {
        let videoPlayerViewController = KeFuVideoPlayerViewController()
        videoPlayerViewController.configure(with: url)
        videoPlayerViewController.modalPresentationStyle = .fullScreen
        present(videoPlayerViewController, animated: false, completion: nil)
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
            return questionViewHeight
        } else if model.cellType == .TYPE_Tip {
            return 60.0
        } else if model.message?.image.uri.isEmpty == false {
            return 200.0
        } else if model.cellType == .TYPE_VIDEO {
            return 230
        }
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
        toolBar.resetStatus()
        if popMenu != nil || model?.message == nil {
            popMenu?.dismiss()
        }
        let msgText = model?.message?.content.data ?? ""

        var dataSouce = [(icon: "chatHuifu", title: "回复"),
                         (icon: "chatCopy", title: "复制")]
        if msgText.isEmpty{
            dataSouce = [(icon: "chatHuifu", title: "回复")]
        }
       

        let popData = dataSouce
        if popData.count == 0 {
            return
        }
        // 设置参数
        let parameters = SwiftPopMenu.defaultConfig()
        var point = guesture.location(in: self.view)
        let pointView = guesture.view
        let space = 0.0
        let point_superview = guesture.location(in: pointView)
        var popMenuW = 120.0
        var pointY: CGFloat = 0
        let textWidth = msgText.textWidth(fontSize: 15, width: kScreenWidth - 100)
        pointY = point.y + msgText.textHeight(fontSize: 15, width: kScreenWidth - 100) - point_superview.y + 30
        point.y = pointY
        var upDown = 1
        if model?.isLeft ?? true {
            point.x = 60 + 30
        } else {
            point.x = kScreenWidth - 100
            if textWidth < 100 {
                upDown = 2 // 无箭头
            }
        }

        popMenu = SwiftPopMenu(menuWidth: popMenuW, arrow: point, datas: popData, configures: parameters, upDown: upDown)
        popMenu?.didSelectMenuBlock = { [weak self] (_: Int, name) in
            switch name {
            case "回复":
                self?.toolBar.textView.becomeFirstResponder()
                self?.replyBar.updateUI(with: model!)
                if self?.replyBar.superview == nil {
                    self?.view.addSubview(self!.replyBar)
                    self?.view.bringSubviewToFront(self!.toolBar)
                    self?.replyBar.snp.makeConstraints { make in
                        make.left.right.equalToSuperview()
                        make.top.equalTo(self!.toolBar.snp.top)
                    }
                }
                self?.toolBar.setTextInputModel()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    // 此处写要延迟的东西
                    self?.replyBar.snp.updateConstraints { make in
                        make.top.equalTo(self!.toolBar.snp.top).offset(-37)
                    }
//                    self?.floatButton.snp.updateConstraints { make in
//                        make.bottom.equalTo(self!.toolBar.snp.top).offset(-37)
//                    }
                }

            case "复制":
                if (model?.cellType == .TYPE_Image) {
                   /* guard let msg = model?.message else {
                        return
                    }*/
                   
                    let cell = self?.tableView.cellForRow(at: indexPath) as! BWChatCell as BWChatCell
                    UIPasteboard.general.image = cell.imgView.image
                    
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
                
            default:
                break
            }
            self?.popMenu = nil
        }
        // show
        popMenu?.show()
    }
}
