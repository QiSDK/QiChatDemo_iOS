//
//  BWChatCell.swift
//  TeneasyChatSDKUI_iOS_Example
//
//  Created by XiaoFu on 2023/2/1.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import AVFoundation
import Kingfisher
import SnapKit
import UIKit
import TeneasyChatSDK_iOS

typealias BWChatCellLongGestCallBack = (UILongPressGestureRecognizer) -> ()
typealias BWShowOriginalClickBlock = () -> ()
typealias BWCellHeightCallBack = (Double) -> ()

class BWChatCell: UITableViewCell {
    var heightBlock: BWCellHeightCallBack?
    var gesture: UILongPressGestureRecognizer?
    var longGestCallBack: BWChatCellLongGestCallBack?
    var showOriginalBack: BWShowOriginalClickBlock?
    var msgMaxWidth = kScreenWidth * 0.7

    private var detectedLinks: [BWLinkDetector.Link] = []
    private var linkTapGesture: UITapGestureRecognizer?

    /// Color used for tappable URLs / emails / phone numbers inside the bubble.
    /// Subclasses override to match their bubble background.
    var linkColor: UIColor { .systemBlue }
    lazy var timeLab: UILabel = {
        let lab = UILabel()
        lab.font = UIFont.systemFont(ofSize: 13)
        if #available(iOS 13.0, *) {
            lab.textColor = UIColor.systemGray2
        } else {
            // Fallback on earlier versions
        }
        lab.lineBreakMode = .byTruncatingTail
        return lab
    }()
    

    lazy var titleLab: BWLabel = {
        let lab = BWLabel()
        lab.font = UIFont.systemFont(ofSize: 14)
        lab.textColor = .white

        lab.numberOfLines = 1000
        lab.layer.cornerRadius = 18
        // 不再裁剪 —— 允许阴影渲染到 layer 外;
        lab.layer.masksToBounds = false
        //lab.numberOfLines = 0 // Allow unlimited lines
        lab.lineBreakMode = .byWordWrapping
        lab.textInsets = UIEdgeInsets(top: 12, left: 14, bottom: 12, right: 14)
        lab.backgroundColor = .clear // 必须设为透明，否则 view 的背景会盖住 layer 的圆角

        //lab.preferredMaxLayoutWidth = kScreenWidth - 120 - iconWidth - 12
        return lab
    }()
    
    lazy var contentBgView: UIImageView = {
        let img = UIImageView()
        return img
    }()

    lazy var blackBackgroundView: UIView = {
        let blackBackgroundView = UIView()
        blackBackgroundView.backgroundColor = .black
        blackBackgroundView.alpha = 0
        return blackBackgroundView
    }()
    
    lazy var iconView: UIImageView = {
        let img = UIImageView()
        img.layer.cornerRadius = iconWidth * 0.5
        img.layer.masksToBounds = true
        return img
    }()

    lazy var arrowView: UIImageView = {
        let img = UIImageView()
        img.isHidden = true
        return img
    }()
    
    lazy var failedDotView: UIImageView = {
        let v = UIImageView()
        return v
    }()
    
    lazy var replyView: BWReplyView = {
        let v = BWReplyViewLeft()
        v.layer.cornerRadius = 8
        v.layer.masksToBounds = true
        return v
    }()
    
    var leftConstraint: Constraint?
    var rightConstraint: Constraint?
    
    static func cell(tableView: UITableView) -> Self {
        let cellId = "\(Self.self)"
        var cell = tableView.dequeueReusableCell(withIdentifier: cellId)
        if cell == nil {
            cell = Self(style: .default, reuseIdentifier: cellId)
        }
        
        return cell as! Self
    }
    
    override required init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        
        self.contentView.addSubview(self.contentBgView)
        self.contentView.addSubview(self.arrowView)
        self.contentView.addSubview(self.iconView)
        self.contentView.addSubview(self.timeLab)
        self.contentView.addSubview(self.replyView)
        self.contentView.addSubview(self.titleLab)
        
        self.contentBgView.isUserInteractionEnabled = true
        self.contentView.isUserInteractionEnabled = true

        
        self.gesture = UILongPressGestureRecognizer(target: self, action: #selector(self.longGestureClick(tap:)))
        self.titleLab.isUserInteractionEnabled = true
        self.titleLab.addGestureRecognizer(self.gesture!)

        let linkTap = UITapGestureRecognizer(target: self, action: #selector(self.handleLinkTap(_:)))
        linkTap.cancelsTouchesInView = false
        self.titleLab.addGestureRecognizer(linkTap)
        self.linkTapGesture = linkTap

        self.replyView.isUserInteractionEnabled = true
        let tapShowOriginalGesture = UITapGestureRecognizer(target: self, action: #selector(self.showOriginal))
        self.replyView.addGestureRecognizer(tapShowOriginalGesture)
    }

    @objc func longGestureClick(tap: UILongPressGestureRecognizer) {
        self.longGestCallBack?(tap)
    }
    
    @objc func showOriginal() {
        self.showOriginalBack!()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.replyView.reset()
        self.replyView.snp.updateConstraints { make in
            make.height.equalTo(0)
            make.width.equalTo(0)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

    }
    
    var model: ChatModel? {
        didSet {
            guard let msg = model?.message else {
                return
            }
            self.timeLab.text = msg.msgTime.date.toString(format: "yyyy-MM-dd HH:mm:ss")

            let quote = self.model?.replyItem?.content ?? ""
            let hasReply = BWReplyView.hasDisplayableReply(model)

            self.initTitle(msg: msg)
            replyView.model = model

            if hasReply && !BWReplyView.isFileReply(model) && quote.contains("[emoticon_") == true {
                let atttext = BEmotionHelper.shared.attributedStringByText(text: quote, font: self.replyView.fileNameLab.font)
                self.replyView.fileNameLab.attributedText = atttext
            }

            if hasReply {
                self.replyView.isHidden = false
                let pillSize = computeReplyPillSize()
                self.replyView.snp.updateConstraints { make in
                    make.top.equalTo(self.titleLab.snp.bottom).offset(6).priority(.low)
                    make.height.equalTo(pillSize.height)
                    make.width.equalTo(pillSize.width)
                }
            } else {
                self.replyView.isHidden = true
                self.replyView.snp.updateConstraints { make in
                    make.top.equalTo(self.titleLab.snp.bottom).offset(0).priority(.low)
                    make.height.equalTo(0)
                    make.width.equalTo(0)
                }
            }
        }
    }

    /// Computes the pill size by measuring the inner labels + icon + paddings.
    func computeReplyPillSize() -> CGSize {
        let isMedia = BWReplyView.isFileReply(model)
        let prefixText = "回复："
        let nameText = BWReplyView.replyDisplayText(model)
        let font = UIFont.systemFont(ofSize: BWReplyView.fontSize)
        let prefixWidth = (prefixText as NSString).size(withAttributes: [.font: font]).width
        let nameWidth = (nameText as NSString).size(withAttributes: [.font: font]).width

        let iconWidth: CGFloat = isMedia ? BWReplyView.iconSize + BWReplyView.iconTrailingSpacing : 0
        let totalContent = prefixWidth + iconWidth + nameWidth
        let totalWidth = ceil(totalContent) + BWReplyView.horizontalPadding * 2
        let maxWidth = msgMaxWidth
        return CGSize(width: min(totalWidth, maxWidth), height: BWReplyView.pillHeight)
    }

    func updateBgConstraints() {
        let maxSize = CGSize(width: msgMaxWidth, height: CGFloat.greatestFiniteMagnitude)
        let size = self.titleLab.sizeThatFits(maxSize)

        let bubbleMargin: CGFloat = 4
        let replyContent = (replyView.fileNameLab.text ?? "")
        let hasReply = !replyContent.isEmpty
        let pillGap: CGFloat = hasReply ? 6 : 0
        let pillHeight: CGFloat = hasReply ? BWReplyView.pillHeight : 0

        self.contentBgView.snp.updateConstraints { make in
            make.width.equalTo(size.width)
            make.height.equalTo(size.height + pillGap + pillHeight + bubbleMargin)
        }
    }
    
    func displayIconImg(path: String) {
        let imgUrl = URL(string: "\(baseUrlImage)\(path)")
        self.iconView.kf.setImage(with: imgUrl)
    }
    

    func initTitle(msg: CommonMessage) {
        self.titleLab.isHidden = false
        let text = msg.content.data
        if text.contains("[emoticon_") == true {
            let atttext = BEmotionHelper.shared.attributedStringByText(text: text, font: self.titleLab.font)
            let mutable = NSMutableAttributedString(attributedString: atttext)
            self.detectedLinks = BWLinkDetector.applyLinks(to: mutable, linkColor: self.linkColor)
            self.titleLab.attributedText = mutable
        } else {
            let baseTextColor = self.titleLab.textColor ?? .label
            let (attributed, links) = BWLinkDetector.makeAttributedString(
                from: text,
                font: self.titleLab.font,
                textColor: baseTextColor,
                linkColor: self.linkColor
            )
            self.detectedLinks = links
            self.titleLab.attributedText = attributed
        }
        self.updateBgConstraints()
    }

    @objc private func handleLinkTap(_ tap: UITapGestureRecognizer) {
        guard !self.detectedLinks.isEmpty,
              let attributed = self.titleLab.attributedText else { return }

        let textStorage = NSTextStorage(attributedString: attributed)
        let layoutManager = NSLayoutManager()
        let insets = self.titleLab.textInsets
        let containerSize = CGSize(
            width: max(self.titleLab.bounds.width - insets.left * 2, 0),
            height: max(self.titleLab.bounds.height - insets.bottom * 2, 0)
        )
        let textContainer = NSTextContainer(size: containerSize)
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        textContainer.lineFragmentPadding = 0
        textContainer.lineBreakMode = self.titleLab.lineBreakMode
        textContainer.maximumNumberOfLines = self.titleLab.numberOfLines

        var location = tap.location(in: self.titleLab)
        location.x -= insets.left
        location.y -= insets.bottom

        let charIndex = layoutManager.characterIndex(
            for: location,
            in: textContainer,
            fractionOfDistanceBetweenInsertionPoints: nil
        )

        guard charIndex >= 0, charIndex < attributed.length else { return }

        for link in self.detectedLinks where NSLocationInRange(charIndex, link.range) {
            if UIApplication.shared.canOpenURL(link.url) {
                UIApplication.shared.open(link.url, options: [:], completionHandler: nil)
            }
            return
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

        
    @objc func dismissFullscreenImage(_ sender: UITapGestureRecognizer) {
        UIView.animate(withDuration: 0.35, animations: {
            self.blackBackgroundView.alpha = 0
            sender.view?.alpha = 0
        }, completion: { _ in
            sender.view?.removeFromSuperview()
            self.blackBackgroundView.removeFromSuperview()
        })
    }

    /// 把阴影应用到指定 view 的 layer (调用前确保 view.layer.masksToBounds = false)
    func applyBubbleShadow(_ shadow: ChatTheme.BubbleShadow, to view: UIView) {
        view.layer.shadowColor = shadow.color.cgColor
        view.layer.shadowOpacity = shadow.opacity
        view.layer.shadowRadius = shadow.radius
        view.layer.shadowOffset = shadow.offset
    }
}

class BWChatLeftCell: BWChatCell {
    required init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.titleLab.backgroundColor = .clear
        self.titleLab.layer.backgroundColor = UIColor.white.cgColor
        self.titleLab.textColor = .black
        self.titleLab.layer.cornerRadius = 18
        if #available(iOS 11.0, *) {
            self.titleLab.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        }
        self.arrowView.isHidden = true
        self.iconView.image = UIImage.svgInit("icon_server_def2")
        self.iconView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(12)
            make.top.equalToSuperview().offset(34) // 加大cell之间的上下间距
            make.width.height.equalTo(iconWidth)
        }

        self.timeLab.snp.makeConstraints { make in
            make.left.equalTo(self.iconView.snp.right).offset(16)
            make.top.equalToSuperview().offset(22)
            make.right.equalToSuperview().offset(-12)
            make.height.equalTo(20)
        }
        
        self.titleLab.snp.makeConstraints { make in
            make.top.equalTo(self.timeLab.snp.bottom)
            make.left.equalTo(self.contentBgView)//.offset(4)
            //make.right.equalTo(self.contentBgView).offset(2)
            make.width.lessThanOrEqualTo(msgMaxWidth)
            make.bottom.lessThanOrEqualTo(self.contentBgView).offset(-4) // Allow vertical growth
        }
        
        self.replyView.snp.makeConstraints { make in
            make.top.equalTo(self.titleLab.snp.bottom).offset(6).priority(.low)
            make.left.equalTo(self.arrowView.snp.right)
            make.height.equalTo(0)
            make.width.equalTo(0)
            make.bottom.equalToSuperview()
        }

        //let image = UIImage.svgInit("left_chat_bg") // UIImage(named: "left_chat_bg", in: BundleUtil.getCurrentBundle(), compatibleWith: nil)
        // 表示图像的四边各保留 15 点，不被拉伸，拉伸的部分是图像的中心区域
        //let insets = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
        //self.contentBgView.image = image?.resizableImage(withCapInsets: insets, resizingMode: .stretch)
        self.contentBgView.snp.makeConstraints { make in
            make.left.equalTo(self.timeLab.snp.left)
            make.top.equalTo(self.timeLab.snp.bottom).offset(0)
            make.height.equalTo(95)
            make.width.equalTo(32)
        }
        self.arrowView.image = UIImage.svgInit("ic_left_point")
        self.arrowView.snp.makeConstraints { make in
            make.right.equalTo(self.contentBgView.snp.left).offset(1)
            make.top.equalTo(self.contentBgView.snp.top).offset(4)
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

typealias BWChatRightCellResendBlock = (String) -> ()

class BWChatRightCell: BWChatCell {
    var resendBlock: BWChatRightCellResendBlock?

    override var linkColor: UIColor {
        // Right bubble has a colored background with white text;
        // use a light cyan so the link stays readable.
        UIColor(red: 0.85, green: 0.95, blue: 1.0, alpha: 1.0)
    }

    lazy var loadingView: UIImageView = {
        let img = UIImageView(frame: CGRect.zero)
        return img
    }()
    
    required init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.iconView.image = UIImage.svgInit("icon_server_def2")
        self.titleLab.backgroundColor = .clear
        self.titleLab.layer.backgroundColor = blueColor.cgColor
        self.titleLab.layer.cornerRadius = 18
        if #available(iOS 11.0, *) {
            self.titleLab.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        }
        self.arrowView.isHidden = true
        //self.contentBgView.backgroundColor = UIColor.red
        
        self.iconView.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-12)
            make.top.equalToSuperview().offset(34) // 加大cell之间的上下间距
            make.width.height.equalTo(iconWidth)
        }
        self.timeLab.snp.makeConstraints { make in
            make.top.equalTo(self.iconView.snp.top).offset(-12)
            make.right.equalTo(self.iconView.snp.left).offset(-16)
            make.height.equalTo(20)
        }
        
        self.arrowView.image = UIImage.svgInit("ic_right_point")
        self.arrowView.snp.makeConstraints { make in
            make.left.equalTo(self.contentBgView.snp.right).offset(-1)
            make.top.equalTo(self.contentBgView.snp.top).offset(4)
        }

        self.titleLab.snp.makeConstraints { make in
            make.top.equalTo(self.timeLab.snp.bottom)
            //make.left.equalTo(self.contentBgView).offset(4)
            make.right.equalTo(self.contentBgView)//.offset(-1)
            make.width.lessThanOrEqualTo(msgMaxWidth)
            make.bottom.lessThanOrEqualTo(self.contentBgView).offset(-4) // Allow vertical growth
        }
        
        self.replyView.snp.makeConstraints { make in
            make.top.equalTo(self.titleLab.snp.bottom).offset(6).priority(.low)
            make.right.equalTo(self.arrowView.snp.left)
            make.height.equalTo(0)
            make.width.equalTo(0)
            make.bottom.equalToSuperview()
        }
                
        self.contentView.addSubview(self.loadingView)
        self.loadingView.snp.makeConstraints { make in
            make.top.equalTo(self.timeLab.snp.bottom).offset(0)
            make.right.equalTo(self.titleLab.snp.left).offset(-10)
            make.width.height.equalTo(20)
        }
        
       // let image = UIImage.svgInit("right_chat_bg")
        //let insets = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
        //self.contentBgView.image = image?.resizableImage(withCapInsets: insets, resizingMode: .stretch)
        
        //self.contentBgView.image = image
        self.contentBgView.snp.makeConstraints { make in
            make.right.equalTo(self.timeLab.snp.right)
            make.top.equalTo(self.timeLab.snp.bottom).offset(-0)
            make.height.equalTo(95)
            make.width.equalTo(32)
        }
        
       
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.clickErrorIcon))
        // tapGesture.cancelsTouchesInView = false
        self.loadingView.addGestureRecognizer(tapGesture)
        self.loadingView.isUserInteractionEnabled = true
    }

    @objc func clickErrorIcon() {
        print("Resend tapped")
        self.resendBlock!(self.titleLab.text ?? "")
    }
    
    override func initTitle(msg: CommonMessage) {
        super.initTitle(msg: msg)
        self.initLoadingForTitle()
    }
    
    func initLoadingForTitle() {
        self.loadingView.snp.updateConstraints { make in
            make.right.equalTo(self.titleLab.snp.left).offset(-10)
        }
        self.initLoadingicon()
    }

    func initLoadingForImage() {
        self.loadingView.snp.updateConstraints { make in
            make.right.equalTo(self.titleLab.snp.left).offset(-kScreenWidth + 88)
        }
        self.initLoadingicon()
    }
    
    func initLoadingicon() {
        let path = BundleUtil.getCurrentBundle().path(forResource: "clock", ofType: "gif")
        let url = URL(fileURLWithPath: path!)
        let provider = LocalFileImageDataProvider(fileURL: url)
        if model?.sendStatus == .发送中 {
            self.loadingView.kf.setImage(with: provider)
            self.loadingView.isHidden = false
        } else if model?.sendStatus == .发送成功 {
            self.loadingView.isHidden = true
        } else if model?.sendStatus == .发送失败 {
            self.loadingView.image = UIImage.svgInit("h5_shibai")
            self.loadingView.isHidden = false
        } else {
            self.loadingView.kf.setImage(with: provider)
            self.loadingView.isHidden = false
        }
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

// MARK: - Theming

extension BWChatLeftCell: ChatThemable {
    func applyTheme(_ theme: ChatTheme) {
        titleLab.backgroundColor = .clear
        titleLab.layer.backgroundColor = theme.leftBubbleColor.cgColor
        titleLab.textColor = theme.leftBubbleTextColor
        titleLab.layer.cornerRadius = 18
        if #available(iOS 11.0, *) {
            titleLab.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        }
        arrowView.isHidden = true
        applyBubbleShadow(theme.bubbleShadow, to: titleLab)
    }
}

extension BWChatRightCell: ChatThemable {
    func applyTheme(_ theme: ChatTheme) {
        titleLab.backgroundColor = .clear
        titleLab.layer.backgroundColor = theme.rightBubbleColor.cgColor
        titleLab.textColor = theme.rightBubbleTextColor
        titleLab.layer.cornerRadius = 18
        if #available(iOS 11.0, *) {
            titleLab.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        }
        arrowView.isHidden = true
        applyBubbleShadow(theme.bubbleShadow, to: titleLab)
    }
}
