//
//  BWKeFuChatToolBarV2.swift
//  TeneasyChatSDKUI_iOS
//
//  Created by Xiao Fu on 2024/7/2.
//

import IQKeyboardManagerSwift
import UIKit
// 插入的图片附件的尺寸样式
enum ImageAttachmentModeV2 {
    case Default // 默认（不改变大小）
    case FitTextLine // 使尺寸适应行高
    case FitTextView // 使尺寸适应textView
}

protocol BWKeFuChatToolBarV2Delegate: AnyObject {
    func toolBar(toolBar: BWKeFuChatToolBarV2, didSelectedVoice btn: UIButton)
    func toolBar(toolBar: BWKeFuChatToolBarV2, didSelectedMenu btn: UIButton)
    func toolBar(toolBar: BWKeFuChatToolBarV2, didSelectedPhoto btn: UIButton)
    func toolBar(toolBar: BWKeFuChatToolBarV2, didSelectedCamera btn: UIButton)
    func toolBar(toolBar: BWKeFuChatToolBarV2, didSendMsg btn: UIButton)
    func toolBar(toolBar: BWKeFuChatToolBarV2, didSelectedEmoji btn: UIButton)
    func toolBar(toolBar: BWKeFuChatToolBarV2, sendVoice gesture: UILongPressGestureRecognizer)
    func toolBar(toolBar: BWKeFuChatToolBarV2, menuView: BWKeFuChatMenuView, collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath, model: BEmotion)
    func toolBar(toolBar: BWKeFuChatToolBarV2, didBeginEditing textView: UITextView)
    func toolBar(toolBar: BWKeFuChatToolBarV2, didChanged textView: UITextView)
    func toolBar(toolBar: BWKeFuChatToolBarV2, didEndEditing textView: UITextView)
    func toolBar(toolBar: BWKeFuChatToolBarV2, sendText context: String)
    func toolBar(toolBar: BWKeFuChatToolBarV2, changed text: String, range: NSRange) -> Bool
    func toolBar(toolBar: BWKeFuChatToolBarV2, delete text: String, range: NSRange) -> Bool
}

class BWKeFuChatToolBarV2: UIView {
    public weak var delegate: BWKeFuChatToolBarV2Delegate?
    private var isShowMenuView = true
    
    private var inputMinHeight: CGFloat = 33
    private var inputMaxHeight: CGFloat = 90
    
    // 保存的输入字符串，当多行文本时，切换语音/键盘按钮，会出现toolBar高度不适应的问题（contentSize）
    var savedText: NSAttributedString = .init(string: "")
    
    /// 监听次数
    var editCount: Int16 = 0
    
