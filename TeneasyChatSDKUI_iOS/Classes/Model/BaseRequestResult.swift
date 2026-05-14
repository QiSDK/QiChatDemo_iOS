//
//  BaseRequestResult.swift
//  TeneasyChatSDKUI_iOS
//
//  Created by Xiao Fu on 2023/2/8.
//

import Foundation

class BaseRequestResult<T: Codable>: Codable {
    var code: Int?
    var msg: String?
    var data: T?
}

struct EmptyResponse: Codable {}

class WorkerModel: Codable {
    var workerName: String?
    var workerAvatar: String?
}
