//
//  BWAutoCardCell.swift
//  TeneasyChatSDKUI_iOS
//
//  渲染 msgSourceType == .mstAutoCard 的卡片消息。
//
//  消息体（message.content.data）是一条 ServiceKeyword 的 JSON：
//  - 标题 = subject；
//  - content 为数组（questionType 1）→ 渲染成一组可点选项按钮；
//  - content 为字符串（questionType 2）→ 渲染成正文段落 + 一个按钮。
//
//  点击任一按钮时通过 optionTapBlock 把选项文本当普通消息发送。
//  Cell 走 UITableView.automaticDimension 自适应高度。
//

import Foundation
import UIKit

typealias BWAutoCardOptionTapCallBack = (String) -> ()
typealias BWAutoCardJumpTapCallBack = (String, Int?) -> ()

class BWAutoCardCell: UITableViewCell {

    var optionTapBlock: BWAutoCardOptionTapCallBack?
    /// 点击带 jumpUrl 的卡片按钮时回调（jumpUrl, jumpCategory）。
    var jumpTapBlock: BWAutoCardJumpTapCallBack?
    private var currentTheme: ChatTheme = .default

    lazy var iconView: UIImageView = {
        let img = UIImageView()
        img.layer.cornerRadius = iconWidth * 0.5
        img.layer.masksToBounds = true
        return img
    }()

