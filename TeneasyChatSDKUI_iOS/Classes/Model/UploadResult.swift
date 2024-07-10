// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let welcome = try? JSONDecoder().decode(Welcome.self, from: jsonData)

import Foundation

// MARK: - Welcome
struct UploadResult: Codable {
    let code: Int
    let message: String?
    let data: FilePath?
}

// MARK: - DataClass
struct FilePath: Codable {
    let filepath: String
}
