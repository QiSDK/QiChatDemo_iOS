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
    case Default
    case FitTextLine
    case FitTextView
}

protocol BWKeFuChatToolBarV2Delegate: AnyObject {
    func toolBar(toolBar: BWKeFuChatToolBarV2, didSelectedImageAction btn: UIButton)
    func toolBar(toolBar: BWKeFuChatToolBarV2, didSelectedVideoAction btn: UIButton)
    func toolBar(toolBar: BWKeFuChatToolBarV2, didSelectedDeviceInfoAction btn: UIButton)
    func toolBar(toolBar: BWKeFuChatToolBarV2, didSelectedFileAction btn: UIButton)
    func toolBar(toolBar: BWKeFuChatToolBarV2, didSelectedEmoji btn: UIButton)
    func toolBar(toolBar: BWKeFuChatToolBarV2, didToggleAttachPanel isShowing: Bool)
    func toolBar(toolBar: BWKeFuChatToolBarV2, didBeginEditing textView: UITextView)
    func toolBar(toolBar: BWKeFuChatToolBarV2, didChanged textView: UITextView)
    func toolBar(toolBar: BWKeFuChatToolBarV2, didEndEditing textView: UITextView)
    func toolBar(toolBar: BWKeFuChatToolBarV2, sendText context: String)
    func toolBar(toolBar: BWKeFuChatToolBarV2, changed text: String, range: NSRange) -> Bool
    func toolBar(toolBar: BWKeFuChatToolBarV2, delete text: String, range: NSRange) -> Bool
    func toolBar(toolBar: BWKeFuChatToolBarV2, menuView: BWKeFuChatMenuView, collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath, model: BEmotion)
}

class BWKeFuChatToolBarV2: UIView {
    public weak var delegate: BWKeFuChatToolBarV2Delegate?

    private let inputMinHeight: CGFloat = 36
    private let inputMaxHeight: CGFloat = 90
    private let panelExpandedHeight: CGFloat = 108

    /// 保存的输入字符串
    var savedText: NSAttributedString = .init(string: "")

    /// 监听次数
    var editCount: Int16 = 0

    private(set) var isPanelShowing = false

    // MARK: - 输入胶囊与右侧图标

