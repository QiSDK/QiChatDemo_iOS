//
//  BWVideoCell.swift
//  TeneasyChatSDKUI_iOS
//
//  Created by Xiao Fu on 2024/5/27.
//

import AVFoundation
import Kingfisher
import UIKit
import TeneasyChatSDK_iOS

//let iconWidth = 30.0
class BWTextMediaCell: UITableViewCell {
    var playBlock: BWVideoCellClickBlock?

    var gesture: UILongPressGestureRecognizer?
    var longGestCallBack: BWChatCellLongGestCallBack?
    let boarder = 3
    let msgMaxWidth = 188.0
    let thumbnailWidthSmall = 114
    let thumbnailHeightSmall = 178
    let thumbnailWidthLarge = 178
    let thumbnailHeightLarge = 114
    let playButtonSize = 60
    let timeLabTopOffset = 5
    let iconOffset = 12
    let timeLabLeftOffset = 16
    let timeLabRightOffset = -12
    let timeLabHeight = 20
    let thumbnailTopOffset = 10
    let arrowOffset = 4
    lazy var contentBgView: UIView = {
        let img = UIImageView()
        return img
    }()
    
    lazy var timeLab: UILabel = {
        let lab = UILabel()
        lab.font = UIFont.systemFont(ofSize: 13)
        if #available(iOS 13.0, *) {
            lab.textColor = UIColor.systemGray2
        } else {
            lab.textColor = UIColor.gray
        }
        lab.lineBreakMode = .byTruncatingTail
        return lab
    }()
    
    
    lazy var arrowView: UIImageView = {
        let img = UIImageView()
        return img
    }()
    
    
    lazy var titleLab: BWLabel = {
        let lab = BWLabel()
        lab.font = UIFont.systemFont(ofSize: 14)
        lab.textColor = .white
        
        lab.numberOfLines = 1000
        //lab.layer.cornerRadius = 8
        lab.layer.masksToBounds = true
        //lab.numberOfLines = 0 // Allow unlimited lines
        lab.lineBreakMode = .byWordWrapping
        lab.textInsets = UIEdgeInsets(top: 8, left: 6, bottom: 8, right: 15)

        //lab.preferredMaxLayoutWidth = kScreenWidth - 120 - iconWidth - 12
        return lab
    }()

    lazy var thumbnail: UIImageView = {
        let blackBackgroundView = UIImageView()
        return blackBackgroundView
    }()

    lazy var playBtn: UIButton = {
        let btn = UIButton()
        //btn.setImage(UIImage(named: "playvideo", in: BundleUtil.getCurrentBundle(), compatibleWith: nil), for: .normal)
        btn.setBackgroundImage(UIImage(named: "playvideo", in: BundleUtil.getCurrentBundle(), compatibleWith: nil), for: .normal)
        //btn.setTitle("play", for: UIControl.State.normal)
        btn.addTarget(self, action: #selector(playButtonTapped), for: .touchUpInside)
        return btn
    }()
    
    lazy var iconView: UIImageView = {
        let img = UIImageView()
        img.layer.cornerRadius = iconWidth * 0.5
        img.layer.masksToBounds = true
        return img
    }()

    
    static func cell(tableView: UITableView) -> Self {
        let cellId = "\(Self.self)"
        var cell = tableView.dequeueReusableCell(withIdentifier: cellId)
        if cell == nil {
            cell = Self(style: .default, reuseIdentifier: cellId)
        }
        
        return cell as! Self
    }
    
    @objc private func playButtonTapped() {
        playBlock?()
    }
    
    func displayIconImg(path: String) {
        let imgUrl = URL(string: "\(baseUrlImage)\(path)")
        self.iconView.kf.setImage(with: imgUrl)
    }
    
    func displayThumbnail(path: String) {
        self.thumbnail.image = UIImage(named: "imgloading", in: BundleUtil.getCurrentBundle(), compatibleWith: nil)
        let imgUrl = URL(string: path)
        if let url = imgUrl{
            initImg(imgUrl: url)
        }
    }
    
    func displayVideoThumbnail2(path: String) {
//        var ext = path.split(separator: ".").last ?? "mp4"
//        var thumbnailFileName = path.replacingOccurrences(of: "." + ext, with: ".jpg");
//        self.thumbnail.image = UIImage(named: "imgloading", in: BundleUtil.getCurrentBundle(), compatibleWith: nil)
//        var urlcomps = URLComponents(string: baseUrlImage)
//        urlcomps?.path = thumbnailFileName
//        
//        if let imgUrl = urlcomps?.url{
//            initImg(imgUrl: imgUrl)
//        }
        
        //let path = path.replacingOccurrences(of: "index.mp4", with: "thumb.jpg")
        let imgUrl = URL(string: "\(baseUrlImage)\(path)")
        //print("视频缩略图地址：\(baseUrlImage)\(path)")
        if let imgUrl = imgUrl {
            initImg(imgUrl: imgUrl)
        }
    }

    
    func initImg(imgUrl: URL) {
        self.thumbnail.kf.setImage(with: imgUrl, placeholder: UIImage(named: "imgloading", in: BundleUtil.getCurrentBundle(), compatibleWith: nil),
                                    options: [.transition(.fade(1))]) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let value):
                //print("Image width: \(imageSize.width), height: \(imageSize.height)")
                // 获取图片尺寸
                let imageSize = value.image.size
                let imageAspectRatio = imageSize.width / imageSize.height
                
                                if imageAspectRatio < 1 {
                                    self.contentBgView.snp.updateConstraints { make in
                                        make.width.equalTo(self.thumbnailWidthSmall)
                                        make.height.equalTo(self.thumbnailHeightSmall)
                                    }
                                } else {
                                    self.contentBgView.snp.updateConstraints { make in
                                        make.width.equalTo(self.thumbnailWidthLarge)
                                        make.height.equalTo(self.thumbnailHeightLarge)
                                    }
                                }
            case .failure(_):
                break
                 //print("图片可能显示失败")
            }
        }
    }
    
    override required init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        
        self.contentView.addSubview(self.arrowView)
        self.contentView.addSubview(self.iconView)
        self.contentView.addSubview(self.timeLab)

        self.contentView.addSubview(self.contentBgView)
        self.contentView.addSubview(self.thumbnail)
        self.thumbnail.addSubview(self.playBtn)
        self.contentView.addSubview(self.titleLab)
        
        self.gesture = UILongPressGestureRecognizer(target: self, action: #selector(self.longGestureClick(tap:)))
        self.titleLab.isUserInteractionEnabled = true
        self.titleLab.addGestureRecognizer(self.gesture!)
        //self.titleLab.backgroundColor = UIColor.red
        
        playBtn.isUserInteractionEnabled = true
        self.playBtn.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(60)
            make.height.equalTo(60)
        }
        
        thumbnail.isUserInteractionEnabled = true
        let longTap = UILongPressGestureRecognizer(target: self, action: #selector(self.longGestureClick(tap:)))
        self.thumbnail.addGestureRecognizer(longTap)

        // Create and add the gesture recognizer
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(playButtonTapped))
        self.thumbnail.addGestureRecognizer(tapGestureRecognizer)
        
        contentBgView.layer.cornerRadius = 5;
        contentBgView.layer.masksToBounds = true;
    }

    var model: ChatModel? {
        didSet {
            guard let msg = model?.message else {
                return
            }
            self.timeLab.text = msg.msgTime.date.toString(format: "yyyy-MM-dd HH:mm:ss")
            
            var text = msg.content.data
            
            if (text.contains("\"color\"")){
                let result = TextBody.deserialize(from: text)
                text = result?.content ?? ""
                //let mediaUrl = result?.image ?? result?.video ?? ""
                var mediaUrl = result?.image ?? ""
                if !(result?.video ?? "").isEmpty {
                    mediaUrl = result?.video ?? ""
                    self.playBtn.isHidden = false
                }else{
                    self.playBtn.isHidden = true
                }
                
                if mediaUrl.isEmpty {
                    self.thumbnail.isHidden = true
                }else{
                    displayThumbnail(path: mediaUrl)
                }
            }
           
            initTitle(msg: text)
        }
    }
    
    func initTitle(msg: String) {
        if msg.contains("[emoticon_") == true {
            let atttext = BEmotionHelper.shared.attributedStringByText(text: msg, font: self.titleLab.font)
            self.titleLab.attributedText = atttext
            //self.updateBgConstraints()
        } else {
            self.titleLab.text = msg
            //self.updateBgConstraints()
        }
    }

    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    @objc func longGestureClick(tap: UILongPressGestureRecognizer) {
        self.longGestCallBack?(tap)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    deinit {
         NotificationCenter.default.removeObserver(self)
     }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

class LeftBWTextMediaCell: BWTextMediaCell {
    required init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.iconView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(iconOffset)
            make.top.equalToSuperview().offset(iconOffset)
            make.width.height.equalTo(iconWidth)
        }
        self.timeLab.snp.makeConstraints { make in
            make.left.equalTo(self.iconView.snp.right).offset(timeLabLeftOffset)
            make.top.equalToSuperview().offset(timeLabTopOffset)
            make.right.equalToSuperview().offset(timeLabRightOffset)
            make.height.equalTo(timeLabHeight)
        }
        
        self.contentBgView.snp.makeConstraints { make in
            make.left.equalTo(self.timeLab.snp.left)
            make.top.equalTo(self.timeLab.snp.bottom).offset(0)
            make.height.equalTo(thumbnailHeightSmall)
            make.width.equalTo(thumbnailWidthSmall)
            make.bottom.equalToSuperview().priority(.low)
        }
        
        self.titleLab.snp.makeConstraints { make in
                    make.top.equalTo(self.contentBgView).offset(4)
                    make.left.equalTo(self.contentBgView)//.offset(4)
                    make.right.equalTo(self.contentBgView)
                    make.height.greaterThanOrEqualTo(50)
                    make.width.lessThanOrEqualTo(msgMaxWidth)
                    make.bottom.lessThanOrEqualTo(self.thumbnail.snp.top).offset(-4)
                    
                }
        
        self.thumbnail.snp.makeConstraints { make in
            make.right.equalTo(self.contentBgView).offset(-boarder)
            make.left.equalTo(self.contentBgView).offset(boarder)
            make.top.equalTo(self.titleLab.snp.bottom).offset(thumbnailTopOffset)
            make.bottom.equalTo(self.contentBgView).offset(-boarder)
        }
        
        arrowView.image = UIImage.svgInit("ic_left_point")
                self.arrowView.snp.makeConstraints { make in
                    make.right.equalTo(self.contentBgView.snp.left).offset(1)
                    make.top.equalTo(self.contentBgView).offset(arrowOffset)
                }
        
        self.contentBgView.backgroundColor = UIColor.white
        self.titleLab.textColor = UIColor.black
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

class RightBWTextMediaCell: BWTextMediaCell {
    required init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.iconView.image = UIImage.svgInit("icon_server_def2")

        self.iconView.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-iconOffset)
            make.top.equalToSuperview().offset(iconOffset)
            make.width.height.equalTo(iconWidth)
        }
        self.timeLab.snp.makeConstraints { make in
            make.right.equalTo(self.iconView.snp.left).offset(-timeLabLeftOffset)
            make.top.equalToSuperview().offset(timeLabTopOffset)
            make.height.equalTo(timeLabHeight)
        }
        self.contentBgView.snp.makeConstraints { make in
            make.top.equalTo(self.timeLab.snp.bottom)
            make.right.equalTo(self.timeLab.snp.right)
            make.width.equalTo(thumbnailWidthSmall)
            make.height.equalTo(thumbnailHeightSmall)
            make.bottom.equalToSuperview().priority(.low)
        }
        
        self.titleLab.snp.makeConstraints { make in
                    make.top.equalTo(self.contentBgView).offset(4)
                    make.left.equalTo(self.contentBgView)//.offset(4)
                    make.right.equalTo(self.contentBgView)
                    make.width.lessThanOrEqualTo(msgMaxWidth)
            make.height.greaterThanOrEqualTo(50)
                    make.bottom.lessThanOrEqualTo(self.thumbnail.snp.top).offset(-4)
                    
                }

        self.thumbnail.snp.makeConstraints { make in
                    make.right.equalTo(self.contentBgView).offset(-boarder)
                    make.left.equalTo(self.contentBgView).offset(boarder)
                    make.top.equalTo(self.titleLab.snp.bottom).offset(thumbnailTopOffset)
                    make.bottom.equalTo(self.contentBgView).offset(-boarder).priority(.high)
                }
        
        //self.contentBgView.image = UIImage.svgInit("right_chat_bg")
        self.contentBgView.backgroundColor = kHexColor(0x228AFE);
        
        arrowView.image = UIImage.svgInit("ic_right_point")
                self.arrowView.snp.makeConstraints { make in
                    make.left.equalTo(self.contentBgView.snp.right).offset(-1)
                    make.top.equalTo(self.contentBgView).offset(arrowOffset)
                }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
