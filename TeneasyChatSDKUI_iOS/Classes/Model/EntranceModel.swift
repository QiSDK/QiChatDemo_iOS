//
//  EntranceModel.swift
//  TeneasyChatSDKUI_iOS
//
//  Created by Xiao Fu on 2024/5/8.
//

import Foundation
import HandyJSON

class EntranceModel: HandyJSON {
    var name: String?
    var nick: String?
    var avatar: String?
    var guide: String?
    var defaultConsultId: Int?
    var changeDefaultTime: String?
    var consults: [Consult]?
    var unread: Int?

    required init(){}
}

// MARK: - Consult
class Consult: HandyJSON {
    var consultId: Int32?
    var name: String?
    var guide: String?
    var Works: [Work]?
    var unread: Int?
    var priority: Int?

    required init(){}

}

// MARK: - Work
class Work: HandyJSON {
    var nick: String?
    var avatar: String?
    var workerId: Int?
    var nimId: String?
    var connectState: String?
    var onlineState: String?

    required init(){}

}
