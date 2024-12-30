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

// MARK: - DataClass
class FilePath: HandyJSON {
    var filepath: String?
    required init() {}
}

/*
 "{\"percentage\":100,\"data\":{\"origin_url\":\"public/tenant_230/20241230/Videos/8c7dd922ad47494fc02c388e12c00eac/index.mp4\",\"hls_master_url\":\"public/tenant_230/20241230/Videos/8c7dd922ad47494fc02c388e12c00eac/master.m3u8\",\"thumbnail_url\":\"public/tenant_230/20241230/Videos/8c7dd922ad47494fc02c388e12c00eac/thumb.jpg\"}}"
 */
class UploadPercent : HandyJSON {
    var percentage: Int = 0
    //var path: String? = ""
    var data: Urls?
    required init() {}
}

class Urls: HandyJSON {
    var origin_url: String? = ""
    var hls_master_url: String? = ""
    var thumbnail_url = ""
    required init() {}
}
