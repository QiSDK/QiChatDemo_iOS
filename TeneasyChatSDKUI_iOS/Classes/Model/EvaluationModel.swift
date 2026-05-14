//
//  EvaluationModel.swift
//  TeneasyChatSDKUI_iOS
//
//  客服满意度评价相关数据模型
//

import Foundation

public struct EvaluationConfig: Codable {
    public let evaluationEnabled: Bool
    public let configs: [EvaluationScoreConfig]
    public let triggerMessages: [String]
}

public struct EvaluationScoreConfig: Codable {
    public let content: String
    public let score: Int
    public let feedback: String
    public let status: Int
}

public struct EvaluationStatus: Codable {
    public let status: Int
}