    private lazy var photoBtn: WButton = {
        let btn = WButton()
        let image = UIImage.svgInit("Img_box_light")
        btn.setImage(image, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        return btn
    }()
    
    private lazy var cameraBtn: WButton = {
        let btn = WButton()
        let image = UIImage.svgInit("camera_light")
        btn.setImage(image, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        return btn
    }()

    private lazy var emojiBtn: WButton = {
        let btn = WButton()
        let image = UIImage.svgInit("emoj_light")
        let selImage = UIImage.svgInit("ht_shuru")
        btn.setImage(image?.withRenderingMode(.alwaysOriginal), for: .normal)
        btn.setImage(selImage, for: .selected)
        return btn
    }()
    
    lazy var textCountLabel: UILabel = {
        let label = UILabel()
        label.text = "0/500"
        label.font = UIFont.systemFont(ofSize: 15)
        label.textColor = .gray
        return label
    }()

    private lazy var sendBtn: WButton = {
        let btn = WButton()
        btn.setTitle("发送", for: UIControl.State.normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        btn.setTitleColor(.white, for: UIControl.State.normal)
        btn.backgroundColor = kMainColor
        btn.layer.cornerRadius = 4
        btn.layer.masksToBounds = true
        return btn
    }()

    lazy var placeTextField: UITextField = {
        let text = UITextField()
        text.delegate = self
        return text
    }()
    
    lazy var textView: IQTextView = {
        let text = IQTextView()
        text.layer.cornerRadius = 8
        text.layer.masksToBounds = true
        text.clipsToBounds = true
        text.backgroundColor = chatBackColor
        text.delegate = self
        text.font = UIFont.systemFont(ofSize: 14)
        text.textColor = .black
        text.returnKeyType = .send
        text.isSelectable = true
        return text
    }()
    
    /// 菜单视图
    lazy var menuView: BWKeFuChatMenuView = {
        let menuView = BWKeFuChatMenuView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 240))
        menuView.backgroundColor = chatBackColor
        menuView.delegate = self
        return menuView
    }()
    
    /// 表情视图
    lazy var emojiView: BWKeFuChatEmojiView = {
        let emojiView = BWKeFuChatEmojiView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 285))
        emojiView.delegate = self
        emojiView.backgroundColor = chatBackColor
        return emojiView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        initSubViews()
        initBindModel()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initSubViews() {
        /// 占位输入框
        addSubview(placeTextField)
        placeTextField.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-10)
            make.top.equalToSuperview().offset(10)
            make.height.equalTo(32)
        }

        /// 输入框
        addSubview(textView)
        textView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-10)
            make.top.equalToSuperview().offset(10)
            make.bottom.equalToSuperview().offset(-44)
            make.height.equalTo(inputMinHeight)
        }
        
        addSubview(photoBtn)
        photoBtn.snp.makeConstraints { make in
            make.left.equalTo(textView.snp.left)
            make.top.equalTo(textView.snp.bottom).offset(8)
            make.width.height.equalTo(26)
        }
        addSubview(cameraBtn)
        cameraBtn.snp.makeConstraints { make in
            make.left.equalTo(photoBtn.snp.right).offset(5)
            make.centerY.equalTo(photoBtn.snp.centerY)
            make.width.height.equalTo(photoBtn.snp.width)
        }
        addSubview(emojiBtn)
        emojiBtn.snp.makeConstraints { make in
            make.left.equalTo(cameraBtn.snp.right).offset(5)
            make.centerY.equalTo(photoBtn.snp.centerY)
            make.width.height.equalTo(photoBtn.snp.width)
        }
        
        addSubview(sendBtn)
        sendBtn.snp.makeConstraints { make in
            make.right.equalTo(textView.snp.right)
            make.centerY.equalTo(photoBtn.snp.centerY)
            make.width.equalTo(70)
            make.height.equalTo(30)
        }
        addSubview(textCountLabel)
        textCountLabel.snp.makeConstraints { make in
            make.right.equalTo(sendBtn.snp.left).offset(-5)
            make.centerY.equalTo(photoBtn.snp.centerY)
        }
    }
    
    func initBindModel() {
        BEmotionHelper.shared.emotionArray = BEmotionHelper.getNewEmoji()
        backgroundColor = kBgColor
        textView.backgroundColor = .white
        placeTextField.backgroundColor = .white
        textView.addObserver(self, forKeyPath: "attributedText", options: .new, context: nil)
        textView.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
        
        photoBtn.addTarget(self, action: #selector(photoBtnAction(sender:)), for: UIControl.Event.touchUpInside)
        cameraBtn.addTarget(self, action: #selector(cameraBtnAction(sender:)), for: UIControl.Event.touchUpInside)
        sendBtn.addTarget(self, action: #selector(sendBtnAction(sender:)), for: UIControl.Event.touchUpInside)
        emojiBtn.addTarget(self, action: #selector(emojiBtnAction(sender:)), for: UIControl.Event.touchUpInside)
                
        /// 主动调一下懒加载，提前创建好两个视图
        placeTextField.inputView = menuView
        placeTextField.inputView = emojiView
    }
    
    deinit {
        textView.removeObserver(self, forKeyPath: "attributedText", context: nil)
        textView.removeObserver(self, forKeyPath: "contentSize", context: nil)
    }
}

// MARK: - --------------公有方法

extension BWKeFuChatToolBarV2 {
    /// 重设状态
    public func resetStatus() {
        isShowMenuView = true
        emojiBtn.isSelected = false
        textView.text = ""
        textView.resignFirstResponder()
        placeTextField.resignFirstResponder()
        updateMenuBtn()
    }
    
    /// 全体禁言
    func banChat(isBan: Bool) {}
    
    /// 将语音模式切换到文本输入模式
    public func setTextInputModel() {}
}

// MARK: - --------------私有方法

extension BWKeFuChatToolBarV2 {
    /// 菜单
    @objc private func photoBtnAction(sender: UIButton) {
        delegate?.toolBar(toolBar: self, didSelectedPhoto: sender)
    }
    @objc private func cameraBtnAction(sender: UIButton) {
        delegate?.toolBar(toolBar: self, didSelectedCamera: sender)
    }
    @objc private func sendBtnAction(sender: UIButton) {
        delegate?.toolBar(toolBar: self, didSendMsg: sender)
    }
    
    /// 表情
    @objc private func emojiBtnAction(sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            UIView.animate(withDuration: 0.25) { [weak self] in
                self?.placeTextField.inputView = self?.emojiView
                self?.placeTextField.becomeFirstResponder()
                self?.placeTextField.reloadInputViews()
                self?.textView.isHidden = false
            }
        } else {
            UIView.animate(withDuration: 0.25) { [weak self] in
                self?.textView.isHidden = false
                self?.placeTextField.inputView = nil
                self?.textView.becomeFirstResponder()
                self?.textView.reloadInputViews()
            }
        }
        
        isShowMenuView = true
        delegate?.toolBar(toolBar: self, didSelectedEmoji: sender)
    }
    
    /// 录制语音
    @objc private func sendVoiceGesture(sender: UILongPressGestureRecognizer) {
        if sender.state == UIGestureRecognizer.State.began {
            NSLog("开始")
        } else if sender.state == UIGestureRecognizer.State.possible {
            NSLog("possible")
        } else if sender.state == UIGestureRecognizer.State.changed {
        } else if sender.state == UIGestureRecognizer.State.ended {
            NSLog("结束")
        } else if sender.state == UIGestureRecognizer.State.cancelled {
            NSLog("取消")
        } else {
            NSLog("失败")
        }
        
        delegate?.toolBar(toolBar: self, sendVoice: sender)
    }
    
    @objc private func tapped(sender: UIButton) {}
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "attributedText" {
            let attributedText = change?[.newKey] as! NSAttributedString
            if attributedText.length > 0 {
            } else {}
        } else if keyPath == "contentSize" {
            guard let contentSize = change?[.newKey] as? CGSize else { return }
            var height = contentSize.height
            if height > inputMaxHeight {
                height = inputMaxHeight
            } else if height < inputMinHeight {
                height = inputMinHeight
            }
            
            textView.snp.updateConstraints { make in
                make.height.equalTo(height)
            }
            layoutIfNeeded()
        }
    }
}

extension BWKeFuChatToolBarV2: UITextViewDelegate, UITextFieldDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        emojiBtn.isSelected = false
        isShowMenuView = true
        // textview变成第一响应后，不一定是“正在输入中”
        delegate?.toolBar(toolBar: self, didBeginEditing: textView)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if textView.attributedText.length > 0 {
            emojiView.setDeleteButtonState(enable: true)
        } else {
            emojiView.setDeleteButtonState(enable: false)
        }
        savedText = textView.attributedText
        updateMenuBtn()
        
        // 发送系统通知“正在输入中”
        delegate?.toolBar(toolBar: self, didChanged: textView)
    }
    
    func updateMenuBtn() {
        textCountLabel.text = "\(textView.text.count)/500"
        if textView.text.count > 0 || textView.attributedText.length > 0 {
        } else {}
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        // 更改状态“正在输入中”
        delegate?.toolBar(toolBar: self, didEndEditing: textView)
    }
        
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let currentText = textView.text ?? ""
        let newTextLength = currentText.count + text.count - range.length
        if (newTextLength >= 500) {
            return false
        }
        if text == "\n" {
            delegate?.toolBar(toolBar: self, sendText: textView.normalText())
            return false
        }
        if text.count == 0 {
            if let delegate = delegate {
                return delegate.toolBar(toolBar: self, delete: text, range: range)
            }
        } else {
            return delegate?.toolBar(toolBar: self, changed: text, range: range) ?? true
        }
        return true
    }
}

