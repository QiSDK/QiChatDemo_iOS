//
//  BWReplyView.swift
//  TeneasyChatSDKUI_iOS
//
//  Created by Xiao Fu on 2025/3/5.
//

import TeneasyChatSDK_iOS

class BWReplyView: UIView {
    var cellTapedGesture: BWShowOriginalClickBlock?

    static let pillHeight: CGFloat = 32
    static let horizontalPadding: CGFloat = 12
    static let iconSize: CGFloat = 18
    static let iconTrailingSpacing: CGFloat = 6
    static let fontSize: CGFloat = 13

    lazy var replyLab: UILabel = {
        let lab = UILabel()
        lab.textColor = UIColor.black.withAlphaComponent(0.54)
        lab.font = UIFont.systemFont(ofSize: BWReplyView.fontSize)
        lab.text = "回复："
        lab.setContentHuggingPriority(.required, for: .horizontal)
        lab.setContentCompressionResistancePriority(.required, for: .horizontal)
        return lab
    }()

    lazy var fileIcon: UIImageView = {
        let img = UIImageView()
        img.contentMode = .scaleAspectFit
        img.setContentHuggingPriority(.required, for: .horizontal)
        img.setContentCompressionResistancePriority(.required, for: .horizontal)
        return img
    }()

    lazy var fileNameLab: UILabel = {
        let lab = UILabel()
        lab.font = UIFont.systemFont(ofSize: BWReplyView.fontSize)
        lab.textColor = UIColor.black.withAlphaComponent(0.54)
        lab.lineBreakMode = .byTruncatingTail
        lab.numberOfLines = 1
        // 空间不够时让文件名/内容截断，而不是反过来挤压"回复："和图标。
        lab.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        lab.setContentHuggingPriority(.defaultLow, for: .horizontal)
        return lab
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
        setupConstraints()
    }

    private func setupViews() {
        self.backgroundColor = kHexColor(0xE5E5E5)
        self.layer.cornerRadius = 8
        self.layer.masksToBounds = true

        self.addSubview(self.replyLab)
        self.addSubview(self.fileIcon)
        self.addSubview(self.fileNameLab)
    }

    private func setupConstraints() {
        self.replyLab.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(BWReplyView.horizontalPadding).priority(.high)
            make.centerY.equalToSuperview()
        }

        self.fileIcon.snp.makeConstraints { make in
            make.left.equalTo(self.replyLab.snp.right).priority(.high)
            make.centerY.equalToSuperview()
            make.height.equalTo(BWReplyView.iconSize)
            // 必须 required：fileIcon 是 UIImageView，带图后其 intrinsic 尺寸 = 图片像素尺寸
            // （image_default ~513px）。若用 .high，约束会被打破、图标撑成几百 px 把其它 view 挤出可视区。
            make.width.equalTo(BWReplyView.iconSize)
        }

