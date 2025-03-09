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
        
        //lab.numberOfLines = 1000
        lab.layer.cornerRadius = 8
        lab.layer.masksToBounds = true
        lab.numberOfLines = 0 // Allow unlimited lines
        lab.lineBreakMode = .byWordWrapping
        lab.textInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        //lab.textInsets = UIEdgeInsets(top: 8, left: 6, bottom: 10, right: 15)
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
        
        self.replyView.isUserInteractionEnabled = true

        
        // Add tap gesture recognizer to the label
        let tapShowOriginalGesture = UITapGestureRecognizer(target: self, action: #selector(self.showOriginal))
        //tapShowOriginalGesture.cancelsTouchesInView = false // Ensure it doesn't cancel other touches
        self.replyView.addGestureRecognizer(tapShowOriginalGesture)
        //self.replyView.fileNameLab.addGestureRecognizer(tapShowOriginalGesture)
        //self.replyView.fileIcon.addGestureRecognizer(tapShowOriginalGesture)
        
        //self.backgroundColor = UIColor.black
    }

    @objc func longGestureClick(tap: UILongPressGestureRecognizer) {
        self.longGestCallBack?(tap)
    }
    
    @objc func showOriginal() {
        self.showOriginalBack!()
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
            
            //let quote = self.model?.replyItem?.content ?? ""

            
            // 现在SDK并没有把时间传回来，所以暂时不用这样转换
            self.timeLab.text = msg.msgTime.date.toString(format: "yyyy-MM-dd HH:mm:ss")
 
            
            let quote = self.model?.replyItem?.content ?? ""
                        if quote.contains("[emoticon_") == true {
                            let atttext = BEmotionHelper.shared.attributedStringByText(text: quote, font: self.replyView.fileNameLab.font)
                            self.replyView.fileNameLab.attributedText = atttext
                        }
            
            if (quote.isEmpty && (self.model?.replyItem?.fileName ?? "").isEmpty) {
                                  self.replyView.isHidden = true
                                  self.replyView.snp.updateConstraints { make in
                                      make.top.equalTo(self.titleLab.snp.bottom)
                                      //make.top.equalToSuperview()
                                      make.height.equalTo(0)
                                  }
                              } else {
                                  self.replyView.isHidden = false
                                  
                                  //不是文本消息
                                  if quote.isEmpty{
                                      self.replyView.snp.updateConstraints { make in
                                          make.top.equalTo(self.titleLab.snp.bottom).offset(5)
                                          make.height.equalTo(56)
                                          make.width.equalTo(200)
                                      }
                                  }else{
                                      self.replyView.snp.updateConstraints { make in
                                          make.top.equalTo(self.titleLab.snp.bottom).offset(5)
                                          make.height.equalTo(56)
                                          make.width.equalTo(155)
                                      }
                                  }
            
                                  
                              }

            
            replyView.model = model;
            
            self.replyView.sizeToFit()
            self.replyView.layoutIfNeeded()
            self.replyView.setNeedsLayout()
            
            self.initTitle(msg: msg)
        }
    }
    
    func updateCellHeight(){
        
    }
    
    func updateBgConstraints() {
        let maxSize = CGSize(width: titleLab.preferredMaxLayoutWidth, height: CGFloat.greatestFiniteMagnitude)
        let size = self.titleLab.sizeThatFits(maxSize)
      
        let margin = 4.0
        var quoteHeight = 80.0
        let sizeQuoteWidth = 0.0
        if (replyView.fileNameLab.text ?? "").isEmpty {
            //margin = 0
            quoteHeight = 0
            //print("contentBgView width:\(size.width)")
            self.contentBgView.snp.updateConstraints { make in
                make.width.equalTo(size.width)
                make.height.equalTo(size.height + quoteHeight + margin) // 8 is margin
            }
            replyView.isHidden = true
        }else{
            var newWidth = (size.width > sizeQuoteWidth + 24) ? size.width : sizeQuoteWidth + 24
            if newWidth < 12{
                newWidth = 12
            }
            
            replyView.isHidden = false
            //print("contentBgView width:\(newWidth)")
            self.contentBgView.snp.updateConstraints { make in
                make.width.equalTo(newWidth)
                make.height.equalTo(size.height + quoteHeight + margin) // 8 is margin
            }
        }
        
//        if (self.heightBlock != nil){
//            self.heightBlock!(size.height + quoteHeight + margin)
//        }
    }
    
    func displayIconImg(path: String) {
        let imgUrl = URL(string: "\(baseUrlImage)\(path)")
        self.iconView.kf.setImage(with: imgUrl)
    }
    

    func initTitle(msg: CommonMessage) {
        self.titleLab.isHidden = false
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
        self.titleLab.textColor = .black
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
            make.top.equalTo(self.timeLab.snp.bottom).priority(.low)
            make.left.equalTo(self.contentBgView)//.offset(4)
            make.right.equalTo(self.contentBgView).offset(-4)  //make.bottom.equalToSuperview()
        }
        
        self.replyView.snp.makeConstraints { make in
            make.top.equalTo(self.titleLab.snp.bottom).offset(10)
            //make.top.equalTo(self.titleLab.snp.bottom).offset(4)
            make.left.equalTo(self.arrowView.snp.right)
            make.height.equalTo(56)
            make.width.equalTo(200)
            make.bottom.equalToSuperview()
        }
        
//        var marginLeft = 16
//        if (self.replyView.text ?? "").isEmpty{
//            marginLeft = 4
//        }
        

        rightConstraint?.deactivate()

        //let image = UIImage.svgInit("left_chat_bg") // UIImage(named: "left_chat_bg", in: BundleUtil.getCurrentBundle(), compatibleWith: nil)
        // 表示图像的四边各保留 15 点，不被拉伸，拉伸的部分是图像的中心区域
        let insets = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
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

    lazy var loadingView: UIImageView = {
        let img = UIImageView(frame: CGRect.zero)
        return img
    }()
    
    required init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.iconView.image = UIImage.svgInit("icon_server_def2")
        self.titleLab.backgroundColor = blueColor
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
            make.top.equalTo(self.timeLab.snp.bottom).priority(.low)
            make.left.equalTo(self.contentBgView).offset(4)
            make.right.equalTo(self.contentBgView)//.offset(-4)
            //make.bottom.equalToSuperview()
        }
        
        self.replyView.snp.makeConstraints { make in
            make.top.equalTo(self.titleLab.snp.bottom).offset(10)
            make.right.equalTo(self.arrowView.snp.left)
            make.height.equalTo(56)
            make.width.equalTo(200)
            make.bottom.equalToSuperview()
        }
        
        // Remove the left constraint
        leftConstraint?.deactivate()
                
        self.contentView.addSubview(self.loadingView)
        self.loadingView.snp.makeConstraints { make in
            make.top.equalTo(self.timeLab.snp.bottom).offset(0)
            make.right.equalTo(self.titleLab.snp.left).offset(-10)
            make.width.height.equalTo(20)
        }
        
       // let image = UIImage.svgInit("right_chat_bg")
        let insets = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
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