extension BWKeFuChatToolBarV2: BWKeFuChatEmojiViewDelegate {
    func emojiView(emojiView: BWKeFuChatEmojiView, collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath, model: BEmotion) {
        let faceManager = BEmotionHelper.shared
        let emotionAttr = faceManager.obtainAttributedStringByImageKey(imageKey: model.displayName, font: textView.font ?? UIFont.systemFont(ofSize: 14), useCache: false)
        textView.insertEmotionAttributedString(emotionAttributedString: emotionAttr)
        textView.scrollRangeToVisible(NSRange(location: textView.text.count, length: 0))
        updateMenuBtn()
    }
    
    func emojiView(emojiView: BWKeFuChatEmojiView, didSelectDelete btn: WButton) {
        if textView.attributedText.length == 0 {
            return
        }
        if !textView.deleteEmotion() {
            textView.deleteBackward()
        }
        if textView.attributedText.length == 0 {
            self.emojiView.setDeleteButtonState(enable: false)
        } else {
            self.emojiView.setDeleteButtonState(enable: true)
        }
        updateMenuBtn()
    }
}

extension BWKeFuChatToolBarV2: BWKeFuChatMenuViewDelegate {
    func menuView(menuView: BWKeFuChatMenuView, collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath, model: BEmotion) {
        delegate?.toolBar(toolBar: self, menuView: menuView, collectionView: collectionView, didSelectItemAt: indexPath, model: model)
    }
}
