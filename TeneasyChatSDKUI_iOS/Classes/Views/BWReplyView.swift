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
            make.width.equalTo(BWReplyView.iconSize).priority(.high)
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
            let ext = (fileName.split(separator: ".").last ?? "").lowercased()
            let isMedia = fileTypes.contains(ext) || imageTypes.contains(ext) || videoTypes.contains(ext)

            if isMedia {
                self.fileIcon.isHidden = false
                self.fileIcon.image = getFileThumbnail(path: ext)
                self.fileIcon.snp.updateConstraints { make in
                    make.width.equalTo(BWReplyView.iconSize).priority(.high)
                }
                self.fileNameLab.snp.updateConstraints { make in
                    make.left.equalTo(self.fileIcon.snp.right).offset(BWReplyView.iconTrailingSpacing).priority(.high)
                }
                let displayName = fileName.split(separator: "/").last.map(String.init) ?? fileName
                self.fileNameLab.text = displayName
            } else {
                self.fileIcon.isHidden = true
                self.fileIcon.image = nil
                self.fileIcon.snp.updateConstraints { make in
                    make.width.equalTo(0).priority(.high)
                }
                self.fileNameLab.snp.updateConstraints { make in
                    make.left.equalTo(self.fileIcon.snp.right).offset(0).priority(.high)
                }
                self.fileNameLab.text = model?.replyItem?.content
            }

            self.setNeedsLayout()
        }
    }

    func getFileThumbnail(path: String) -> UIImage? {
        let ext = (path.split(separator: ".").last ?? "").lowercased()
        var thumbnail = UIImage(named: "unknown_default", in: BundleUtil.getCurrentBundle(), compatibleWith: nil)
        if imageTypes.contains(ext) {
            thumbnail = UIImage(named: "image_default", in: BundleUtil.getCurrentBundle(), compatibleWith: nil)
        } else if videoTypes.contains(ext) {
            thumbnail = UIImage(named: "video_default", in: BundleUtil.getCurrentBundle(), compatibleWith: nil)
        } else if ext == "pdf" {
            thumbnail = UIImage(named: "pdf_default", in: BundleUtil.getCurrentBundle(), compatibleWith: nil)
        } else if ext == "xls" || ext == "xlsx" || ext == "csv" {
            thumbnail = UIImage(named: "excel_default", in: BundleUtil.getCurrentBundle(), compatibleWith: nil)
        } else if ext == "doc" || ext == "docx" {
            thumbnail = UIImage(named: "word_default", in: BundleUtil.getCurrentBundle(), compatibleWith: nil)
        }
        return thumbnail
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
