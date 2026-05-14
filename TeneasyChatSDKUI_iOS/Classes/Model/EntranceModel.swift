//
//  EntranceModel.swift
//  TeneasyChatSDKUI_iOS
//
//  Created by Xiao Fu on 2024/5/8.
//

import Foundation

class EntranceModel: Codable {
    var name: String?
    var nick: String?
    var avatar: String?
    var guide: String?
    var defaultConsultId: Int?
    var changeDefaultTime: String?
    var consults: [Consult]?
    var unread: Int?
}

class ReplyList: Codable {
    var replyList: [Message]?
}

// MARK: - Consult
class Consult: Codable {
    var consultId: Int32?
    var name: String?
    var guide: String?
    var Works: [Work]?
    var unread: Int?
    var priority: Int?
}

// MARK: - Work
class Work: Codable {
    var nick: String?
    var avatar: String?
    var workerId: Int?
    var nimId: String?
    var connectState: String?
    var onlineState: String?
}
