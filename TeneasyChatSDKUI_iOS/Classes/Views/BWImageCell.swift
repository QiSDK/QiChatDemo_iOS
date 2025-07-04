//
//  BWVideoCell.swift
//  TeneasyChatSDKUI_iOS
//
//  Created by Xiao Fu on 2024/5/27.
//

import AVFoundation
import Kingfisher
import UIKit

class BWImageCell: UITableViewCell {
    var playBlock: BWVideoCellClickBlock?

    var gesture: UILongPressGestureRecognizer?
    var longGestCallBack: BWChatCellLongGestCallBack?
    var boarder = 3
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
            // Fallback on earlier versions
        }
        lab.lineBreakMode = .byTruncatingTail
        return lab
    }()
    
    
    lazy var arrowView: UIImageView = {
        let img = UIImageView()
        return img
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
//        self.playBtn.isHidden = true
//        self.player?.play()
        playBlock!()
    }
    
    func displayIconImg(path: String) {
        let imgUrl = URL(string: "\(baseUrlImage)\(path)")
        self.iconView.kf.setImage(with: imgUrl)
    }
    
    func displayThumbnail(path: String) {
        var urlcomps = URLComponents(string: baseUrlImage)
        urlcomps?.path = path

        self.thumbnail.image = UIImage(named: "imgloading", in: BundleUtil.getCurrentBundle(), compatibleWith: nil)
        //print(urlcomps?.url?.absoluteString ?? "xxxx")
        if let imgUrl = urlcomps?.url{
            initImg(imgUrl: imgUrl)
        }
    }
    
    func displayVideoThumbnail(path: String) {
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
        if (imgUrl != nil){
            initImg(imgUrl: imgUrl!)
        }
    }
    
    func displayFileThumbnail(path: String) {
        let ext = (path.split(separator: ".").last ?? "").lowercased()
        
        //"docx","doc","pdf", "xls", "xlsx", "csv"
        var fileIcon = UIImage(named: "unknown_default", in: BundleUtil.getCurrentBundle(), compatibleWith: nil)
        if (ext == "pdf"){
            fileIcon = UIImage(named: "pdf_default", in: BundleUtil.getCurrentBundle(), compatibleWith: nil)
        }else if (ext == "xls" || ext == "xlsx" || ext == "csv"){
            fileIcon = UIImage(named: "excel_default", in: BundleUtil.getCurrentBundle(), compatibleWith: nil)
        }else if (ext == "doc" || ext == "docx"){
            fileIcon = UIImage(named: "word_default", in: BundleUtil.getCurrentBundle(), compatibleWith: nil)
        }
        self.thumbnail.image = fileIcon
    }
    
    func initImg(imgUrl: URL) {
        self.thumbnail.kf.setImage(with: imgUrl, placeholder: UIImage(named: "imgloading", in: BundleUtil.getCurrentBundle(), compatibleWith: nil),
                                   options: [
                                       .transition(.fade(1)),
                                   ]) { result in
            switch result {
            case .success(let value):
                // 获取图片尺寸
                let imageSize = value.image.size
                //print("Image width: \(imageSize.width), height: \(imageSize.height)")
                let imageAspectRatio = imageSize.width / imageSize.height

                if imageAspectRatio < 1{
                    self.contentBgView.snp.updateConstraints { make in
                        make.width.equalTo(114)
                        make.height.equalTo(178)
                    }
                }else if imageAspectRatio == 1{
                    self.contentBgView.snp.updateConstraints { make in
                        make.width.equalTo(178)
                        make.height.equalTo(178)
                    }
                }else{
                    self.contentBgView.snp.updateConstraints { make in
                        make.width.equalTo(178)
                        make.height.equalTo(114)
                    }
                }
            case .failure(_): break
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

        self.thumbnail.snp.makeConstraints { make in
            make.right.equalTo(self.contentBgView).offset(-boarder)
            make.left.equalTo(self.contentBgView).offset(boarder)
            make.top.equalTo(self.contentBgView).offset(boarder)
            make.bottom.equalTo(self.contentBgView).offset(-boarder)
            //make.height.width.equalTo(80)
        }
        
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
        
        //self.contentView.addGestureRecognizer(gesture!)

        contentBgView.layer.cornerRadius = 5;
        contentBgView.layer.masksToBounds = true;
       // thumbnail.contentMode = .scaleToFill
    }

    var model: ChatModel? {
        didSet {
            guard let msg = model?.message else {
                return
            }
            self.timeLab.text = msg.msgTime.date.toString(format: "yyyy-MM-dd HH:mm:ss")
           
            if !msg.video.uri.isEmpty  {
                let videoUrl = URL(string: "\(baseUrlImage)\(msg.video.uri)")
                //print(videoUrl?.absoluteString ?? "")
                self.initVideo(videoUrl: videoUrl!)
            } else {}
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
    
    func initVideo(videoUrl: URL) {
        self.playBtn.isHidden = false

    }
    
    deinit {
         NotificationCenter.default.removeObserver(self)
     }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

class BWImageLeftCell: BWImageCell {
    required init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.iconView.image = UIImage.svgInit("icon_server_def2")
        
        self.iconView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(12)
            make.top.equalToSuperview().offset(12)
            make.width.height.equalTo(iconWidth)
        }
        self.timeLab.snp.makeConstraints { make in
            make.left.equalTo(self.iconView.snp.right).offset(16)
            make.top.equalToSuperview().offset(5)
            make.right.equalToSuperview().offset(-12)
            make.height.equalTo(20)
        }
        
        self.contentBgView.snp.makeConstraints { make in
            make.left.equalTo(self.timeLab.snp.left)
            make.top.equalTo(self.timeLab.snp.bottom).offset(0)
            make.height.equalTo(178)
            make.width.equalTo(114)
            make.bottom.equalToSuperview().priority(.low)
        }
        
        arrowView.image = UIImage.svgInit("ic_left_point")
        self.arrowView.snp.makeConstraints { make in
            make.right.equalTo(self.contentBgView.snp.left).offset(1)
            make.top.equalTo(self.contentBgView).offset(4)
        }
        
        self.contentBgView.backgroundColor = UIColor.white
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

class BWImageRightCell: BWImageCell {
    required init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.iconView.image = UIImage.svgInit("icon_server_def2")

        self.iconView.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-12)
            make.top.equalToSuperview().offset(12)
            make.width.height.equalTo(iconWidth)
        }
        self.timeLab.snp.makeConstraints { make in
            make.right.equalTo(self.iconView.snp.left).offset(-16)
            make.top.equalToSuperview().offset(5)
            make.height.equalTo(20)
        }
        self.contentBgView.snp.makeConstraints { make in
            make.top.equalTo(self.timeLab.snp.bottom)
            make.right.equalTo(self.timeLab.snp.right)
            make.width.equalTo(114)
            make.height.equalTo(178)
            make.bottom.equalToSuperview().priority(.low)
        }
        
        //self.contentBgView.image = UIImage.svgInit("right_chat_bg")
        self.contentBgView.backgroundColor = kHexColor(0x228AFE);
        
        arrowView.image = UIImage.svgInit("ic_right_point")
        self.arrowView.snp.makeConstraints { make in
            make.left.equalTo(self.contentBgView.snp.right).offset(-1)
            make.top.equalTo(self.contentBgView).offset(4)
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
