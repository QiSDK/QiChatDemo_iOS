//
//  ConstConfig.swift
//  TeneasyChatSDKUI_iOS_Example
//
//  Created by XiaoFu on 2023/1/31.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import Foundation
import UIKit

///MARK: 设备宽高
public let kMainScreen:UIScreen = {
    if #available(iOS 13.0, *) {
        return (UIApplication.shared.connectedScenes.first as? UIWindowScene)!.screen
    }
    else {
        return UIScreen.main
    }
}()

public let kScreenWidth = kMainScreen.bounds.size.width
public let kScreenHeight = kMainScreen.bounds.size.height
public let kDeviceBottom:CGFloat = kMainScreen.bounds.size.height >= 812 ? 34.0 : 0.0
public let kDeviceTop:CGFloat = kMainScreen.bounds.size.height >= 812 ? 44.0 : 20.0
//public let kDeviceTop:CGFloat = kMainScreen.bounds.size.height >= 812 ? 66.0 : 44.0
public let kBgColor = UIColor.init(red: 246/255.0, green: 246/255.0, blue: 246/255.0, alpha: 1)
public let kMainColor = UIColor.init(red: 30/255.0, green: 144/255.0, blue: 255/255.0, alpha: 1)

///HexColor 支持0xFF55c9c4格式
public func kHexColor(_ argb: UInt32) -> UIColor {
    return UIColor(red: ((CGFloat)((argb & 0xFF0000) >> 16)) / 255.0,green: ((CGFloat)((argb & 0xFF00) >> 8)) / 255.0,blue: ((CGFloat)(argb & 0xFF)) / 255.0, alpha: 1.0)
}
