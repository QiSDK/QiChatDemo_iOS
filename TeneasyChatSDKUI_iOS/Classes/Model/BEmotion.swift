//
//  BWKeFuChatEmojiModel.swift
//  ProgramIOS
//
//  Created by XiaoFu on 2021/8/20.
//

import UIKit



class BEmotion {
    
    var identifier:String = ""
    
    var displayName:String = ""

    var image:UIImage?
    
    convenience init(identifier:String,displayName:String) {
        self.init()
        self.identifier = identifier;
        self.displayName = displayName;
      
        self.image = UIImage(named: "emoticon/\(identifier)", in: BundleUtil.getCurrentBundle(), compatibleWith: nil)
    }
}
