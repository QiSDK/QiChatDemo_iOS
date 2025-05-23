//
//  ChatModel.swift
//  TeneasyChatSDKUI_iOS_Example
//
//  Created by XiaoFu on 2023/2/1.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import Foundation
import TeneasyChatSDK_iOS
import HandyJSON

enum MessageSendState: String { case 发送中="0", 发送成功="1", 发送失败="2", 未知="-1" }

/*
 var TYPE_Text : Int = 0
 val TYPE_Image : Int = 1
 val TYPE_Tip: Int = 3
 val TYPE_QA : Int = 4
 val TYPE_LastLine : Int = 5
 */
enum CellType: String { case TYPE_Text="0", TYPE_Image="1", TYPE_Tip="2", TYPE_QA="3", TYPE_VIDEO="4", TYPE_LastLine="5" , TYPE_File="6", TYPE_TEXT_IMAGES="7"}
class ChatModel {
    var message: CommonMessage?
    var isLeft: Bool=false
    var replyItem: ReplyMessageItem?
    var sendStatus: MessageSendState = .发送中
    var payLoadId: UInt64=0
    var cellType: CellType = .TYPE_Text
}

class Custom: HandyJSON {
    var username: String?
    var platform: Int = 1
    var userlevel: Int = 10
    required init(){}
}

class ReplyMessageItem: HandyJSON {
    var id: String = ""
    var fileName: String? = ""
    var size: Int32 = 0
    var content: String = ""
    required init(){}
}
