//
//  BaseRequestResult.swift
//  TeneasyChatSDKUI_iOS
//
//  Created by Xiao Fu on 2023/2/8.
//

import Foundation
import HandyJSON

class BaseRequestResult<T>: HandyJSON {
    var code: Int?
    var msg: String?
    var data: T?
    required init() {}
}

class WorkerModel: HandyJSON {
    var workerName: String?
    var workerAvatar: String?
    required init() {}
}
