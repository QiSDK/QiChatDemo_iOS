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

//typealias BWMediaTapBlock = (TextBody) -> ()
//let iconWidth = 30.0
typealias BWTextImagesBlock = (String) -> ()

class BWTextImagesCell: UITableViewCell, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
     var playBlock: BWTextImagesBlock?

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
    let thumbnailTopOffset = 5
    let arrowOffset = 4
    //var textBody: TextImages?
    var imgs: [String]?
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
        img.isHidden = true
        return img
    }()
    
    
    lazy var titleLab: BWLabel = {
        let lab = BWLabel()
        lab.font = UIFont.systemFont(ofSize: 14)
        lab.textColor = .white
        lab.textAlignment = .center
        lab.numberOfLines = 1000
        //lab.layer.cornerRadius = 8
        lab.layer.masksToBounds = true
        //lab.numberOfLines = 0 // Allow unlimited lines
        lab.lineBreakMode = .byWordWrapping
        lab.textInsets = UIEdgeInsets(top: 8, left: 6, bottom: 8, right: 15)

        //lab.preferredMaxLayoutWidth = kScreenWidth - 120 - iconWidth - 12
        return lab
    }()

    lazy var thumbnailTV: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 5
        layout.minimumInteritemSpacing = 5
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.showsHorizontalScrollIndicator = true
        collectionView.backgroundColor = .clear
        return collectionView
    }()

    lazy var playBtn: UIButton = {
        let btn = UIButton()
        //btn.setImage(UIImage(named: "playvideo", in: BundleUtil.getCurrentBundle(), compatibleWith: nil), for: .normal)
        btn.setBackgroundImage(UIImage(named: "playvideo", in: BundleUtil.getCurrentBundle(), compatibleWith: nil), for: .normal)
        //btn.setTitle("play", for: UIControl.State.normal)
        //btn.addTarget(self, action: #selector(playButtonTapped), for: .touchUpInside)
        btn.isHidden = true
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
    
    
    @objc func playButtonTapped(_ sender: UITapGestureRecognizer) {
            guard let imageView = sender.view as? UIImageView else { return }
            // You can get the index or other info from imageView.tag or other means
            // For example, if you set imageView.tag = indexPath.item, you can get it here:
            let index = imageView.tag - 1001
            if let imgs = self.imgs, index < imgs.count {
                let selectedImagePath = imgs[index]
                // Handle the tap on the image at selectedImagePath
                print("Tapped image at index: \(index), path: \(selectedImagePath)")
                // Call playBlock or other action here if needed
                
                playBlock!(imgs[index])
            }
        }
    
    func displayIconImg(path: String) {
        let imgUrl = URL(string: "\(baseUrlImage)\(path)")
        self.iconView.kf.setImage(with: imgUrl)
    }
    
    override required init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        
        self.contentView.addSubview(self.arrowView)
        self.contentView.addSubview(self.iconView)
        self.contentView.addSubview(self.timeLab)

        self.contentView.addSubview(self.contentBgView)
        self.contentView.addSubview(self.thumbnailTV)
        self.thumbnailTV.addSubview(self.playBtn)
        self.contentView.addSubview(self.titleLab)
        
        self.thumbnailTV.dataSource = self
        self.thumbnailTV.delegate = self
        self.thumbnailTV.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "ThumbnailCell")
        self.thumbnailTV.isScrollEnabled = true
        
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
            let result = TextImages.deserialize(from: text)
            self.imgs = result?.imgs
            text = result?.message ?? ""
            //self.thumbnailTV.reloadData()
            initTitle(msg: text)
        }
    }
    
    var model2: ChatModel? {
        didSet {
            guard let msg = model2?.message else {
                return
            }
            self.timeLab.text = msg.msgTime.date.toString(format: "yyyy-MM-dd HH:mm:ss")
            var text = msg.content.data
            let result = TextBody.deserialize(from: text)
            self.imgs = result?.image?.components(separatedBy: ";")
            text = result?.content ?? ""
            //self.thumbnailTV.reloadData()
            initTitle(msg: text)
        }
    }
    
    func initTitle(msg: String) {
        if msg.contains("[emoticon_") == true {
            let atttext = BEmotionHelper.shared.attributedStringByText(text: msg, font: self.titleLab.font)
            self.titleLab.attributedText = atttext
        } else {
            self.titleLab.text = msg
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
    

    // MARK: - UITableViewDataSource and Delegate
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.imgs?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: CGFloat(thumbnailWidthSmall), height: CGFloat(thumbnailHeightSmall))
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ThumbnailCell", for: indexPath)
        
        // Remove all subviews to avoid reuse issues and random order
        cell.contentView.subviews.forEach { $0.removeFromSuperview() }
        
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: thumbnailWidthSmall, height: thumbnailHeightSmall))
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.tag = 1001 + indexPath.item
        cell.contentView.addSubview(imageView)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(playButtonTapped(_:)))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tapGestureRecognizer)
        
        let imgPath = self.imgs?[indexPath.item] ?? ""
                
        var imgUrl = "\(baseUrlImage)\(imgPath)";
        if imgPath.contains("htt"){
            imgUrl = String(imgPath)
        }
        
        imageView.kf.setImage(with: URL(string: imgUrl) , placeholder: UIImage(named: "image_default", in: BundleUtil.getCurrentBundle(), compatibleWith: nil))
        return cell
    }
    

}

class LeftBWTextImagesCell: BWTextImagesCell {
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
            make.width.equalTo(250)
            make.left.equalTo(self.timeLab.snp.left)
            make.top.equalTo(self.timeLab.snp.bottom).offset(0)
            make.bottom.equalToSuperview().priority(.low)
        }
        
        self.titleLab.snp.makeConstraints { make in
                    make.top.equalTo(self.contentBgView).offset(4)
                    make.left.equalTo(self.contentBgView)//.offset(4)
                    make.right.equalTo(self.contentBgView)
                    make.width.lessThanOrEqualTo(msgMaxWidth)
                    make.bottom.lessThanOrEqualTo(self.thumbnailTV.snp.top).offset(-4)
                    
                }
        
        self.thumbnailTV.snp.makeConstraints { make in
            make.left.equalTo(self.contentBgView)
            make.right.equalTo(self.contentBgView)
            make.height.equalTo(178)
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
