//
//  ServiceKeyword.swift
//  TeneasyChatSDKUI_iOS
//
//  宿主 App 通过自己的接口拿到的「服务关键词」配置。
//
//  当用户在聊天页输入的文本【包含】任一 keyword 时，UISDK 会以
//  msgSourceType = .mstAutoCard、type = .msgText 发送一条卡片消息，
//  消息体即本对象的 toJsonString() 结果，UI 上由 BWAutoCardCell 渲染成卡片。
//
//  content 是多态的：
//  - questionType == 1：数组，渲染成可点选项按钮（见 options）；
//  - questionType == 2：字符串，渲染成正文段落（见 contentText）。
//

import Foundation

public struct ServiceKeyword {
    public let id: Int?
    public let questionType: Int?
    public let category: Int?
    public let subject: String?

    /// content 为数组时的选项列表；否则为空。
    public let options: [String]
    /// content 为字符串时的正文；否则为空串。
    public let contentText: String
    /// 原始 content 是否为数组，决定 toJsonString 还原成数组还是字符串。
    public let isContentArray: Bool

    public let keywords: [String]
    public let weight: Int
    public let jumpCategory: Int?
    public let jumpUrl: String?

    public init(json: [String: Any]) {
        self.id = (json["id"] as? NSNumber)?.intValue
        self.questionType = (json["questionType"] as? NSNumber)?.intValue
        self.category = (json["category"] as? NSNumber)?.intValue
        self.subject = json["subject"] as? String

        if let arr = json["content"] as? [Any] {
            self.options = arr.map { "\($0)" }
            self.contentText = ""
            self.isContentArray = true
        } else if let str = json["content"] as? String {
            self.options = []
            self.contentText = str
            self.isContentArray = false
        } else {
            self.options = []
            self.contentText = ""
            self.isContentArray = false
        }

        self.keywords = (json["keywords"] as? [Any])?.map { "\($0)" } ?? []
        self.weight = (json["weight"] as? NSNumber)?.intValue ?? 0
        self.jumpCategory = (json["jumpCategory"] as? NSNumber)?.intValue
        self.jumpUrl = json["jumpUrl"] as? String
    }

    /// 原样还原条目 JSON（content 数组/字符串两种形态都保真）——即卡片消息的文本体。
    public func toJsonString() -> String? {
        var dict: [String: Any] = [
            "content": isContentArray ? options : contentText,
            "keywords": keywords,
            "weight": weight,
        ]
        if let id = id { dict["id"] = id }
        if let questionType = questionType { dict["questionType"] = questionType }
        if let category = category { dict["category"] = category }
        if let subject = subject { dict["subject"] = subject }
        if let jumpCategory = jumpCategory { dict["jumpCategory"] = jumpCategory }
        if let jumpUrl = jumpUrl { dict["jumpUrl"] = jumpUrl }

        guard let data = try? JSONSerialization.data(withJSONObject: dict, options: []) else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }

    /// 从卡片消息文本体反解析（供 BWAutoCardCell 渲染用）。
    public static func from(jsonString: String) -> ServiceKeyword? {
        guard let data = jsonString.data(using: .utf8),
              let obj = try? JSONSerialization.jsonObject(with: data, options: []),
              let dict = obj as? [String: Any] else {
            return nil
        }
        return ServiceKeyword(json: dict)
    }
}

/// 在 list 中查找命中 input 的卡片配置。
///
/// 命中规则：input【包含】某条目的任一 keyword 子串即命中；多条命中时取 weight
/// 最大的那条，weight 并列取列表中靠前的一条。无命中返回 nil。
public func matchAutoCard(input: String, list: [ServiceKeyword]) -> ServiceKeyword? {
    if input.isEmpty || list.isEmpty { return nil }
    var best: ServiceKeyword?
    for item in list {
        let hit = item.keywords.contains { !$0.isEmpty && input.contains($0) }
        // 严格大于才替换 → 并列时保留先出现的（靠前）那条。
        if hit, best == nil || item.weight > best!.weight {
            best = item
        }
    }
    return best
}
