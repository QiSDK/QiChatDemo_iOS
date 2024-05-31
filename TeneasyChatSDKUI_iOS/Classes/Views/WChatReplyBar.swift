//
//  WChatReplyBar.swift
//  qixin
//
//  Created by evanchan on 2022/10/17.
//

import UIKit
import SnapKit
import TeneasyChatSDK_iOS

class WChatReplyBar: WBaseView {
//    var replyType:MessageType = .text
//    lazy var iconImageView:UIImageView = {
//        let icon = UIImageView()
//        icon.image = SVGKImage(named: "lt_xiaoxidingwei").uiImage
//        return icon
//    }()
    
    var msg: CommonMessage? = nil
    
    lazy var vline:UIView = {
        let line = UIView()
        line.backgroundColor = .gray
        return line
    }()
    
    lazy var titleLabel:UILabel = {
        let label = UILabel()
        label.textColor = .blue
        label.font = UIFont.systemFont(ofSize: 12)
        label.textAlignment = .left
        return label
    }()
    
    lazy var contentLabel:UILabel = {
        let label = UILabel()
        label.textColor = .blue
        label.font = UIFont.systemFont(ofSize: 12)
        label.textAlignment = .left
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    
    lazy var closeButton:UIButton = {
        let button = UIButton(type: .custom)
        let image = UIImage.svgInit("close")
        button.setImage(image, for: .normal)
        return button
    }()

    override func initConfig() {
        backgroundColor = kHexColor(0xF6F6F6)
    }
    
    override func initSubViews() {
//        addSubview(iconImageView) //lt_guanbihuifu
//        iconImageView.snp.makeConstraints { make in
//            make.left.equalTo(kScaleWidth(8))
//            make.top.equalToSuperview().offset(6)
//            make.bottom.equalToSuperview().offset(-5)
//            make.width.height.equalTo(26)
//        }
        
//        addSubview(vline)
//        vline.snp.makeConstraints { make in
//            make.top.equalTo(9)
//            make.left.equalTo(iconImageView.snp.right).offset(kScaleWidth(17))
//            make.width.equalTo(2)
//            make.height.equalTo(20)
//        }
        
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(9)
            make.top.equalToSuperview().offset(1)
            make.height.equalTo(18)
            make.width.equalTo(290) //290是计算出来的，249是16个字符
        }
        
        addSubview(contentLabel)
        contentLabel.snp.makeConstraints { make in
            make.left.equalTo(titleLabel)
            make.top.equalTo(titleLabel.snp.bottom)
            make.height.equalTo(titleLabel)
            make.width.equalTo(titleLabel)
            make.bottom.equalToSuperview()
        }
  
        addSubview(closeButton)
        closeButton.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.width.height.equalTo(40)
            make.right.equalToSuperview().offset(-10)
        }
    }
    
    override func initBindModel() {}
    
    func updateUI(with chatModel:ChatModel) {
        msg = chatModel.message
        titleLabel.text = "回复 "
        
        if !(msg?.image.uri ?? "").isEmpty{
            contentLabel.text = "[图片]"
        }else if !(msg?.video.uri ?? "").isEmpty{
            contentLabel.text = "[视频]"
        }else{
            contentLabel.text = msg?.content.data ?? ""
        }
        
        titleLabel.textColor = UIColor.purple
    }

}
