// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   var welcome = try? JSONDecoder().decode(Welcome.self, from: jsonData)

import Foundation
import HandyJSON

// MARK: - Main Data Model
class ReportRequest: Encodable {
    var data: [DataItem]?
    required init(){}
}

// MARK: - Data Item
class DataItem: Encodable {
    var url: String?
    var code: Int?
    var payload: String?
    var platform: Int?
    var createdAt: String?
    required init(){}
}

