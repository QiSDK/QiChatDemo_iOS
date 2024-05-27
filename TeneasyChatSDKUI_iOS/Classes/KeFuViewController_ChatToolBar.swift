
extension KeFuViewController: BWKeFuChatToolBarDelegate {
    func toolBar(toolBar: BWKeFuChatToolBar, didSelectedVoice btn: UIButton) {}
    
    func toolBar(toolBar: BWKeFuChatToolBar, didSelectedMenu btn: UIButton) {}
    
    /// 表情
    func toolBar(toolBar: BWKeFuChatToolBar, didSelectedEmoji btn: UIButton) {}
    
    /// 录音
    func toolBar(toolBar: BWKeFuChatToolBar, sendVoice gesture: UILongPressGestureRecognizer) {}
    
    /// 点击发送或者图片
    func toolBar(toolBar: BWKeFuChatToolBar, didSelectedPhoto btn: UIButton) {
        if btn.titleLabel?.text == "发送" {
            sendMsg(textMsg: toolBar.textView.normalText())
            //sendMsg(textMsg: toolBar.textView.text)
        } else {
            // 选图片
            chooseImgFunc()
        }
        self.toolBar.resetStatus()
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
    
    func toolBar(toolBar: BWKeFuChatToolBar, menuView: BWKeFuChatMenuView, collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath, model: BEmotion) {
        print(model.displayName)
    }
    
    func toolBar(toolBar: BWKeFuChatToolBar, didBeginEditing textView: UITextView) {}
    
    func toolBar(toolBar: BWKeFuChatToolBar, didChanged textView: UITextView) {}
    
    func toolBar(toolBar: BWKeFuChatToolBar, didEndEditing textView: UITextView) {}
    
    /// 发送文字
    func toolBar(toolBar: BWKeFuChatToolBar, sendText context: String) {
        sendMsg(textMsg: context)
        self.toolBar.resetStatus()
    }
    
    @objc func toolBar(toolBar: BWKeFuChatToolBar, delete text: String, range: NSRange) -> Bool {
        return true
    }
    
    @objc func toolBar(toolBar: BWKeFuChatToolBar, changed text: String, range: NSRange) -> Bool {
        return true
    }
}
