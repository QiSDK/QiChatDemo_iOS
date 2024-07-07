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

class BWChatCell: UITableViewCell {
    var gesture: UILongPressGestureRecognizer?
    var longGestCallBack: BWChatCellLongGestCallBack?
    
    lazy var timeLab: UILabel = {
        let lab = UILabel()
        lab.font = UIFont.systemFont(ofSize: 13)
        lab.textColor = .black
        lab.lineBreakMode = .byTruncatingTail
        return lab
    }()
    
    lazy var imgView: ResizableImageView = {
        let v = ResizableImageView()
        v.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapImg))
        v.addGestureRecognizer(tapGesture)
        return v
    }()

    lazy var titleLab: BWLabel = {
        let lab = BWLabel()
        lab.font = UIFont.systemFont(ofSize: 15)
        lab.textColor = .white
        lab.numberOfLines = 1000
        lab.textInsets = UIEdgeInsets(top: 8, left: 15, bottom: 8, right: 15)
        lab.preferredMaxLayoutWidth = kScreenWidth - 100 - iconWidth - 12
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
        return img
    }()
    
    lazy var failedDotView: UIImageView = {
        let v = UIImageView()
        return v
    }()
    
    lazy var replyQuoteLabel: BWLabel = {
        let lab = BWLabel()
        lab.font = UIFont.systemFont(ofSize: 15)
        lab.textColor = .black
        lab.numberOfLines = 1000
        lab.preferredMaxLayoutWidth = kScreenWidth - 100 - iconWidth - 12
        lab.backgroundColor = kHexColor(0xD7E8FD)
        lab.layer.cornerRadius = 4
        lab.layer.masksToBounds = true
        // 不可动态设置，会有复用问题
        lab.textInsets = UIEdgeInsets(top: 6, left: 15, bottom: 6, right: 15)
        return lab
    }()
    
    var iconWidth = 44.0
    var imgHeight = 160.0
    
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
        self.contentView.addSubview(self.replyQuoteLabel)
        self.contentView.addSubview(self.titleLab)
        self.contentView.addSubview(self.imgView)
        self.imgView.backgroundColor = UIColor.black
        self.imgView.contentMode = .scaleAspectFit
        self.imgView.snp.makeConstraints { make in
            self.leftConstraint = make.left.equalTo(self.titleLab.snp.left).constraint
            self.rightConstraint = make.right.equalTo(self.titleLab.snp.right).constraint
            // make.left.equalToSuperview().offset(12)
            // make.right.equalToSuperview().offset(-12)
            make.width.equalTo(kScreenWidth - 12 - 80)
            make.top.equalTo(self.timeLab.snp.bottom).offset(6)
            make.height.equalTo(imgHeight)
        }
        self.gesture = UILongPressGestureRecognizer(target: self, action: #selector(self.longGestureClick(tap:)))
        self.titleLab.isUserInteractionEnabled = true
        self.titleLab.addGestureRecognizer(self.gesture!)
    }

    @objc func longGestureClick(tap: UILongPressGestureRecognizer) {
        self.longGestCallBack?(tap)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
    }
    
    var model: ChatModel? {
        didSet {
            
            guard let msg = model?.message else {
                return
            }
            
            let quote = self.model?.replayQuote ?? ""
            if quote.contains("[emoticon_") == true {
                let atttext = BEmotionHelper.shared.attributedStringByText(text: quote, font: self.replyQuoteLabel.font)
                self.replyQuoteLabel.attributedText = atttext
            } else {
                self.replyQuoteLabel.text = quote
            }
            if (quote.isEmpty) {
                self.replyQuoteLabel.isHidden = true
                self.replyQuoteLabel.snp.updateConstraints { make in
                    make.top.equalTo(self.timeLab.snp.bottom).offset(0)
                    make.height.equalTo(0)
                }
            } else {
                let maxSizeQuote = CGSize(width: replyQuoteLabel.preferredMaxLayoutWidth, height: CGFloat.greatestFiniteMagnitude)
                let sizeQuote = self.replyQuoteLabel.sizeThatFits(maxSizeQuote)
                self.replyQuoteLabel.isHidden = false
                self.replyQuoteLabel.snp.updateConstraints { make in
                    make.top.equalTo(self.timeLab.snp.bottom).offset(8)
                    make.height.equalTo(sizeQuote.height)
                }
//                replyQuoteLabelHeightConstraint?.update(offset: UITableView.automaticDimension)
            }
            self.replyQuoteLabel.sizeToFit()
            self.replyQuoteLabel.layoutIfNeeded()
            self.replyQuoteLabel.setNeedsLayout()
            
            // 现在SDK并没有把时间传回来，所以暂时不用这样转换
            self.timeLab.text = msg.msgTime.date.toString(format: "yyyy-MM-dd HH:mm:ss")
       
            if msg.image.uri.isEmpty == false {
//                let imgUrl = URL(string: "https://images.pexels.com/photos/2444403/pexels-photo-2444403.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500")
                let imgUrl = URL(string: "\(baseUrlImage)\(msg.image.uri)")
                print(imgUrl?.absoluteString ?? "")
                if imgUrl != nil {
                    self.initImg(imgUrl: imgUrl!)
                } else {
                    self.initTitle(msg: msg)
                }
            } else {
                self.initTitle(msg: msg)
            }
            
        }
    }
    
    func updateBgConstraints() {
        let maxSize = CGSize(width: titleLab.preferredMaxLayoutWidth, height: CGFloat.greatestFiniteMagnitude)
        let size = self.titleLab.sizeThatFits(maxSize)
        let maxSizeQuote = CGSize(width: replyQuoteLabel.preferredMaxLayoutWidth, height: CGFloat.greatestFiniteMagnitude)
        let sizeQuote = self.replyQuoteLabel.sizeThatFits(maxSizeQuote)
        var margin = 12.0
        var quoteHeight = sizeQuote.height
        if (replyQuoteLabel.text?.isEmpty ?? true) {
            margin = 0
            quoteHeight = 0
        }
//        print(model?.replayQuote)
//        print(size.width)
//        print(sizeQuote.width)
        self.contentBgView.snp.updateConstraints { make in
            make.width.equalTo((size.width > sizeQuote.width + 24) ? size.width : sizeQuote.width + 24)
            make.height.equalTo(size.height + quoteHeight + margin) // 8 is margin
        }
    }

    func initImg(imgUrl: URL) {
        self.imgView.kf.setImage(with: imgUrl) { result in
            switch result {
            case .success(let value):
                // 获取图片尺寸
                let imageSize = value.image.size
                print("Image width: \(imageSize.width), height: \(imageSize.height)")
                let imageAspectRatio = imageSize.width / imageSize.height
                // 图片最大高度是160，按比例算宽度
                let width = self.imgHeight * imageAspectRatio
                self.imgView.snp.updateConstraints { make in
                    make.width.equalTo(width)
                }
                print(width)
                
                self.contentBgView.snp.updateConstraints { make in
                    make.width.equalTo(width + 12)
                    make.height.equalTo(self.imgHeight + 14)
                }
            case .failure(let error):
                print("Error: \(error)")
            }
        }
        self.titleLab.isHidden = true
        self.imgView.isHidden = false
    }

    func initTitle(msg: CommonMessage) {
        self.titleLab.isHidden = false
        self.imgView.isHidden = true
        
        if msg.content.data.contains("[emoticon_") == true {
            let atttext = BEmotionHelper.shared.attributedStringByText(text: msg.content.data, font: self.titleLab.font)
            self.titleLab.attributedText = atttext
            self.updateBgConstraints()
        } else {
            self.titleLab.text = msg.content.data
            // print("message text:" + (msg.content.data))
            self.updateBgConstraints()
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    @objc func handleTapImg() {
        if let window = UIApplication.shared.keyWindow {
            window.addSubview(self.blackBackgroundView)
            self.blackBackgroundView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
                
            let imageView = UIImageView(image: self.imgView.image)
            imageView.contentMode = .scaleAspectFit
            imageView.isUserInteractionEnabled = true
            window.addSubview(imageView)
            imageView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
                
            UIView.animate(withDuration: 0.75, animations: {
                self.blackBackgroundView.alpha = 1
                
            })
                
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissFullscreenImage))
            imageView.addGestureRecognizer(tapGesture)
        }
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
}

