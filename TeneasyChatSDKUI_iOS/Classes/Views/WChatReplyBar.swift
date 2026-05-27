//
//  WChatReplyBar.swift
//  qixin
//
//  Created by Xiao Fu on 2022/10/17.
//

import UIKit
import SnapKit
import TeneasyChatSDK_iOS

class WChatReplyBar: WBaseView {
    var msg: CommonMessage? = nil

    private static let horizontalPadding: CGFloat = 12
    private static let iconSize: CGFloat = 18
    private static let iconTrailingSpacing: CGFloat = 6
    private static let fontSize: CGFloat = 14
    private static let verticalPadding: CGFloat = 10

    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "回复："
        label.textColor = kHexColor(0x666666)
        label.font = UIFont.systemFont(ofSize: WChatReplyBar.fontSize)
        label.textAlignment = .left
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        return label
    }()

    lazy var fileIcon: UIImageView = {
        let v = UIImageView()
        v.contentMode = .scaleAspectFit
        v.setContentHuggingPriority(.required, for: .horizontal)
        v.setContentCompressionResistancePriority(.required, for: .horizontal)
        v.isHidden = true
        return v
    }()

    lazy var contentLabel: UILabel = {
        let label = UILabel()
        label.textColor = kHexColor(0x666666)
        label.font = UIFont.systemFont(ofSize: WChatReplyBar.fontSize)
        label.textAlignment = .left
        label.lineBreakMode = .byTruncatingTail
        label.numberOfLines = 1
        return label
    }()

    lazy var closeButton: UIButton = {
        let button = UIButton(type: .custom)
        let image = UIImage.svgInit("close")
        button.setImage(image, for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        return button
    }()

    override func initConfig() {
        backgroundColor = kHexColor(0xE5E5E5)
    }

    override func initSubViews() {
        self.snp.makeConstraints { make in
            make.height.equalTo(37)
        }

        addSubview(closeButton)
        closeButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-10)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(22)
        }

        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(WChatReplyBar.horizontalPadding)
            make.top.equalToSuperview().offset(WChatReplyBar.verticalPadding)
            make.bottom.equalToSuperview().offset(-WChatReplyBar.verticalPadding)
        }

        addSubview(fileIcon)
        fileIcon.snp.makeConstraints { make in
            make.left.equalTo(titleLabel.snp.right)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(WChatReplyBar.iconSize)
        }

        addSubview(contentLabel)
        contentLabel.snp.makeConstraints { make in
            make.left.equalTo(fileIcon.snp.right)
            make.centerY.equalToSuperview()
            make.right.lessThanOrEqualTo(closeButton.snp.left).offset(-8)
        }
    }

    override func initBindModel() {}

    func updateUI(with chatModel: ChatModel) {
        msg = chatModel.message
        titleLabel.text = "回复："

        let fileUri = msg?.file.uri ?? ""
        let imageUri = msg?.image.uri ?? ""
        let videoUri = msg?.video.uri ?? ""

        if !fileUri.isEmpty {
            showMediaIcon(forPath: fileUri)
            contentLabel.text = displayName(from: fileUri)
        } else if !imageUri.isEmpty {
            showMediaIcon(forPath: imageUri)
            contentLabel.text = displayName(from: imageUri)
        } else if !videoUri.isEmpty {
            showMediaIcon(forPath: videoUri)
            contentLabel.text = displayName(from: videoUri)
        } else {
            hideMediaIcon()
            var text = msg?.content.data ?? ""
            if text.contains("\"imgs\"") {
                if let result = JSONCoding.decode(TextImages.self, from: text) {
                    text = result.message
                }
            } else if msg?.msgSourceType == .mstSystemCustomer || msg?.msgSourceType == .mstSystemWorker {
                if let result = JSONCoding.decode(TextBody.self, from: text) {
                    text = result.content ?? text
                }
            }
            contentLabel.text = text
        }
    }

    private func showMediaIcon(forPath path: String) {
        fileIcon.isHidden = false
        fileIcon.image = mediaThumbnail(forPath: path)
        fileIcon.snp.updateConstraints { make in
            make.width.equalTo(WChatReplyBar.iconSize)
        }
        contentLabel.snp.updateConstraints { make in
            make.left.equalTo(fileIcon.snp.right).offset(WChatReplyBar.iconTrailingSpacing)
        }
    }

    private func hideMediaIcon() {
        fileIcon.isHidden = true
        fileIcon.image = nil
        fileIcon.snp.updateConstraints { make in
            make.width.equalTo(0)
        }
        contentLabel.snp.updateConstraints { make in
            make.left.equalTo(fileIcon.snp.right).offset(0)
        }
    }

    private func displayName(from path: String) -> String {
        return path.split(separator: "/").last.map(String.init) ?? path
    }

    private func mediaThumbnail(forPath path: String) -> UIImage? {
        let ext = (path.split(separator: ".").last ?? "").lowercased()
        if imageTypes.contains(ext) {
            return UIImage(named: "image_default", in: BundleUtil.getCurrentBundle(), compatibleWith: nil)
        } else if videoTypes.contains(ext) {
            return UIImage(named: "video_default", in: BundleUtil.getCurrentBundle(), compatibleWith: nil)
        } else if ext == "pdf" {
            return UIImage(named: "pdf_default", in: BundleUtil.getCurrentBundle(), compatibleWith: nil)
        } else if ext == "xls" || ext == "xlsx" || ext == "csv" {
            return UIImage(named: "excel_default", in: BundleUtil.getCurrentBundle(), compatibleWith: nil)
        } else if ext == "doc" || ext == "docx" {
            return UIImage(named: "word_default", in: BundleUtil.getCurrentBundle(), compatibleWith: nil)
        }
        return UIImage(named: "unknown_default", in: BundleUtil.getCurrentBundle(), compatibleWith: nil)
    }
}