    /// 圆角胶囊背景
    private lazy var inputPill: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 20
        v.layer.masksToBounds = true
        return v
    }()

    /// 占位输入框（用于切到 emoji 面板时抢焦点）
    lazy var placeTextField: UITextField = {
        let text = UITextField()
        text.delegate = self
        text.isHidden = true
        return text
    }()

    lazy var textView: IQTextView = {
        let text = IQTextView()
        text.placeholder = "说点什么吧"
        text.backgroundColor = .clear
        text.delegate = self
        text.font = UIFont.systemFont(ofSize: 15)
        text.textColor = .black
        text.returnKeyType = .send
        text.isSelectable = true
        text.textContainerInset = .zero
        text.textContainer.lineFragmentPadding = 0
        return text
    }()

    private lazy var emojiBtn: WButton = {
        let btn = WButton()
        var image = UIImage.svgInit("emoj_light")
        var selImage = UIImage.svgInit("ht_shuru")
        if #available(iOS 13.0, *) {
            image = image?.withTintColor(.systemGray, renderingMode: .alwaysOriginal)
            selImage = selImage?.withTintColor(.systemGray, renderingMode: .alwaysOriginal)
        }
        btn.setImage(image, for: .normal)
        btn.setImage(selImage, for: .selected)
        return btn
    }()

    private lazy var attachBtn: WButton = {
        let btn = WButton()
        btn.setImage(Self.paperclipImage(tint: .systemGray), for: .normal)
        return btn
    }()

    // MARK: - 展开面板

    private lazy var panelContainer: UIView = {
        let v = UIView()
        v.clipsToBounds = true
        v.backgroundColor = .clear
        return v
    }()

    private lazy var imageAction = _ToolBarPanelItem(title: "图片",
                                                    image: UIImage.svgInit("Img_box_light"))
    private lazy var videoAction = _ToolBarPanelItem(title: "视频",
                                                    image: Self.videoIcon())
    private lazy var deviceInfoAction = _ToolBarPanelItem(title: "设备信息",
                                                          image: Self.deviceInfoIcon())
    private lazy var fileAction = _ToolBarPanelItem(title: "文件",
                                                   image: UIImage(named: "file_icon",
                                                                 in: BundleUtil.getCurrentBundle(),
                                                                 compatibleWith: nil))

    /// 旧菜单视图（已不再展示，仅保留以兼容 emoji 表情数据源初始化路径）
    lazy var menuView: BWKeFuChatMenuView = {
        let menuView = BWKeFuChatMenuView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 240))
        menuView.delegate = self
        return menuView
    }()

    /// 表情视图（以 placeTextField 的 inputView 形式弹出，等同键盘）
    lazy var emojiView: BWKeFuChatEmojiView = {
        let emojiView = BWKeFuChatEmojiView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 285))
        emojiView.delegate = self
        if #available(iOS 13.0, *) {
            emojiView.backgroundColor = UIColor.tertiarySystemBackground
        }
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
        addSubview(placeTextField)
        placeTextField.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.top.equalToSuperview()
            make.width.height.equalTo(1)
        }

        addSubview(attachBtn)
        attachBtn.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-12)
            make.top.equalToSuperview().offset(8)
            make.width.height.equalTo(36)
        }

        addSubview(emojiBtn)
        emojiBtn.snp.makeConstraints { make in
            make.right.equalTo(attachBtn.snp.left).offset(-2)
            make.centerY.equalTo(attachBtn)
            make.width.height.equalTo(36)
        }

        addSubview(inputPill)
        inputPill.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(12)
            make.right.equalTo(emojiBtn.snp.left).offset(-6)
            make.top.equalToSuperview().offset(8)
            make.height.greaterThanOrEqualTo(40)
        }

        inputPill.addSubview(textView)
        textView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(14)
            make.right.equalToSuperview().offset(-14)
            make.top.equalToSuperview().offset(10)
            make.bottom.equalToSuperview().offset(-10)
            make.height.equalTo(inputMinHeight - 16)
        }

        addSubview(panelContainer)
        panelContainer.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(inputPill.snp.bottom).offset(6)
            make.bottom.equalToSuperview()
            make.height.equalTo(0)
        }

        //let stack = UIStackView(arrangedSubviews: [imageAction, videoAction, deviceInfoAction, fileAction])
        let stack = UIStackView(arrangedSubviews: [imageAction, videoAction, deviceInfoAction])
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.alignment = .top
        stack.spacing = 4
        panelContainer.addSubview(stack)
        stack.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(8)
            make.right.equalToSuperview().offset(-8)
            make.top.equalToSuperview().offset(4)
        }
    }

    private func initBindModel() {
        BEmotionHelper.shared.emotionArray = BEmotionHelper.getNewEmoji()

        if #available(iOS 13.0, *) {
            menuView.backgroundColor = UIColor.secondarySystemBackground
            backgroundColor = UIColor.secondarySystemBackground
        }

        textView.addObserver(self, forKeyPath: "attributedText", options: .new, context: nil)
        textView.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)

        emojiBtn.addTarget(self, action: #selector(emojiBtnAction(sender:)), for: .touchUpInside)
        attachBtn.addTarget(self, action: #selector(attachBtnAction(sender:)), for: .touchUpInside)

        imageAction.addTarget(self, action: #selector(imageActionTapped), for: .touchUpInside)
        videoAction.addTarget(self, action: #selector(videoActionTapped), for: .touchUpInside)
        deviceInfoAction.addTarget(self, action: #selector(deviceInfoActionTapped), for: .touchUpInside)
        fileAction.addTarget(self, action: #selector(fileActionTapped), for: .touchUpInside)

        // 预热 inputView，避免首次切换抖动
        placeTextField.inputView = emojiView
    }

    deinit {
        textView.removeObserver(self, forKeyPath: "attributedText", context: nil)
        textView.removeObserver(self, forKeyPath: "contentSize", context: nil)
    }

    // MARK: - 图标工厂

    private static func paperclipImage(tint: UIColor) -> UIImage? {
        if #available(iOS 13.0, *) {
            let cfg = UIImage.SymbolConfiguration(pointSize: 22, weight: .regular)
            return UIImage(systemName: "paperclip", withConfiguration: cfg)?
                .withTintColor(tint, renderingMode: .alwaysOriginal)
        }
        return nil
    }

    private static func videoIcon() -> UIImage? {
        if #available(iOS 13.0, *) {
            let cfg = UIImage.SymbolConfiguration(pointSize: 24, weight: .regular)
            return UIImage(systemName: "play.rectangle", withConfiguration: cfg)?
                .withRenderingMode(.alwaysTemplate)
        }
        return nil
    }

    private static func deviceInfoIcon() -> UIImage? {
        if #available(iOS 13.0, *) {
            let cfg = UIImage.SymbolConfiguration(pointSize: 24, weight: .regular)
            return UIImage(systemName: "iphone", withConfiguration: cfg)?
                .withRenderingMode(.alwaysTemplate)
        }
        return nil
    }
}

// MARK: - Theming

extension BWKeFuChatToolBarV2: ChatThemable {
    func applyTheme(_ theme: ChatTheme) {
        backgroundColor = theme.gradientEndColor.withAlphaComponent(0.85)
        menuView.backgroundColor = theme.gradientEndColor.withAlphaComponent(0.85)
        emojiView.backgroundColor = theme.gradientEndColor.withAlphaComponent(0.85)

        inputPill.backgroundColor = theme.leftBubbleColor
        textView.textColor = theme.leftBubbleTextColor

        let iconTint = theme.tintColor.withAlphaComponent(0.7)
        let circleColor = theme.leftBubbleColor

        retintIcon(button: emojiBtn, name: "emoj_light", color: iconTint, state: .normal)
        retintIcon(button: emojiBtn, name: "ht_shuru", color: iconTint, state: .selected)
        attachBtn.setImage(Self.paperclipImage(tint: theme.tintColor), for: .normal)

        let panelIconColor = theme.leftBubbleTextColor.withAlphaComponent(0.85)
        let panelLabelColor = theme.leftBubbleTextColor.withAlphaComponent(0.85)
        for item in [imageAction, videoAction, deviceInfoAction, fileAction] {
            item.applyStyle(iconColor: panelIconColor,
                            labelColor: panelLabelColor,
                            circleColor: circleColor)
        }
    }

    private func retintIcon(button: WButton, name: String, color: UIColor,
                            state: UIControl.State = .normal,
                            useAssetCatalog: Bool = false) {
        var image: UIImage?
        if useAssetCatalog {
            image = UIImage(named: name, in: BundleUtil.getCurrentBundle(), compatibleWith: nil)
        } else {
            image = UIImage.svgInit(name)
        }
        guard let original = image else { return }
        if #available(iOS 13.0, *) {
            button.setImage(original.withTintColor(color, renderingMode: .alwaysOriginal), for: state)
        } else {
            button.setImage(original, for: state)
        }
    }
}

