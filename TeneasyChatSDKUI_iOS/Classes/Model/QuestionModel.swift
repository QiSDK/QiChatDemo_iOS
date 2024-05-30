//
//  QuestionModel.swift
//  TeneasyChatSDKUI_iOS
//
//  Created by Xiao Fu on 2024/5/8.
//

import Foundation
import HandyJSON

// MARK: - QuestionModel

class QuestionModel: HandyJSON {
    var autoReplyItem: AutoReplyItem?

    required init() {}
}

// MARK: - AutoReplyItem

class AutoReplyItem: HandyJSON {
    var id: String?
    var name: String?
    var title: String?
    var qa: [QA]?
    var delaySec: Int?
    var workerId: [Any?]?
    var workerNames: [Any?]?

    required init() {}
}

// MARK: - QA

class QA: HandyJSON {
    var id: Int?
    var question: Question?
    var content: String?
    var answer: [Question]?
    var related: [QA]?
    var myExpanded: Bool = false
    var clicked: Bool = false

    required init() {}
}

// MARK: - Question

class Question: HandyJSON {
    var chatId: String?
    var msgId: String?
    var msgTime: NSNull?
    var sender: String?
    var replyMsgId: String?
    var msgOp: String?
    var worker: Int?
    var autoReplyFlag: NSNull?
    var msgFmt: String?
    var consultId: String?
    var content: Content?
    var image: imgUri?

    required init() {}
}

// MARK: - Content

class Content: HandyJSON {
    var data: String?

    required init() {}
}