    lazy var timeLab: UILabel = {
        let lab = UILabel()
        lab.font = UIFont.systemFont(ofSize: 13)
        if #available(iOS 13.0, *) {
            lab.textColor = UIColor.systemGray2
        }
        lab.lineBreakMode = .byTruncatingTail
        return lab
    }()

    /// 卡片气泡容器
    lazy var bubble: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 12
        v.layer.masksToBounds = true
        return v
    }()

    lazy var subjectLab: UILabel = {
        let lab = UILabel()
        lab.font = UIFont.boldSystemFont(ofSize: 16)
        lab.numberOfLines = 0
        return lab
    }()

    lazy var contentLab: UILabel = {
        let lab = UILabel()
        lab.font = UIFont.systemFont(ofSize: 13)
        lab.numberOfLines = 0
        return lab
    }()

    /// 右侧配图（精准问题 rightImageUrl）。无图时不加入布局。
    lazy var rightImageView: UIImageView = {
        let img = UIImageView()
        img.contentMode = .scaleAspectFill
        img.layer.cornerRadius = 8
        img.layer.masksToBounds = true
        return img
    }()

    /// 竖向堆叠：标题 + 正文（作为 headerRow 的左列）
    lazy var textVStack: UIStackView = {
        let s = UIStackView()
        s.axis = .vertical
        s.alignment = .fill
        s.spacing = 8
        return s
    }()

    /// 横向堆叠：左列文字 + 右侧配图
    lazy var headerRow: UIStackView = {
        let s = UIStackView()
        s.axis = .horizontal
        s.alignment = .top
        s.spacing = 10
        return s
    }()

    /// 竖向堆叠：headerRow + 选项按钮
    lazy var stack: UIStackView = {
        let s = UIStackView()
        s.axis = .vertical
        s.alignment = .fill
        s.spacing = 8
        return s
    }()

    static func cell(tableView: UITableView) -> Self {
        let cellId = "\(Self.self)"
        var cell = tableView.dequeueReusableCell(withIdentifier: cellId)
        if cell == nil {
            cell = Self(style: .default, reuseIdentifier: cellId)
        }
        cell?.backgroundColor = .clear
        return cell as! Self
    }

    override required init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        iconView.image = UIImage.svgInit("icon_server_def2")
        contentView.addSubview(iconView)
        iconView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(12)
            make.top.equalToSuperview().offset(12)
            make.width.height.equalTo(iconWidth)
        }

        contentView.addSubview(timeLab)
        timeLab.snp.makeConstraints { make in
            make.left.equalTo(iconView.snp.right).offset(16)
            make.top.equalToSuperview().offset(8)
            make.right.equalToSuperview().offset(-12)
        }

        contentView.addSubview(bubble)
        bubble.snp.makeConstraints { make in
            make.left.equalTo(timeLab.snp.left)
            make.top.equalTo(timeLab.snp.bottom).offset(5)
            make.right.lessThanOrEqualToSuperview().offset(-40)
            // 自适应高度的关键：底部约束到 contentView
            make.bottom.equalToSuperview().offset(-10)
        }

        bubble.addSubview(stack)
        stack.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 14, left: 16, bottom: 14, right: 16))
        }
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    func displayIconImg(path: String) {
        let imgUrl = URL(string: "\(baseUrlImage)\(path)")
        iconView.kf.setImage(with: imgUrl)
    }

    var model: ChatModel? {
        didSet {
            guard let msg = model?.message else { return }
            timeLab.text = msg.msgTime.date.toString(format: "yyyy-MM-dd HH:mm:ss")
            let card = ServiceKeyword.from(jsonString: msg.content.data)
            rebuild(card: card, raw: msg.content.data)
            applyTheme(currentTheme)
        }
    }

    private func rebuild(card: ServiceKeyword?, raw: String) {
        // 清空旧内容
        stack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        textVStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        headerRow.arrangedSubviews.forEach { $0.removeFromSuperview() }

        guard let card = card else {
            // 兜底：当普通文本展示
            contentLab.text = raw
            stack.addArrangedSubview(contentLab)
            return
        }

        if let subject = card.subject, !subject.isEmpty {
            subjectLab.text = subject
            textVStack.addArrangedSubview(subjectLab)
        }

        if !card.contentText.isEmpty {
            contentLab.text = card.contentText
            textVStack.addArrangedSubview(contentLab)
        }

        // 标题 + 正文（+ 精准问题右侧配图）作为顶部一行
        headerRow.addArrangedSubview(textVStack)
        let imageUrl = (card.rightImageUrl ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        if !imageUrl.isEmpty {
            let full = imageUrl.hasPrefix("http") ? imageUrl : "\(baseUrlImage)\(imageUrl)"
            rightImageView.kf.setImage(with: URL(string: full))
            headerRow.addArrangedSubview(rightImageView)
            rightImageView.snp.remakeConstraints { make in
                make.width.height.equalTo(64)
            }
        }
        stack.addArrangedSubview(headerRow)

        // questionType 1：每个选项一个按钮
        for opt in card.options {
            stack.addArrangedSubview(makeOptionButton(title: opt, sendText: opt))
        }
        // questionType 2：无选项数组时给一个按钮。
        // hasJump（jumpCategory 非 0 且 jumpUrl 非空）→ 请求跳转；否则回退成发送 subject。
        if card.options.isEmpty, let subject = card.subject, !subject.isEmpty {
            if card.hasJump {
                stack.addArrangedSubview(
                    makeJumpButton(title: subject, jumpUrl: card.jumpUrl ?? "", jumpCategory: card.jumpCategory))
            } else {
                stack.addArrangedSubview(makeOptionButton(title: subject, sendText: subject))
            }
        }
    }

    private func styleButton(_ btn: UIButton, title: String) {
        btn.setTitle(title, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = currentTheme.tintColor
        btn.layer.cornerRadius = 10
        btn.layer.masksToBounds = true
        btn.contentEdgeInsets = UIEdgeInsets(top: 10, left: 12, bottom: 10, right: 12)
        btn.snp.makeConstraints { make in
            make.height.greaterThanOrEqualTo(44)
        }
    }

    private func makeOptionButton(title: String, sendText: String) -> UIButton {
        let btn = UIButton(type: .system)
        styleButton(btn, title: title)
        // 用 accessibilityValue 暂存发送文本，避免闭包捕获歧义
        btn.accessibilityValue = sendText
        btn.addTarget(self, action: #selector(onOptionTap(_:)), for: .touchUpInside)
        return btn
    }

    private func makeJumpButton(title: String, jumpUrl: String, jumpCategory: Int?) -> UIButton {
        let btn = UIButton(type: .system)
        styleButton(btn, title: title)
        // accessibilityValue 暂存 jumpUrl，tag 暂存 jumpCategory（-1 代表 nil）
        btn.accessibilityValue = jumpUrl
        btn.tag = jumpCategory ?? -1
        btn.addTarget(self, action: #selector(onJumpTap(_:)), for: .touchUpInside)
        return btn
    }

    @objc private func onOptionTap(_ sender: UIButton) {
        let text = sender.accessibilityValue ?? (sender.title(for: .normal) ?? "")
        if !text.isEmpty {
            optionTapBlock?(text)
        }
    }

    @objc private func onJumpTap(_ sender: UIButton) {
        let url = sender.accessibilityValue ?? ""
        if url.isEmpty { return }
        let category: Int? = sender.tag < 0 ? nil : sender.tag
        jumpTapBlock?(url, category)
    }
}

// MARK: - Theming

extension BWAutoCardCell: ChatThemable {
    func applyTheme(_ theme: ChatTheme) {
        currentTheme = theme
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        bubble.backgroundColor = theme.leftBubbleColor
        subjectLab.textColor = theme.leftBubbleTextColor
        contentLab.textColor = theme.tintColor
        stack.arrangedSubviews.compactMap { $0 as? UIButton }.forEach {
            $0.backgroundColor = theme.tintColor
        }
    }
}
