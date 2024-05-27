//
//  WChatPasteToastView.swift
//  qixin
//
//  Created by evanchan on 2022/10/28.
//

import UIKit

class WChatPasteToastView: WBaseView {
    
   open var textLabel:UILabel!

    override func initConfig() {
        self.backgroundColor = UIColor.init(red: 64/255.0, green: 64/255.0, blue: 64/255.0, alpha: 1)
        self.layer.cornerRadius = 7.5
        self.layer.masksToBounds = true
        
    }
    override func initSubViews() {
        //图片
        let imageview = UIImageView()
        imageview.image = UIImage.svgInit("ht_fuzhi")
        addSubview(imageview)
        imageview.snp.makeConstraints { make in
            make.left.equalTo(12)
            make.size.equalTo(CGSize(width: 20, height: 20))
            make.top.equalTo(12)
        }
        
        //文字
        textLabel = UILabel()
        textLabel.font = UIFont.systemFont(ofSize: 13)
        textLabel.textColor = .white
        textLabel.textAlignment = .left
        textLabel.text = "消息已复制到剪切板"
        addSubview(textLabel)
        textLabel.snp.makeConstraints { make in
            make.left.equalTo(imageview.snp.right).offset(12)
            make.top.equalTo(imageview)
            make.height.equalTo(20)
        }
        
    }
    override func initBindModel() {
        
    }
    static func show(inView:UIView?,textStr:String = "") {
        let pasteToast = WChatPasteToastView()
        if inView == nil {
           let appdelegate = UIApplication.shared.delegate
            appdelegate?.window??.addSubview(pasteToast)
        }
        else {
            inView?.addSubview(pasteToast)
        }
        if textStr != ""{
            pasteToast.textLabel.text = textStr
        }else{
            pasteToast.textLabel.text = "消息已复制到剪切板"
        }
        pasteToast.snp.makeConstraints { make in
            make.left.equalTo(10)
            make.right.equalTo(-10)
            make.bottom.equalTo(-98)
            make.height.equalTo(43)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            pasteToast.removeFromSuperview()
        }
    }
}
