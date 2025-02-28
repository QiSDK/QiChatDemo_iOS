//
//  AssignWorker.swift
//  TeneasyChatSDKUI_iOS
//
//  Created by Xiao Fu on 2024/5/9.
//

import Foundation
import HandyJSON

class AssignWorker: HandyJSON {
    var nick: String?
    var avatar: String?
    var workerId: Int32?
    var greeting: String?
    var State: String?
    var consultId: String?
    /*
     "greeting": "您好, t28q为您服务",
                     "State": "CHAT_STATE_UNPROCESSED_3MIN",
                     "consultId": "1"
     */
    required init(){}
}
