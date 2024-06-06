// This file was generated from JSON Schema using codebeautify, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let welcome7 = try Welcome7(json)

import Foundation
import HandyJSON


struct HistoryModel: HandyJSON {
    var request: RequestData?
    var list: [Message]?
    var replyList: [Message]?
    var lastMsgId: String?
    var nick: String?
}

struct RequestData: HandyJSON {
    var chatId: String?
    var msgId: String?
    var count: Int?
    var withLastOne: Bool?
    var workerId: Int?
    var consultId: Int?
    var userId: Int?
}

struct Message: HandyJSON {
    var chatId: String?
    var msgId: String?
    var msgTime: String?
    var sender: String?
    var replyMsgId: String?
    var msgOp: String?
    var worker: Int?
    var autoReplyFlag: String? // This could also be Int? if null should be treated as 0
    var msgFmt: String?
    var consultId: String?
    var content: MessageContent?
    var image: imgUri?
    var video: imgUri?
    var workerChanged: AssignWorker?
}

struct MessageContent: HandyJSON {
    var data: String?
}

struct imgUri: HandyJSON {
    var uri: String?
}