class BWChatLeftCell: BWChatCell {
    required init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
//        self.titleLab.backgroundColor = .white
        self.titleLab.textColor = .black
        self.iconView.image = UIImage.svgInit("icon_server_def2")
        self.iconView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(12)
            make.top.equalToSuperview().offset(34) // 加大cell之间的上下间距
            make.width.height.equalTo(iconWidth)
        }

        self.timeLab.snp.makeConstraints { make in
            make.left.equalTo(self.iconView.snp.right).offset(16)
            make.top.equalTo(self.iconView.snp.top).offset(-12)
            make.right.equalToSuperview().offset(-12)
            make.height.equalTo(20)
        }
        self.replyQuoteLabel.snp.makeConstraints { make in
            make.top.equalTo(self.timeLab.snp.bottom)
            make.left.equalTo(self.timeLab.snp.left)
            make.height.equalTo(0)
        }
        self.titleLab.snp.makeConstraints { make in
            make.top.equalTo(self.replyQuoteLabel.snp.bottom)
            make.left.equalTo(self.timeLab.snp.left)
            make.bottom.equalToSuperview()
        }
        rightConstraint?.deactivate()
        self.imgView.snp.updateConstraints { make in
            make.left.equalTo(self.titleLab.snp.left).offset(6)
        }
        let image = UIImage.svgInit("left_chat_bg") // UIImage(named: "left_chat_bg", in: BundleUtil.getCurrentBundle(), compatibleWith: nil)
        // 表示图像的四边各保留 15 点，不被拉伸，拉伸的部分是图像的中心区域
        let insets = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
        self.contentBgView.image = image?.resizableImage(withCapInsets: insets, resizingMode: .stretch)
        self.contentBgView.snp.makeConstraints { make in
            make.left.equalTo(self.titleLab.snp.left)
            make.top.equalTo(self.timeLab.snp.bottom).offset(0)
            make.height.equalTo(0)
            make.width.equalTo(0)
        }
        self.arrowView.image = UIImage.svgInit("ic_left_point")
        self.arrowView.snp.makeConstraints { make in
            make.right.equalTo(self.contentBgView.snp.left)
            make.top.equalTo(self.contentBgView.snp.top).offset(8)
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

typealias BWChatRightCellResendBlock = (String) -> ()

class BWChatRightCell: BWChatCell {
    var resendBlock: BWChatRightCellResendBlock?

    lazy var loadingView: UIImageView = {
        let img = UIImageView(frame: CGRect.zero)
        return img
    }()
    
    required init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.iconView.image = UIImage.svgInit("icon_server_def2")

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
        self.replyQuoteLabel.snp.makeConstraints { make in
            make.top.equalTo(self.timeLab.snp.bottom)
            make.right.equalTo(self.timeLab.snp.right).offset(-12)
            make.height.equalTo(0)
        }
        self.titleLab.snp.makeConstraints { make in
            make.top.equalTo(self.replyQuoteLabel.snp.bottom)
            make.right.equalTo(self.timeLab.snp.right)
            make.bottom.equalToSuperview()
        }
        
        // Remove the left constraint
        leftConstraint?.deactivate()
                
        self.imgView.snp.updateConstraints { make in
            make.right.equalTo(self.titleLab.snp.right).offset(-6)
        }
        self.contentView.addSubview(self.loadingView)
        self.loadingView.snp.makeConstraints { make in
            make.top.equalTo(self.timeLab.snp.bottom).offset(0)
            make.right.equalTo(self.titleLab.snp.left).offset(-10)
            make.width.height.equalTo(20)
        }
        
        let image = UIImage.svgInit("right_chat_bg")
        let insets = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
        self.contentBgView.image = image?.resizableImage(withCapInsets: insets, resizingMode: .stretch)
        self.contentBgView.snp.makeConstraints { make in
            make.right.equalTo(self.titleLab.snp.right)
            make.top.equalTo(self.timeLab.snp.bottom).offset(-0)
            make.height.equalTo(0)
            make.width.equalTo(0)
        }
        
        self.arrowView.image = UIImage.svgInit("ic_right_point")
        self.arrowView.snp.makeConstraints { make in
            make.left.equalTo(self.contentBgView.snp.right)
            make.top.equalTo(self.contentBgView.snp.top).offset(8)
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

    override func initImg(imgUrl: URL) {
        super.initImg(imgUrl: imgUrl)
        self.initLoadingForImage()
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
