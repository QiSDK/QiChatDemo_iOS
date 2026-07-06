//
//  NetworkLogPlugin.swift
//  TeneasyChatSDKUI_iOS
//
//  Moya 插件：捕获 UISDK 经由 ChatProvider 发出的 HTTP 请求，写入 NetworkLogBuffer。
//  相当于 Android 端的 OkHttp NetworkLogInterceptor。
//
//  在 WWApi.swift 里通过 MoyaProvider<ChatApi>(plugins: [NetworkLogPlugin()]) 注册一次，
//  此后每个 ChatProvider 请求都会经过 willSend / didReceive 回调被记录。
//

import Foundation
import Moya

final class NetworkLogPlugin: PluginType {

    /// 读取 body 的上限，超出则省略（避免大响应/上传把内存打满）
    private static let maxBodyBytes = 1024 * 1024 // 1MB

    /// 以 URLRequest 为键记录请求开始时间，用于计算耗时
    private let lock = NSLock()
    private var startTimes: [URLRequest: Date] = [:]

    func willSend(_ request: RequestType, target: TargetType) {
        guard let urlRequest = request.request else { return }
        lock.lock()
        startTimes[urlRequest] = Date()
        lock.unlock()
    }

    func didReceive(_ result: Result<Response, MoyaError>, target: TargetType) {
        switch result {
        case .success(let response):
            record(
                urlRequest: response.request,
                statusCode: response.statusCode,
                responseData: response.data,
                errorText: nil
            )
        case .failure(let error):
            let response = error.response
            record(
                urlRequest: response?.request,
                statusCode: response?.statusCode ?? -1,
                responseData: response?.data,
                errorText: error.errorDescription ?? error.localizedDescription
            )
        }
    }

    private func record(urlRequest: URLRequest?, statusCode: Int, responseData: Data?, errorText: String?) {
        let start: Date? = {
            guard let req = urlRequest else { return nil }
            lock.lock(); defer { lock.unlock() }
            let s = startTimes[req]
            startTimes[req] = nil
            return s
        }()

        let timestamp = start ?? Date()
        let duration = start.map { Date().timeIntervalSince($0) } ?? 0

        var headers: [String: String] = [:]
        urlRequest?.allHTTPHeaderFields?.forEach { headers[$0.key] = $0.value }

        let requestBody = bodyString(urlRequest?.httpBody)
        let responseBody = bodyString(responseData)
        let (apiCode, apiMsg) = parseApiCodeMsg(responseBody)

        let log = NetworkLog(
            url: urlRequest?.url?.absoluteString ?? "",
            method: urlRequest?.httpMethod ?? "",
            requestHeaders: headers,
            requestBodyPlain: requestBody,
            httpStatusCode: statusCode,
            responseBody: responseBody,
            apiCode: apiCode,
            apiMsg: apiMsg,
            error: errorText,
            duration: duration,
            timestamp: timestamp
        )
        NetworkLogBuffer.shared.append(log)
    }

    private func bodyString(_ data: Data?) -> String? {
        guard let data = data, !data.isEmpty else { return nil }
        if data.count > NetworkLogPlugin.maxBodyBytes {
            return "[body \(data.count) bytes, 已省略]"
        }
        return String(data: data, encoding: .utf8)
    }

    private func parseApiCodeMsg(_ body: String?) -> (Int, String) {
        guard let body = body,
              let data = body.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return (-1, "")
        }
        let code = json["code"] as? Int ?? -1
        let msg = json["msg"] as? String ?? ""
        return (code, msg)
    }
}
