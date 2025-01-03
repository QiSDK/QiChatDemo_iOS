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
    var uri: String? = ""
    var hlsUri: String? = ""
    var thumbnailUri = ""
    required init() {}
}

/*
 {"percentage":100,"data":{"uri":"/session/tenant_230/20250102/Videos/3137333538313235353133303966696c65d41d8cd98f00b204e9800998ecf8427e/index.mp4","hls_uri":"/session/tenant_230/20250102/Videos/3137333538313235353133303966696c65d41d8cd98f00b204e9800998ecf8427e/master.m3u8","thumbnail_uri":"/session/tenant_230/20250102/Videos/3137333538313235353133303966696c65d41d8cd98f00b204e9800998ecf8427e/thumb.jpg"}}
 */