// MARK: - 公有方法

extension BWKeFuChatToolBarV2 {
    /// 重设状态
    public func resetStatus() {
        emojiBtn.isSelected = false
        textView.text = ""
        textView.resignFirstResponder()
        placeTextField.resignFirstResponder()
        setPanelShowing(false, animated: false)
    }

    /// 全体禁言
    func banChat(isBan: Bool) {}

    /// 切到文本输入模式
    public func setTextInputModel() {}
}

// MARK: - 私有方法

extension BWKeFuChatToolBarV2 {

    private func setPanelShowing(_ showing: Bool, animated: Bool) {
        guard isPanelShowing != showing else { return }
        isPanelShowing = showing
        panelContainer.snp.updateConstraints { make in
            make.height.equalTo(showing ? panelExpandedHeight : 0)
        }
        delegate?.toolBar(toolBar: self, didToggleAttachPanel: showing)
        if animated {
            UIView.animate(withDuration: 0.22) {
                self.superview?.layoutIfNeeded()
            }
        } else {
            superview?.layoutIfNeeded()
        }
    }

    @objc private func attachBtnAction(sender: UIButton) {
        if isPanelShowing {
            setPanelShowing(false, animated: true)
        } else {
            // 收起键盘 / emoji，再展开面板
            emojiBtn.isSelected = false
            textView.resignFirstResponder()
            placeTextField.resignFirstResponder()
            setPanelShowing(true, animated: true)
        }
    }

