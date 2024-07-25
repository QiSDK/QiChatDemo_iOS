// DO NOT EDIT.
// swift-format-ignore-file
//
// Generated by the Swift generator plugin for the protocol buffer compiler.
// Source: api/core/data_statistic.proto
//
// For information on using the generated types, please see the documentation:
//   https://github.com/apple/swift-protobuf/

import Foundation
import SwiftProtobuf

// If the compiler emits an error on this type, it is because this file
// was generated by a version of the `protoc` Swift plug-in that is
// incompatible with the version of SwiftProtobuf to which you are linking.
// Please ensure that you are building against the same version of the API
// that was used to generate this file.
fileprivate struct _GeneratedWithProtocGenSwiftVersion: SwiftProtobuf.ProtobufAPIVersionCheck {
  struct _2: SwiftProtobuf.ProtobufAPIVersion_2 {}
  typealias Version = _2
}

public struct Api_Core_WorkerStatisticsRequest {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  /// 客服组id
  public var groupID: Int32 = 0

  /// 客服身份
  public var workerIdentity: Api_Common_WorkerPermission = .workerPermNone

  /// 开始时间
  public var startTime: Int64 = 0

  /// 结束时间
  public var endTime: Int64 = 0

  /// 页数
  public var page: UInt32 = 0

  /// 每页大小
  public var pageSize: UInt32 = 0

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public init() {}
}

public struct Api_Core_WorkerStatisticsResponse {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  /// 客服上限人数
  public var workerMaxNum: Int32 = 0

  /// 现有客服人数
  public var workerCurrentNum: Int32 = 0

  /// 统计人数
  public var userCount: Int32 = 0

  /// 所有客服平均三分钟回复率
  public var replyRate: Float = 0

  /// 所有客服平均响应时长(分)
  public var responseDuration: String = String()

  ///  所有客服平均服务时长(分)
  public var serverDuration: String = String()

  /// 所有累积在线时长(小时)
  public var onlineDuration: String = String()

  /// 所有转任务数
  public var transferTaskNum: Int32 = 0

  /// 所有接任务数
  public var receiveTaskNum: Int32 = 0

  /// 客服统计列表
  public var statistics: [Api_Core_WorkerStatistic] = []

  /// 总数
  public var count: Int64 = 0

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public init() {}
}

public struct Api_Core_WorkerStatistic {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  public var workerID: Int32 = 0

  /// 客服昵称
  public var workerNickname: String = String()

  /// 分配人数
  public var assignNum: Int32 = 0

  /// 3分钟回复率
  public var replyRate: Float = 0

  /// 转任务数
  public var transferTaskNum: Int32 = 0

  /// 接任务数
  public var receiveTaskNum: Int32 = 0

  /// 平均响应时长(分)
  public var responseDuration: String = String()

  /// 客服组id
  public var groupID: Int32 = 0

  /// 客服组昵称
  public var groupNickname: String = String()

  /// 客服分组id
  public var subGroupID: Int32 = 0

  /// 客服分组昵称
  public var subGroupNickname: String = String()

  /// 客服身份
  public var workerIdentity: Api_Common_WorkerPermission = .workerPermNone

  /// 平均服务时长(分)
  public var serverDuration: String = String()

  /// 累积在线时长(小时)
  public var onlineDuration: String = String()

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public init() {}
}

#if swift(>=5.5) && canImport(_Concurrency)
extension Api_Core_WorkerStatisticsRequest: @unchecked Sendable {}
extension Api_Core_WorkerStatisticsResponse: @unchecked Sendable {}
extension Api_Core_WorkerStatistic: @unchecked Sendable {}
#endif  // swift(>=5.5) && canImport(_Concurrency)

// MARK: - Code below here is support for the SwiftProtobuf runtime.

fileprivate let _protobuf_package = "api.core"

