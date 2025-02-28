//
//  BWChatCell.swift
//  TeneasyChatSDKUI_iOS_Example
//
//  Created by XiaoFu on 2023/2/1.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import AVFoundation
import Kingfisher
import UIKit

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
    
    lazy var imgView: UIImageView = {
        let v = UIImageView()
        v.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapImg))
        v.addGestureRecognizer(tapGesture)
        return v
    }()

    lazy var titleLab: BWLabel = {
        let lab = BWLabel()
        lab.font = UIFont.systemFont(ofSize: 15)
        lab.textColor = .black
        lab.numberOfLines = 1000
        lab.textInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        lab.preferredMaxLayoutWidth = kScreenWidth - 100
        return lab
    }()

    lazy var blackBackgroundView: UIView = {
        let blackBackgroundView = UIView()
        blackBackgroundView.backgroundColor = .black
        blackBackgroundView.alpha = 0
        return blackBackgroundView
    }()
    
    lazy var failedDotView: UIImageView = {
        let v = UIImageView()
        return v
    }()
    
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
                
        self.contentView.addSubview(self.timeLab)
        self.contentView.addSubview(self.titleLab)
        self.contentView.addSubview(self.imgView)
        self.imgView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(12)
            make.width.equalTo(kScreenWidth - 12 - 80)
            make.top.equalTo(self.timeLab.snp.bottom)
            make.height.equalTo(0)
        }
        self.gesture = UILongPressGestureRecognizer(target: self, action: #selector(self.longGestureClick(tap:)))
        self.contentView.addGestureRecognizer(self.gesture!)
    }

    @objc func longGestureClick(tap: UILongPressGestureRecognizer) {
        self.longGestCallBack?(tap)
    }
    
    var model: ChatModel? {
        didSet {
            guard let msg = model?.message else {
                return
            }
            // 现在SDK并没有把时间传回来，所以暂时不用这样转换
         
            self.timeLab.text = WTimeConvertUtil.displayLocalTime(from: msg.msgTime.date)
       
            if msg.image.uri.isEmpty == false {
                let imgUrl = URL(string: "\(baseUrlImage)\(msg.image.uri)")
                print(imgUrl?.absoluteString ?? "")
                if imgUrl != nil {
                    self.initImg(imgUrl: imgUrl!)
                } else {
                    self.initTitle()
                }
            } else {
                self.initTitle()
            }
            if msg.content.data.contains("[emoticon_") == true {
                let atttext = BEmotionHelper.shared.attributedStringByText(text: msg.content.data, font: self.titleLab.font)
                self.titleLab.attributedText = atttext
            } else {
                self.titleLab.text = msg.content.data
                // print("message text:" + (msg.content.data))
            }
        }
    }

    func initImg(imgUrl: URL) {
        self.imgView.snp.updateConstraints { make in
            make.height.equalTo(160)
        }
        self.imgView.kf.setImage(with: imgUrl)
        self.titleLab.isHidden = true
        self.imgView.isHidden = false
    }

    func initVideo(videoUrl: URL) {
        self.imgView.snp.updateConstraints { make in
            make.height.equalTo(0)
        }
        self.titleLab.isHidden = true
        self.imgView.isHidden = true
    }

    func initTitle() {
        self.imgView.snp.updateConstraints { make in
            make.height.equalTo(0)
        }
        self.titleLab.isHidden = false
        self.imgView.isHidden = true
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
        self.titleLab.backgroundColor = .white

        self.timeLab.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(12)
            make.top.equalToSuperview().offset(12)
            make.right.equalToSuperview().offset(-12)
            make.height.equalTo(20)
        }
        self.titleLab.snp.makeConstraints { make in
            make.top.equalTo(self.timeLab.snp.bottom)
            make.left.equalToSuperview().offset(12)
            make.bottom.equalToSuperview()
        }
        self.imgView.snp.updateConstraints { make in
            make.left.equalToSuperview().offset(12)
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
        
        self.titleLab.backgroundColor = UIColor(red: 253/255, green: 230/255, blue: 89/255, alpha: 1)

        self.timeLab.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.right.equalToSuperview().offset(-12)
            make.height.equalTo(20)
        }
        self.titleLab.snp.makeConstraints { make in
            make.top.equalTo(self.timeLab.snp.bottom)
            make.right.equalToSuperview().offset(-12)
            make.bottom.equalToSuperview()
        }
        
        self.imgView.snp.updateConstraints { make in
            make.left.equalToSuperview().offset(80)
        }
        self.contentView.addSubview(self.loadingView)
        self.loadingView.snp.makeConstraints { make in
            make.top.equalTo(self.timeLab.snp.bottom).offset(0)
            make.right.equalTo(self.titleLab.snp.left).offset(-10)
            make.width.height.equalTo(20)
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
    
    override func initTitle() {
        super.initTitle()
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
