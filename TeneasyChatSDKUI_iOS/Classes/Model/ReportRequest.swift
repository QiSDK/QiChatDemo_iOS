// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   var welcome = try? JSONDecoder().decode(Welcome.self, from: jsonData)

import Foundation
import HandyJSON

// MARK: - Main Data Model
class ReportRequest: Encodable {
    var data = [ErrorItem]()
    required init(){}
}

// MARK: - Data Item
class ErrorItem: Encodable {
    var url: String?
    var code: Int?
    var payload: String?
    var platform: Int?
    var created_at: String?
    var tenantId: Int?
    required init(){}
}

class ErrorPayload: HandyJSON {
    var header: String?
    var request: String?
    var resp: String?
    required init(){}
}