    @objc private func emojiBtnAction(sender: UIButton) {
        // emoji 与展开面板互斥
        if isPanelShowing { setPanelShowing(false, animated: true) }

        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            UIView.animate(withDuration: 0.25) { [weak self] in
                self?.placeTextField.inputView = self?.emojiView
                self?.placeTextField.becomeFirstResponder()
                self?.placeTextField.reloadInputViews()
            }
        } else {
            UIView.animate(withDuration: 0.25) { [weak self] in
                self?.placeTextField.inputView = nil
                self?.textView.becomeFirstResponder()
                self?.textView.reloadInputViews()
            }
        }
        delegate?.toolBar(toolBar: self, didSelectedEmoji: sender)
    }

    @objc private func imageActionTapped(sender: UIControl) {
        let proxy = proxyButton(from: sender)
        delegate?.toolBar(toolBar: self, didSelectedImageAction: proxy)
    }

    @objc private func videoActionTapped(sender: UIControl) {
        let proxy = proxyButton(from: sender)
        delegate?.toolBar(toolBar: self, didSelectedVideoAction: proxy)
    }

    @objc private func deviceInfoActionTapped(sender: UIControl) {
        let proxy = proxyButton(from: sender)
        delegate?.toolBar(toolBar: self, didSelectedDeviceInfoAction: proxy)
    }

    @objc private func fileActionTapped(sender: UIControl) {
        let proxy = proxyButton(from: sender)
        delegate?.toolBar(toolBar: self, didSelectedFileAction: proxy)
    }

    /// 面板 item 自定义控件不是 UIButton；外部 delegate 仍按 UIButton 签名，提供个占位。
    private func proxyButton(from control: UIControl) -> UIButton {
        let btn = UIButton(frame: control.bounds)
        return btn
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?,
                               change: [NSKeyValueChangeKey: Any]?,
                               context: UnsafeMutableRawPointer?) {
        if keyPath == "contentSize" {
            guard let contentSize = change?[.newKey] as? CGSize else { return }
            var height = contentSize.height
            if height > inputMaxHeight {
                height = inputMaxHeight
            } else if height < inputMinHeight - 16 {
                height = inputMinHeight - 16
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
        if isPanelShowing { setPanelShowing(false, animated: true) }
        delegate?.toolBar(toolBar: self, didBeginEditing: textView)
    }

    func textViewDidChange(_ textView: UITextView) {
        if textView.attributedText.length > 0 {
            emojiView.setDeleteButtonState(enable: true)
        } else {
            emojiView.setDeleteButtonState(enable: false)
        }
        savedText = textView.attributedText
        delegate?.toolBar(toolBar: self, didChanged: textView)
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        delegate?.toolBar(toolBar: self, didEndEditing: textView)
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange,
                  replacementText text: String) -> Bool {
        let currentText = textView.text ?? ""
        let newTextLength = currentText.count + text.count - range.length
        if newTextLength >= 500 {
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
    func emojiView(emojiView: BWKeFuChatEmojiView, collectionView: UICollectionView,
                   didSelectItemAt indexPath: IndexPath, model: BEmotion) {
        let faceManager = BEmotionHelper.shared
        let emotionAttr = faceManager.obtainAttributedStringByImageKey(
            imageKey: model.displayName,
            font: textView.font ?? UIFont.systemFont(ofSize: 14),
            useCache: false)
        textView.insertEmotionAttributedString(emotionAttributedString: emotionAttr)
        textView.scrollRangeToVisible(NSRange(location: textView.text.count, length: 0))
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
    }
}

extension BWKeFuChatToolBarV2: BWKeFuChatMenuViewDelegate {
    func menuView(menuView: BWKeFuChatMenuView, collectionView: UICollectionView,
                  didSelectItemAt indexPath: IndexPath, model: BEmotion) {
        delegate?.toolBar(toolBar: self, menuView: menuView,
                          collectionView: collectionView,
                          didSelectItemAt: indexPath, model: model)
    }
}

// MARK: - 面板单个 item

private final class _ToolBarPanelItem: UIControl {
    private let circle = UIView()
    private let iconView = UIImageView()
    private let titleLabel = UILabel()

    init(title: String, image: UIImage?) {
        super.init(frame: .zero)
        setupUI()
        titleLabel.text = title
        iconView.image = image
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }

    private func setupUI() {
        circle.backgroundColor = .white
        circle.layer.cornerRadius = 26
        circle.layer.masksToBounds = true
        circle.isUserInteractionEnabled = false
        addSubview(circle)
        circle.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(8)
            make.width.height.equalTo(52)
        }

        iconView.contentMode = .scaleAspectFit
        iconView.tintColor = UIColor(white: 0.2, alpha: 1.0)
        iconView.isUserInteractionEnabled = false
        circle.addSubview(iconView)
        iconView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(28)
        }

        titleLabel.font = UIFont.systemFont(ofSize: 13)
        titleLabel.textColor = UIColor(white: 0.2, alpha: 1.0)
        titleLabel.textAlignment = .center
        titleLabel.isUserInteractionEnabled = false
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(circle.snp.bottom).offset(6)
            make.centerX.equalToSuperview()
            make.left.greaterThanOrEqualToSuperview()
            make.right.lessThanOrEqualToSuperview()
            make.bottom.lessThanOrEqualToSuperview()
        }
    }

    override var isHighlighted: Bool {
        didSet {
            UIView.animate(withDuration: 0.12) {
                self.circle.alpha = self.isHighlighted ? 0.7 : 1.0
            }
        }
    }

    func applyStyle(iconColor: UIColor, labelColor: UIColor, circleColor: UIColor) {
        iconView.tintColor = iconColor
        circle.backgroundColor = circleColor
        titleLabel.textColor = labelColor
    }
}
