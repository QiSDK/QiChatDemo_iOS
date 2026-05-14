//
//  TextBody.swift
//  Pods
//
//  Created by XiaoFu on 5/5/25.
//
import Foundation

class TextBody: Codable {
    var content: String?
    var image: String?
    var video: String?
    var color: String?
}

struct TextImages: Codable {
    var message: String = ""
    var imgs: [String] = []
}
