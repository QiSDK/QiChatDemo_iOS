
extension KeFuViewController: BWKeFuChatToolBarV2Delegate {
    func toolBar(toolBar: BWKeFuChatToolBarV2, didSelectedVoice btn: UIButton) {}
    
    func toolBar(toolBar: BWKeFuChatToolBarV2, didSelectedMenu btn: UIButton) {}
    
    /// 表情
    func toolBar(toolBar: BWKeFuChatToolBarV2, didSelectedEmoji btn: UIButton) {}
    
    /// 录音
    func toolBar(toolBar: BWKeFuChatToolBarV2, sendVoice gesture: UILongPressGestureRecognizer) {}
    
    /// 点击发送或者图片
    func toolBar(toolBar: BWKeFuChatToolBarV2, didSelectedPhoto btn: UIButton) {
        self.authorize { state in
            if state == .restricted || state == .denied {
                self.presentNoauth(isPhoto: true)
            } else {
                self.presentImagePicker(controller: self.imagePickerController, source: .photoLibrary)
            }
        }
        self.toolBar.resetStatus()
    }

    func toolBar(toolBar: BWKeFuChatToolBarV2, didSelectedCamera btn: UIButton) {
        self.authorizeCamaro { state in
            if state == .restricted || state == .denied {
                DispatchQueue.main.async {
                    self.presentNoauth(isPhoto: false)
                }
            } else {
                DispatchQueue.main.async {
                    self.presentImagePicker(controller: self.imagePickerController, source: .camera)
                }
            }
        }
        self.toolBar.resetStatus()
    }

    func toolBar(toolBar: BWKeFuChatToolBarV2, didSendMsg btn: UIButton) {
        if toolBar.textView.normalText().isEmpty == false {
            sendMsg(textMsg: toolBar.textView.normalText())
            self.toolBar.resetStatus()
        }
    }
    
    func chooseImgFunc() {
        let alertVC = UIAlertController(title: "选择图片", message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        let alertAction1 = UIAlertAction(title: "从相册选择", style: .default, handler: { [weak self] _ in
            self?.authorize { state in
                if state == .restricted || state == .denied {
                    self?.presentNoauth(isPhoto: true)
                } else {
                    self?.presentImagePicker(controller: self?.imagePickerController ?? UIImagePickerController(), source: .photoLibrary)
                }
            }
        })
        alertVC.addAction(alertAction1)
        let alertAction2 = UIAlertAction(title: "拍照", style: .default, handler: { [weak self] _ in
            self?.authorizeCamaro { state in
                if state == .restricted || state == .denied {
                    DispatchQueue.main.async {
                        self?.presentNoauth(isPhoto: false)
                    }
                } else {
                    DispatchQueue.main.async {
                        self?.presentImagePicker(controller: self?.imagePickerController ?? UIImagePickerController(), source: .camera)
                    }
                }
            }
        })
        alertVC.addAction(alertAction2)
        let cancelAction = UIAlertAction(title: "取消", style: .default, handler: { _ in
            
        })
        alertVC.addAction(cancelAction)
        present(alertVC, animated: true, completion: nil)
    }
    
    func toolBar(toolBar: BWKeFuChatToolBarV2, menuView: BWKeFuChatMenuView, collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath, model: BEmotion) {
        print(model.displayName)
    }
    
    func toolBar(toolBar: BWKeFuChatToolBarV2, didBeginEditing textView: UITextView) {}
    
    func toolBar(toolBar: BWKeFuChatToolBarV2, didChanged textView: UITextView) {}
    
    func toolBar(toolBar: BWKeFuChatToolBarV2, didEndEditing textView: UITextView) {}
    
    /// 发送文字
    func toolBar(toolBar: BWKeFuChatToolBarV2, sendText context: String) {
        sendMsg(textMsg: context)
        self.toolBar.resetStatus()
    }
    
    @objc func toolBar(toolBar: BWKeFuChatToolBarV2, delete text: String, range: NSRange) -> Bool {
        return true
    }
    
    @objc func toolBar(toolBar: BWKeFuChatToolBarV2, changed text: String, range: NSRange) -> Bool {
        return true
    }
}
