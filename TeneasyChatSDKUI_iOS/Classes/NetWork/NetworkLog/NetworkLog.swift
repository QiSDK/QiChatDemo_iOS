//
//  NetworkLog.swift
//  TeneasyChatSDKUI_iOS
//
//  UISDK 一次 HTTP 请求的完整日志（请求 + 响应关键数据）。
//  数据来源为 NetworkLogPlugin（Moya PluginType），捕获经由 ChatProvider 发出的所有请求。
//  与 Android/Flutter 端保持一致（请求体为明文 JSON，无加密字段）。
//

import Foundation

struct NetworkLog {
    /// 完整请求 URL
    let url: String
    /// HTTP 方法（GET / POST ...）
    let method: String
    /// HTTP 请求头（Key-Value）
    let requestHeaders: [String: String]
    /// 请求体明文，无请求体时为 nil
    let requestBodyPlain: String?
    /// HTTP 响应状态码，网络错误时为 -1
    let httpStatusCode: Int
    /// 响应体字符串，无响应体或读取失败时为 nil
    let responseBody: String?
    /// 业务层响应码（ReturnData.code），无法解析时为 -1
    let apiCode: Int
    /// 业务层响应消息（ReturnData.msg），无法解析时为空串
    let apiMsg: String
    /// 网络错误描述，无错误时为 nil
    let error: String?
    /// 从发送请求到收到响应的耗时（秒）
    let duration: Double
    /// 请求发出的时间戳
    let timestamp: Date
}
