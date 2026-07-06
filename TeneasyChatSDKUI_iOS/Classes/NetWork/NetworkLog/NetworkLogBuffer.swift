//
//  NetworkLogBuffer.swift
//  TeneasyChatSDKUI_iOS
//
//  网络日志缓冲区 - 与 Android NetworkLogBuffer / Flutter Logman 对齐。
//  收集 NetworkLogPlugin 捕获的 HTTP 请求日志，最多保留 200 条（超出丢弃最旧）。
//  线程安全，通过 Notification 通知列表页刷新。
//

import Foundation

extension Notification.Name {
    static let teneasyNetworkLogDidChange = Notification.Name("teneasyNetworkLogDidChange")
}

final class NetworkLogBuffer {
    static let shared = NetworkLogBuffer()
    private init() {}

    private let maxCount = 200
    private let queue = DispatchQueue(label: "com.teneasy.NetworkLogBuffer", attributes: .concurrent)
    private var _logs: [NetworkLog] = []

    /// 当前日志列表（副本，最新的在前）
    var logs: [NetworkLog] {
        queue.sync { _logs }
    }

    /// 追加一条日志（由 plugin 调用，可能在任意线程）
    func append(_ log: NetworkLog) {
        queue.async(flags: .barrier) {
            self._logs.insert(log, at: 0)
            if self._logs.count > self.maxCount {
                self._logs = Array(self._logs.prefix(self.maxCount))
            }
            self.notifyChanged()
        }
    }

    /// 清空所有日志
    func clear() {
        queue.async(flags: .barrier) {
            self._logs.removeAll()
            self.notifyChanged()
        }
    }

    private func notifyChanged() {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .teneasyNetworkLogDidChange, object: nil)
        }
    }
}
