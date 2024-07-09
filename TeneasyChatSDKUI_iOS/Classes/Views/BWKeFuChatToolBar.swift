//
//  BWKeFuChatToolView.swift
//  ProgramIOS
//
//  Created by XiaoFu on 2021/8/19.
//  输入框工具栏

import IQKeyboardManagerSwift
import UIKit
// 插入的图片附件的尺寸样式
enum ImageAttachmentMode {
    case Default // 默认（不改变大小）
    case FitTextLine // 使尺寸适应行高
    case FitTextView // 使尺寸适应textView
}

protocol BWKeFuChatToolBarDelegate: AnyObject {
    func toolBar(toolBar: BWKeFuChatToolBar, didSelectedVoice btn: UIButton)
    func toolBar(toolBar: BWKeFuChatToolBar, didSelectedMenu btn: UIButton)
    func toolBar(toolBar: BWKeFuChatToolBar, didSelectedPhoto btn: UIButton)
    func toolBar(toolBar: BWKeFuChatToolBar, didSelectedEmoji btn: UIButton)
    func toolBar(toolBar: BWKeFuChatToolBar, sendVoice gesture: UILongPressGestureRecognizer)
    func toolBar(toolBar: BWKeFuChatToolBar, menuView: BWKeFuChatMenuView, collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath, model: BEmotion)
    func toolBar(toolBar: BWKeFuChatToolBar, didBeginEditing textView: UITextView)
    func toolBar(toolBar: BWKeFuChatToolBar, didChanged textView: UITextView)
    func toolBar(toolBar: BWKeFuChatToolBar, didEndEditing textView: UITextView)
    func toolBar(toolBar: BWKeFuChatToolBar, sendText context: String)
    func toolBar(toolBar: BWKeFuChatToolBar, changed text: String, range: NSRange) -> Bool
    func toolBar(toolBar: BWKeFuChatToolBar, delete text: String, range: NSRange) -> Bool
}

class BWKeFuChatToolBar: UIView {
    public weak var delegate: BWKeFuChatToolBarDelegate?
    private var isShowMenuView = true
    
    private var inputMinHeight: CGFloat = 33
    private var inputMaxHeight: CGFloat = 90
    
    // 保存的输入字符串，当多行文本时，切换语音/键盘按钮，会出现toolBar高度不适应的问题（contentSize）
    var savedText: NSAttributedString = .init(string: "")
    
    /// 监听次数
    var editCount: Int16 = 0

    private lazy var emojiBtn: WButton = {
        let btn = WButton()
        let image = UIImage.svgInit("h5_biaoqing")
        let selImage = UIImage.svgInit("ht_shuru")
        btn.setImage(image?.withRenderingMode(.alwaysOriginal), for: .normal)
        btn.setImage(selImage, for: .selected)
        return btn
    }()

    private lazy var menuBtn: WButton = {
        let btn = WButton()
        let image = UIImage.svgInit("h5_zhaoping")
        btn.setImage(image, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        return btn
    }()

    lazy var placeTextField: UITextField = {
        let text = UITextField()
        text.delegate = self
        return text
    }()
    
    lazy var textView: IQTextView = {
        let text = IQTextView()
        text.layer.cornerRadius = 5
        text.layer.masksToBounds = true
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
        /// 菜单/发送按钮
        addSubview(menuBtn)
        menuBtn.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-10)
            make.centerY.equalToSuperview()
            make.height.equalTo(24)
            make.width.equalTo(24)
        }

        /// 表情按钮
        addSubview(emojiBtn)
        emojiBtn.snp.makeConstraints { make in
            make.right.equalTo(menuBtn.snp.left).offset(-10)
            make.centerY.equalTo(menuBtn)
            make.width.height.equalTo(23)
        }
        
        /// 占位输入框
        addSubview(placeTextField)
        placeTextField.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(10)
            make.right.equalTo(emojiBtn.snp.left).offset(-10)
            make.centerY.equalToSuperview()
            make.height.equalTo(32)
        }

        /// 输入框
        addSubview(textView)
        textView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(10)
            make.right.equalTo(emojiBtn.snp.left).offset(-10)
            make.top.equalToSuperview().offset(7)
            make.bottom.equalToSuperview().offset(-7)
            make.height.equalTo(inputMinHeight)
        }
    }
    
    func initBindModel() {
        BEmotionHelper.shared.emotionArray = BEmotionHelper.getNewEmoji()
        backgroundColor = kBgColor
        textView.addObserver(self, forKeyPath: "attributedText", options: .new, context: nil)
        textView.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
        
        menuBtn.addTarget(self, action: #selector(menuBtnAction(sender:)), for: UIControl.Event.touchUpInside)
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

extension BWKeFuChatToolBar {
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

extension BWKeFuChatToolBar {
    /// 菜单
    @objc private func menuBtnAction(sender: UIButton) {
        delegate?.toolBar(toolBar: self, didSelectedPhoto: sender)
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
//                menuBtn.isSelected = true
//                menuBtn.snp.updateConstraints { make in
//                    make.width.equalTo(55)
//                    make.height.equalTo(32)
//                }
            } else {
//                menuBtn.isSelected = false
//                menuBtn.snp.updateConstraints { make in
//                    make.width.equalTo(23)
//                    make.height.equalTo(23)
//                }
            }
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

extension BWKeFuChatToolBar: UITextViewDelegate, UITextFieldDelegate {
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
        if textView.text.count > 0 || textView.attributedText.length > 0 {
            menuBtn.backgroundColor = UIColor(red: 253/255, green: 230/255, blue: 89/255, alpha: 1)
            menuBtn.setTitle("发送", for: UIControl.State.normal)
            menuBtn.setImage(nil, for: UIControl.State.normal)
            menuBtn.setTitleColor(UIColor.black, for: UIControl.State.normal)
            menuBtn.layer.cornerRadius = 4
            menuBtn.layer.masksToBounds = true
            menuBtn.snp.updateConstraints { make in
                make.width.equalTo(40)
            }
        } else {
            menuBtn.backgroundColor = UIColor.clear
            menuBtn.setTitle(nil, for: UIControl.State.normal)
            menuBtn.setImage(UIImage(named: "lt_photo", in: BundleUtil.getCurrentBundle(), compatibleWith: nil), for: .normal)
            menuBtn.layer.cornerRadius = 0
            menuBtn.layer.masksToBounds = true
            menuBtn.titleLabel?.text = ""
            menuBtn.snp.updateConstraints { make in
                make.width.equalTo(25)
            }
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        // 更改状态“正在输入中”
        delegate?.toolBar(toolBar: self, didEndEditing: textView)
    }
        
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
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

extension BWKeFuChatToolBar: BWKeFuChatEmojiViewDelegate {
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

extension BWKeFuChatToolBar: BWKeFuChatMenuViewDelegate {
    func menuView(menuView: BWKeFuChatMenuView, collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath, model: BEmotion) {
        delegate?.toolBar(toolBar: self, menuView: menuView, collectionView: collectionView, didSelectItemAt: indexPath, model: model)
    }
}
