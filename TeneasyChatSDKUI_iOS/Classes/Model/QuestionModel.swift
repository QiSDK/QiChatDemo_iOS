//
//  QuestionModel.swift
//  TeneasyChatSDKUI_iOS
//
//  Created by Xiao Fu on 2024/5/8.
//

import Foundation

// MARK: - QuestionModel

class QuestionModel: Codable {
    var autoReplyItem: AutoReplyItem?
}

// MARK: - AutoReplyItem

class AutoReplyItem: Codable {
    var id: String?
    var name: String?
    var title: String?
    var qa: [QA]?
    var delaySec: Int?
    var workerId: [Int]?
    var workerNames: [String]?
}

// MARK: - QA

class QA: Codable {
    var id: Int?
    var question: Question?
    var content: String?
    var answer: [Question]?
    var related: [QA]?
    var myExpanded: Bool = false
    var clicked: Bool = false

    private enum CodingKeys: String, CodingKey {
        case id, question, content, answer, related
    }
}

// MARK: - Question

class Question: Codable {
    var chatId: String?
    var msgId: String?
    var sender: String?
    var replyMsgId: String?
    var msgOp: String?
    var worker: Int?
    var msgFmt: String?
    var consultId: String?
    var content: Content?
    var image: imgUri?
}

// MARK: - Content

class Content: Codable {
    var data: String?
}