extension Api_Core_WorkerStatisticsRequest: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = _protobuf_package + ".WorkerStatisticsRequest"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .standard(proto: "group_id"),
    3: .standard(proto: "worker_identity"),
    4: .standard(proto: "start_time"),
    5: .standard(proto: "end_time"),
    6: .same(proto: "page"),
    7: .same(proto: "pageSize"),
  ]

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularInt32Field(value: &self.groupID) }()
      case 3: try { try decoder.decodeSingularEnumField(value: &self.workerIdentity) }()
      case 4: try { try decoder.decodeSingularInt64Field(value: &self.startTime) }()
      case 5: try { try decoder.decodeSingularInt64Field(value: &self.endTime) }()
      case 6: try { try decoder.decodeSingularUInt32Field(value: &self.page) }()
      case 7: try { try decoder.decodeSingularUInt32Field(value: &self.pageSize) }()
      default: break
      }
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if self.groupID != 0 {
      try visitor.visitSingularInt32Field(value: self.groupID, fieldNumber: 1)
    }
    if self.workerIdentity != .workerPermNone {
      try visitor.visitSingularEnumField(value: self.workerIdentity, fieldNumber: 3)
    }
    if self.startTime != 0 {
      try visitor.visitSingularInt64Field(value: self.startTime, fieldNumber: 4)
    }
    if self.endTime != 0 {
      try visitor.visitSingularInt64Field(value: self.endTime, fieldNumber: 5)
    }
    if self.page != 0 {
      try visitor.visitSingularUInt32Field(value: self.page, fieldNumber: 6)
    }
    if self.pageSize != 0 {
      try visitor.visitSingularUInt32Field(value: self.pageSize, fieldNumber: 7)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: Api_Core_WorkerStatisticsRequest, rhs: Api_Core_WorkerStatisticsRequest) -> Bool {
    if lhs.groupID != rhs.groupID {return false}
    if lhs.workerIdentity != rhs.workerIdentity {return false}
    if lhs.startTime != rhs.startTime {return false}
    if lhs.endTime != rhs.endTime {return false}
    if lhs.page != rhs.page {return false}
    if lhs.pageSize != rhs.pageSize {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Api_Core_WorkerStatisticsResponse: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = _protobuf_package + ".WorkerStatisticsResponse"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .standard(proto: "worker_max_num"),
    2: .standard(proto: "worker_current_num"),
    3: .standard(proto: "user_count"),
    4: .standard(proto: "reply_rate"),
    5: .standard(proto: "response_duration"),
    6: .standard(proto: "server_duration"),
    7: .standard(proto: "online_duration"),
    8: .standard(proto: "transfer_task_num"),
    9: .standard(proto: "receive_task_num"),
    10: .same(proto: "statistics"),
    11: .same(proto: "count"),
  ]

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularInt32Field(value: &self.workerMaxNum) }()
      case 2: try { try decoder.decodeSingularInt32Field(value: &self.workerCurrentNum) }()
      case 3: try { try decoder.decodeSingularInt32Field(value: &self.userCount) }()
      case 4: try { try decoder.decodeSingularFloatField(value: &self.replyRate) }()
      case 5: try { try decoder.decodeSingularStringField(value: &self.responseDuration) }()
      case 6: try { try decoder.decodeSingularStringField(value: &self.serverDuration) }()
      case 7: try { try decoder.decodeSingularStringField(value: &self.onlineDuration) }()
      case 8: try { try decoder.decodeSingularInt32Field(value: &self.transferTaskNum) }()
      case 9: try { try decoder.decodeSingularInt32Field(value: &self.receiveTaskNum) }()
      case 10: try { try decoder.decodeRepeatedMessageField(value: &self.statistics) }()
      case 11: try { try decoder.decodeSingularInt64Field(value: &self.count) }()
      default: break
      }
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if self.workerMaxNum != 0 {
      try visitor.visitSingularInt32Field(value: self.workerMaxNum, fieldNumber: 1)
    }
    if self.workerCurrentNum != 0 {
      try visitor.visitSingularInt32Field(value: self.workerCurrentNum, fieldNumber: 2)
    }
    if self.userCount != 0 {
      try visitor.visitSingularInt32Field(value: self.userCount, fieldNumber: 3)
    }
    if self.replyRate != 0 {
      try visitor.visitSingularFloatField(value: self.replyRate, fieldNumber: 4)
    }
    if !self.responseDuration.isEmpty {
      try visitor.visitSingularStringField(value: self.responseDuration, fieldNumber: 5)
    }
    if !self.serverDuration.isEmpty {
      try visitor.visitSingularStringField(value: self.serverDuration, fieldNumber: 6)
    }
    if !self.onlineDuration.isEmpty {
      try visitor.visitSingularStringField(value: self.onlineDuration, fieldNumber: 7)
    }
    if self.transferTaskNum != 0 {
      try visitor.visitSingularInt32Field(value: self.transferTaskNum, fieldNumber: 8)
    }
    if self.receiveTaskNum != 0 {
      try visitor.visitSingularInt32Field(value: self.receiveTaskNum, fieldNumber: 9)
    }
    if !self.statistics.isEmpty {
      try visitor.visitRepeatedMessageField(value: self.statistics, fieldNumber: 10)
    }
    if self.count != 0 {
      try visitor.visitSingularInt64Field(value: self.count, fieldNumber: 11)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: Api_Core_WorkerStatisticsResponse, rhs: Api_Core_WorkerStatisticsResponse) -> Bool {
    if lhs.workerMaxNum != rhs.workerMaxNum {return false}
    if lhs.workerCurrentNum != rhs.workerCurrentNum {return false}
    if lhs.userCount != rhs.userCount {return false}
    if lhs.replyRate != rhs.replyRate {return false}
    if lhs.responseDuration != rhs.responseDuration {return false}
    if lhs.serverDuration != rhs.serverDuration {return false}
    if lhs.onlineDuration != rhs.onlineDuration {return false}
    if lhs.transferTaskNum != rhs.transferTaskNum {return false}
    if lhs.receiveTaskNum != rhs.receiveTaskNum {return false}
    if lhs.statistics != rhs.statistics {return false}
    if lhs.count != rhs.count {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Api_Core_WorkerStatistic: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = _protobuf_package + ".WorkerStatistic"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .standard(proto: "worker_id"),
    2: .standard(proto: "worker_nickname"),
    3: .standard(proto: "assign_num"),
    4: .standard(proto: "reply_rate"),
    5: .standard(proto: "transfer_task_num"),
    6: .standard(proto: "receive_task_num"),
    7: .standard(proto: "response_duration"),
    8: .standard(proto: "group_id"),
    9: .standard(proto: "group_nickname"),
    10: .standard(proto: "sub_group_id"),
    11: .standard(proto: "sub_group_nickname"),
    12: .standard(proto: "worker_identity"),
    13: .standard(proto: "server_duration"),
    14: .standard(proto: "online_duration"),
  ]

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularInt32Field(value: &self.workerID) }()
      case 2: try { try decoder.decodeSingularStringField(value: &self.workerNickname) }()
      case 3: try { try decoder.decodeSingularInt32Field(value: &self.assignNum) }()
      case 4: try { try decoder.decodeSingularFloatField(value: &self.replyRate) }()
      case 5: try { try decoder.decodeSingularInt32Field(value: &self.transferTaskNum) }()
      case 6: try { try decoder.decodeSingularInt32Field(value: &self.receiveTaskNum) }()
      case 7: try { try decoder.decodeSingularStringField(value: &self.responseDuration) }()
      case 8: try { try decoder.decodeSingularInt32Field(value: &self.groupID) }()
      case 9: try { try decoder.decodeSingularStringField(value: &self.groupNickname) }()
      case 10: try { try decoder.decodeSingularInt32Field(value: &self.subGroupID) }()
      case 11: try { try decoder.decodeSingularStringField(value: &self.subGroupNickname) }()
      case 12: try { try decoder.decodeSingularEnumField(value: &self.workerIdentity) }()
      case 13: try { try decoder.decodeSingularStringField(value: &self.serverDuration) }()
      case 14: try { try decoder.decodeSingularStringField(value: &self.onlineDuration) }()
      default: break
      }
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if self.workerID != 0 {
      try visitor.visitSingularInt32Field(value: self.workerID, fieldNumber: 1)
    }
    if !self.workerNickname.isEmpty {
      try visitor.visitSingularStringField(value: self.workerNickname, fieldNumber: 2)
    }
    if self.assignNum != 0 {
      try visitor.visitSingularInt32Field(value: self.assignNum, fieldNumber: 3)
    }
    if self.replyRate != 0 {
      try visitor.visitSingularFloatField(value: self.replyRate, fieldNumber: 4)
    }
    if self.transferTaskNum != 0 {
      try visitor.visitSingularInt32Field(value: self.transferTaskNum, fieldNumber: 5)
    }
    if self.receiveTaskNum != 0 {
      try visitor.visitSingularInt32Field(value: self.receiveTaskNum, fieldNumber: 6)
    }
    if !self.responseDuration.isEmpty {
      try visitor.visitSingularStringField(value: self.responseDuration, fieldNumber: 7)
    }
    if self.groupID != 0 {
      try visitor.visitSingularInt32Field(value: self.groupID, fieldNumber: 8)
    }
    if !self.groupNickname.isEmpty {
      try visitor.visitSingularStringField(value: self.groupNickname, fieldNumber: 9)
    }
    if self.subGroupID != 0 {
      try visitor.visitSingularInt32Field(value: self.subGroupID, fieldNumber: 10)
    }
    if !self.subGroupNickname.isEmpty {
      try visitor.visitSingularStringField(value: self.subGroupNickname, fieldNumber: 11)
    }
    if self.workerIdentity != .workerPermNone {
      try visitor.visitSingularEnumField(value: self.workerIdentity, fieldNumber: 12)
    }
    if !self.serverDuration.isEmpty {
      try visitor.visitSingularStringField(value: self.serverDuration, fieldNumber: 13)
    }
    if !self.onlineDuration.isEmpty {
      try visitor.visitSingularStringField(value: self.onlineDuration, fieldNumber: 14)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: Api_Core_WorkerStatistic, rhs: Api_Core_WorkerStatistic) -> Bool {
    if lhs.workerID != rhs.workerID {return false}
    if lhs.workerNickname != rhs.workerNickname {return false}
    if lhs.assignNum != rhs.assignNum {return false}
    if lhs.replyRate != rhs.replyRate {return false}
    if lhs.transferTaskNum != rhs.transferTaskNum {return false}
    if lhs.receiveTaskNum != rhs.receiveTaskNum {return false}
    if lhs.responseDuration != rhs.responseDuration {return false}
    if lhs.groupID != rhs.groupID {return false}
    if lhs.groupNickname != rhs.groupNickname {return false}
    if lhs.subGroupID != rhs.subGroupID {return false}
    if lhs.subGroupNickname != rhs.subGroupNickname {return false}
    if lhs.workerIdentity != rhs.workerIdentity {return false}
    if lhs.serverDuration != rhs.serverDuration {return false}
    if lhs.onlineDuration != rhs.onlineDuration {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}