        self.fileNameLab.snp.makeConstraints { make in
            make.left.equalTo(self.fileIcon.snp.right).offset(BWReplyView.iconTrailingSpacing).priority(.high)
            make.centerY.equalToSuperview()
            make.right.lessThanOrEqualToSuperview().offset(-BWReplyView.horizontalPadding).priority(.high)
        }
    }

    var model: ChatModel? {
        didSet {
            let fileName = model?.replyItem?.fileName ?? ""

            // `getReplyItem` 只给图片/视频/文件消息填 fileName，给文字消息填 content。
            // 所以 fileName 是否为空就是"媒体/文件 vs 文字"的判据，
            // 不再用扩展名去猜（webp、无扩展名的视频 uri 等会猜错，导致图标丢失）。
            if BWReplyView.isFileReply(model) {
                self.fileIcon.isHidden = false
                self.fileIcon.image = BWReplyView.thumbnail(forFileName: fileName)
                self.fileIcon.snp.updateConstraints { make in
                    make.width.equalTo(BWReplyView.iconSize)
                }
                self.fileNameLab.snp.updateConstraints { make in
                    make.left.equalTo(self.fileIcon.snp.right).offset(BWReplyView.iconTrailingSpacing).priority(.high)
                }
                self.fileNameLab.text = BWReplyView.replyDisplayText(model)
            } else {
                self.fileIcon.isHidden = true
                self.fileIcon.image = nil
                self.fileIcon.snp.updateConstraints { make in
                    make.width.equalTo(0)
                }
                self.fileNameLab.snp.updateConstraints { make in
                    make.left.equalTo(self.fileIcon.snp.right).offset(0).priority(.high)
                }
                // 先清掉复用 cell 残留的 attributedText（表情回复会往这里塞图片），
                // 否则切到纯文字回复时旧表情会残留 / 盖住新文字。
                self.fileNameLab.attributedText = nil
                self.fileNameLab.text = model?.replyItem?.content
            }

            self.setNeedsLayout()
        }
    }

    /// 复用 cell 前重置，避免上一条消息的回复气泡残留成一个空灰条。
    func reset() {
        self.fileIcon.isHidden = true
        self.fileIcon.image = nil
        self.fileNameLab.attributedText = nil
        self.fileNameLab.text = nil
        self.isHidden = true
    }

    // MARK: - 共享的回复气泡布局判据（被 BWChatCell / BWImageCell / BWFileCell 复用，避免逻辑漂移）

    /// 图片扩展名（图标选择用本地白名单，不依赖 SDK 里不透明的 imageTypes）。
    static let imageExtensions: Set<String> = [
        "jpg", "jpeg", "png", "gif", "webp", "bmp", "heic", "heif", "tiff", "tif", "svg", "ico"
    ]
    /// 视频扩展名。
    static let videoExtensions: Set<String> = [
        "mp4", "mov", "m4v", "avi", "mkv", "flv", "wmv", "3gp", "webm", "m3u8", "ts", "hls"
    ]

    /// 是否是"媒体/文件"类回复（图片/视频/文件），由 replyItem.fileName 是否存在决定。
    static func isFileReply(_ model: ChatModel?) -> Bool {
        return !((model?.replyItem?.fileName ?? "").isEmpty)
    }

    /// 是否有"可显示"的回复内容。媒体一定有（图标+文件名）；
    /// 文字则要求去掉首尾空白后非空，避免空白/占位内容渲染成一个空气泡。
    static func hasDisplayableReply(_ model: ChatModel?) -> Bool {
        if isFileReply(model) { return true }
        let content = (model?.replyItem?.content ?? "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        return !content.isEmpty
    }

    /// 回复气泡里图标后面要显示的文字：媒体取文件名，文字取内容。
    static func replyDisplayText(_ model: ChatModel?) -> String {
        let fileName = model?.replyItem?.fileName ?? ""
        if !fileName.isEmpty {
            return fileName.split(separator: "/").last.map(String.init) ?? fileName
        }
        return model?.replyItem?.content ?? ""
    }

    /// 根据文件名/扩展名选默认图标，未知类型回退到 unknown_default。
    static func thumbnail(forFileName fileName: String) -> UIImage? {
        let ext = (fileName.split(separator: ".").last ?? "").lowercased()
        let bundle = BundleUtil.getCurrentBundle()
        if imageExtensions.contains(ext) {
            return UIImage(named: "image_default", in: bundle, compatibleWith: nil)
        } else if videoExtensions.contains(ext) {
            return UIImage(named: "video_default", in: bundle, compatibleWith: nil)
        } else if ext == "pdf" {
            return UIImage(named: "pdf_default", in: bundle, compatibleWith: nil)
        } else if ext == "xls" || ext == "xlsx" || ext == "csv" {
            return UIImage(named: "excel_default", in: bundle, compatibleWith: nil)
        } else if ext == "doc" || ext == "docx" {
            return UIImage(named: "word_default", in: bundle, compatibleWith: nil)
        }
        return UIImage(named: "unknown_default", in: bundle, compatibleWith: nil)
    }

    func getFileThumbnail(path: String) -> UIImage? {
        return BWReplyView.thumbnail(forFileName: path)
    }

    /// Returns true if there is reply content to display.
    func hasContent(for model: ChatModel?) -> Bool {
        let content = model?.replyItem?.content ?? ""
        let fileName = model?.replyItem?.fileName ?? ""
        return !content.isEmpty || !fileName.isEmpty
    }
}

class BWReplyViewLeft: BWReplyView {
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
