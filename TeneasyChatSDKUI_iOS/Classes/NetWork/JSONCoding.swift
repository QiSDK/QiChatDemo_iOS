//
//  JSONCoding.swift
//  TeneasyChatSDKUI_iOS
//
//  统一的 Codable 编解码工具，替代 HandyJSON 的 deserialize / toJSONString。
//

import Foundation

enum JSONCoding {
    static let decoder: JSONDecoder = {
        let d = JSONDecoder()
        return d
    }()

    static let encoder: JSONEncoder = {
        let e = JSONEncoder()
        return e
    }()

    static func decode<T: Decodable>(_ type: T.Type, from data: Data) -> T? {
        do {
            return try decoder.decode(type, from: data)
        } catch {
            print("JSONCoding.decode<\(type)> error: \(error)")
            return nil
        }
    }

    static func decode<T: Decodable>(_ type: T.Type, from string: String?) -> T? {
        guard let data = string?.data(using: .utf8) else { return nil }
        return decode(type, from: data)
    }

    static func decode<T: Decodable>(_ type: T.Type, from dict: [String: Any]?) -> T? {
        guard let dict = dict,
              let data = try? JSONSerialization.data(withJSONObject: dict, options: []) else {
            return nil
        }
        return decode(type, from: data)
    }

    static func encodeToString<T: Encodable>(_ value: T) -> String? {
        do {
            let data = try encoder.encode(value)
            return String(data: data, encoding: .utf8)
        } catch {
            print("JSONCoding.encodeToString<\(T.self)> error: \(error)")
            return nil
        }
    }
}
