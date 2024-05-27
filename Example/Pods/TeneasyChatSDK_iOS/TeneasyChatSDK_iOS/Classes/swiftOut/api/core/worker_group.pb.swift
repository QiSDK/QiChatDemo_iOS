// DO NOT EDIT.
// swift-format-ignore-file
//
// Generated by the Swift generator plugin for the protocol buffer compiler.
// Source: api/core/worker_group.proto
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

/// 查询组
public struct Api_Core_WorkerGroupQueryResponse {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  public var items: [Api_Common_WorkerGroup] = []

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public init() {}
}

/// 创建分组
public struct Api_Core_WorkerGroupCreateRequest {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  /// 组名称
  public var name: String = String()

  /// 显示优先级
  public var priority: Int32 = 0

  public var children: [Api_Common_WorkerGroup] = []

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public init() {}
}

public struct Api_Core_WorkerGroupCreateResponse {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  public var id: Int64 = 0

  public var name: String = String()

  public var priority: Int32 = 0

  public var children: [Api_Common_WorkerGroup] = []

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public init() {}
}

/// 更新分组内容
public struct Api_Core_WorkerGroupUpdateRequest {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  /// 指定分组id
  public var id: Int64 = 0

  /// 全量更新
  public var name: String = String()

  public var priority: Int32 = 0

  public var children: [Api_Common_WorkerGroup] = []

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public init() {}
}

public struct Api_Core_WorkerGroupUpdateResponse {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  public var id: Int64 = 0

  public var name: String = String()

  public var priority: Int32 = 0

  public var children: [Api_Common_WorkerGroup] = []

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public init() {}
}

/// 删除分组
public struct Api_Core_WorkerGroupDeleteRequest {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  /// 指定分组id
  public var id: Int64 = 0

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public init() {}
}

public struct Api_Core_GroupQueryModel {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  public var id: Int64 = 0

  public var name: String = String()

  public var priority: Int32 = 0

  public var count: Int32 = 0

  public var groupAdmin: [String] = []

  public var groupLeader: [String] = []

  public var child: [Api_Common_WorkerGroup] = []

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public init() {}
}

public struct Api_Core_WorkerGroupQueryRequest {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  public var groupPid: Int64 {
    get {return _groupPid ?? 0}
    set {_groupPid = newValue}
  }
  /// Returns true if `groupPid` has been explicitly set.
  public var hasGroupPid: Bool {return self._groupPid != nil}
  /// Clears the value of `groupPid`. Subsequent reads from it will return its default value.
  public mutating func clearGroupPid() {self._groupPid = nil}

  public var groupCid: Int64 {
    get {return _groupCid ?? 0}
    set {_groupCid = newValue}
  }
  /// Returns true if `groupCid` has been explicitly set.
  public var hasGroupCid: Bool {return self._groupCid != nil}
  /// Clears the value of `groupCid`. Subsequent reads from it will return its default value.
  public mutating func clearGroupCid() {self._groupCid = nil}

  public var batch: CommonBatch {
    get {return _batch ?? CommonBatch()}
    set {_batch = newValue}
  }
  /// Returns true if `batch` has been explicitly set.
  public var hasBatch: Bool {return self._batch != nil}
  /// Clears the value of `batch`. Subsequent reads from it will return its default value.
  public mutating func clearBatch() {self._batch = nil}

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public init() {}

  fileprivate var _groupPid: Int64? = nil
  fileprivate var _groupCid: Int64? = nil
  fileprivate var _batch: CommonBatch? = nil
}

public struct Api_Core_WorkerGroupQueryResp {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  public var items: [Api_Core_GroupQueryModel] = []

  public var batch: CommonBatch {
    get {return _batch ?? CommonBatch()}
    set {_batch = newValue}
  }
  /// Returns true if `batch` has been explicitly set.
  public var hasBatch: Bool {return self._batch != nil}
  /// Clears the value of `batch`. Subsequent reads from it will return its default value.
  public mutating func clearBatch() {self._batch = nil}

  public var total: Int32 = 0

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public init() {}

  fileprivate var _batch: CommonBatch? = nil
}

#if swift(>=5.5) && canImport(_Concurrency)
extension Api_Core_WorkerGroupQueryResponse: @unchecked Sendable {}
extension Api_Core_WorkerGroupCreateRequest: @unchecked Sendable {}
extension Api_Core_WorkerGroupCreateResponse: @unchecked Sendable {}
extension Api_Core_WorkerGroupUpdateRequest: @unchecked Sendable {}
extension Api_Core_WorkerGroupUpdateResponse: @unchecked Sendable {}
extension Api_Core_WorkerGroupDeleteRequest: @unchecked Sendable {}
extension Api_Core_GroupQueryModel: @unchecked Sendable {}
extension Api_Core_WorkerGroupQueryRequest: @unchecked Sendable {}
extension Api_Core_WorkerGroupQueryResp: @unchecked Sendable {}
#endif  // swift(>=5.5) && canImport(_Concurrency)

// MARK: - Code below here is support for the SwiftProtobuf runtime.

fileprivate let _protobuf_package = "api.core"

extension Api_Core_WorkerGroupQueryResponse: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = _protobuf_package + ".WorkerGroupQueryResponse"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "items"),
  ]

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeRepeatedMessageField(value: &self.items) }()
      default: break
      }
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.items.isEmpty {
      try visitor.visitRepeatedMessageField(value: self.items, fieldNumber: 1)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: Api_Core_WorkerGroupQueryResponse, rhs: Api_Core_WorkerGroupQueryResponse) -> Bool {
    if lhs.items != rhs.items {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Api_Core_WorkerGroupCreateRequest: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = _protobuf_package + ".WorkerGroupCreateRequest"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "name"),
    2: .same(proto: "priority"),
    3: .same(proto: "children"),
  ]

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularStringField(value: &self.name) }()
      case 2: try { try decoder.decodeSingularInt32Field(value: &self.priority) }()
      case 3: try { try decoder.decodeRepeatedMessageField(value: &self.children) }()
      default: break
      }
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.name.isEmpty {
      try visitor.visitSingularStringField(value: self.name, fieldNumber: 1)
    }
    if self.priority != 0 {
      try visitor.visitSingularInt32Field(value: self.priority, fieldNumber: 2)
    }
    if !self.children.isEmpty {
      try visitor.visitRepeatedMessageField(value: self.children, fieldNumber: 3)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: Api_Core_WorkerGroupCreateRequest, rhs: Api_Core_WorkerGroupCreateRequest) -> Bool {
    if lhs.name != rhs.name {return false}
    if lhs.priority != rhs.priority {return false}
    if lhs.children != rhs.children {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Api_Core_WorkerGroupCreateResponse: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = _protobuf_package + ".WorkerGroupCreateResponse"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "id"),
    2: .same(proto: "name"),
    3: .same(proto: "priority"),
    4: .same(proto: "children"),
  ]

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularInt64Field(value: &self.id) }()
      case 2: try { try decoder.decodeSingularStringField(value: &self.name) }()
      case 3: try { try decoder.decodeSingularInt32Field(value: &self.priority) }()
      case 4: try { try decoder.decodeRepeatedMessageField(value: &self.children) }()
      default: break
      }
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if self.id != 0 {
      try visitor.visitSingularInt64Field(value: self.id, fieldNumber: 1)
    }
    if !self.name.isEmpty {
      try visitor.visitSingularStringField(value: self.name, fieldNumber: 2)
    }
    if self.priority != 0 {
      try visitor.visitSingularInt32Field(value: self.priority, fieldNumber: 3)
    }
    if !self.children.isEmpty {
      try visitor.visitRepeatedMessageField(value: self.children, fieldNumber: 4)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: Api_Core_WorkerGroupCreateResponse, rhs: Api_Core_WorkerGroupCreateResponse) -> Bool {
    if lhs.id != rhs.id {return false}
    if lhs.name != rhs.name {return false}
    if lhs.priority != rhs.priority {return false}
    if lhs.children != rhs.children {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Api_Core_WorkerGroupUpdateRequest: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = _protobuf_package + ".WorkerGroupUpdateRequest"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "id"),
    2: .same(proto: "name"),
    3: .same(proto: "priority"),
    4: .same(proto: "children"),
  ]

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularInt64Field(value: &self.id) }()
      case 2: try { try decoder.decodeSingularStringField(value: &self.name) }()
      case 3: try { try decoder.decodeSingularInt32Field(value: &self.priority) }()
      case 4: try { try decoder.decodeRepeatedMessageField(value: &self.children) }()
      default: break
      }
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if self.id != 0 {
      try visitor.visitSingularInt64Field(value: self.id, fieldNumber: 1)
    }
    if !self.name.isEmpty {
      try visitor.visitSingularStringField(value: self.name, fieldNumber: 2)
    }
    if self.priority != 0 {
      try visitor.visitSingularInt32Field(value: self.priority, fieldNumber: 3)
    }
    if !self.children.isEmpty {
      try visitor.visitRepeatedMessageField(value: self.children, fieldNumber: 4)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: Api_Core_WorkerGroupUpdateRequest, rhs: Api_Core_WorkerGroupUpdateRequest) -> Bool {
    if lhs.id != rhs.id {return false}
    if lhs.name != rhs.name {return false}
    if lhs.priority != rhs.priority {return false}
    if lhs.children != rhs.children {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Api_Core_WorkerGroupUpdateResponse: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = _protobuf_package + ".WorkerGroupUpdateResponse"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "id"),
    2: .same(proto: "name"),
    3: .same(proto: "priority"),
    4: .same(proto: "children"),
  ]

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularInt64Field(value: &self.id) }()
      case 2: try { try decoder.decodeSingularStringField(value: &self.name) }()
      case 3: try { try decoder.decodeSingularInt32Field(value: &self.priority) }()
      case 4: try { try decoder.decodeRepeatedMessageField(value: &self.children) }()
      default: break
      }
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if self.id != 0 {
      try visitor.visitSingularInt64Field(value: self.id, fieldNumber: 1)
    }
    if !self.name.isEmpty {
      try visitor.visitSingularStringField(value: self.name, fieldNumber: 2)
    }
    if self.priority != 0 {
      try visitor.visitSingularInt32Field(value: self.priority, fieldNumber: 3)
    }
    if !self.children.isEmpty {
      try visitor.visitRepeatedMessageField(value: self.children, fieldNumber: 4)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: Api_Core_WorkerGroupUpdateResponse, rhs: Api_Core_WorkerGroupUpdateResponse) -> Bool {
    if lhs.id != rhs.id {return false}
    if lhs.name != rhs.name {return false}
    if lhs.priority != rhs.priority {return false}
    if lhs.children != rhs.children {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Api_Core_WorkerGroupDeleteRequest: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = _protobuf_package + ".WorkerGroupDeleteRequest"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "id"),
  ]

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularInt64Field(value: &self.id) }()
      default: break
      }
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if self.id != 0 {
      try visitor.visitSingularInt64Field(value: self.id, fieldNumber: 1)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: Api_Core_WorkerGroupDeleteRequest, rhs: Api_Core_WorkerGroupDeleteRequest) -> Bool {
    if lhs.id != rhs.id {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Api_Core_GroupQueryModel: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = _protobuf_package + ".GroupQueryModel"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "id"),
    2: .same(proto: "name"),
    3: .same(proto: "priority"),
    4: .same(proto: "count"),
    5: .same(proto: "GroupAdmin"),
    6: .same(proto: "GroupLeader"),
    7: .same(proto: "child"),
  ]

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularInt64Field(value: &self.id) }()
      case 2: try { try decoder.decodeSingularStringField(value: &self.name) }()
      case 3: try { try decoder.decodeSingularInt32Field(value: &self.priority) }()
      case 4: try { try decoder.decodeSingularInt32Field(value: &self.count) }()
      case 5: try { try decoder.decodeRepeatedStringField(value: &self.groupAdmin) }()
      case 6: try { try decoder.decodeRepeatedStringField(value: &self.groupLeader) }()
      case 7: try { try decoder.decodeRepeatedMessageField(value: &self.child) }()
      default: break
      }
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if self.id != 0 {
      try visitor.visitSingularInt64Field(value: self.id, fieldNumber: 1)
    }
    if !self.name.isEmpty {
      try visitor.visitSingularStringField(value: self.name, fieldNumber: 2)
    }
    if self.priority != 0 {
      try visitor.visitSingularInt32Field(value: self.priority, fieldNumber: 3)
    }
    if self.count != 0 {
      try visitor.visitSingularInt32Field(value: self.count, fieldNumber: 4)
    }
    if !self.groupAdmin.isEmpty {
      try visitor.visitRepeatedStringField(value: self.groupAdmin, fieldNumber: 5)
    }
    if !self.groupLeader.isEmpty {
      try visitor.visitRepeatedStringField(value: self.groupLeader, fieldNumber: 6)
    }
    if !self.child.isEmpty {
      try visitor.visitRepeatedMessageField(value: self.child, fieldNumber: 7)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: Api_Core_GroupQueryModel, rhs: Api_Core_GroupQueryModel) -> Bool {
    if lhs.id != rhs.id {return false}
    if lhs.name != rhs.name {return false}
    if lhs.priority != rhs.priority {return false}
    if lhs.count != rhs.count {return false}
    if lhs.groupAdmin != rhs.groupAdmin {return false}
    if lhs.groupLeader != rhs.groupLeader {return false}
    if lhs.child != rhs.child {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Api_Core_WorkerGroupQueryRequest: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = _protobuf_package + ".WorkerGroupQueryRequest"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .standard(proto: "group_pid"),
    2: .standard(proto: "group_cid"),
    3: .same(proto: "batch"),
  ]

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularInt64Field(value: &self._groupPid) }()
      case 2: try { try decoder.decodeSingularInt64Field(value: &self._groupCid) }()
      case 3: try { try decoder.decodeSingularMessageField(value: &self._batch) }()
      default: break
      }
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    // The use of inline closures is to circumvent an issue where the compiler
    // allocates stack space for every if/case branch local when no optimizations
    // are enabled. https://github.com/apple/swift-protobuf/issues/1034 and
    // https://github.com/apple/swift-protobuf/issues/1182
    try { if let v = self._groupPid {
      try visitor.visitSingularInt64Field(value: v, fieldNumber: 1)
    } }()
    try { if let v = self._groupCid {
      try visitor.visitSingularInt64Field(value: v, fieldNumber: 2)
    } }()
    try { if let v = self._batch {
      try visitor.visitSingularMessageField(value: v, fieldNumber: 3)
    } }()
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: Api_Core_WorkerGroupQueryRequest, rhs: Api_Core_WorkerGroupQueryRequest) -> Bool {
    if lhs._groupPid != rhs._groupPid {return false}
    if lhs._groupCid != rhs._groupCid {return false}
    if lhs._batch != rhs._batch {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Api_Core_WorkerGroupQueryResp: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = _protobuf_package + ".WorkerGroupQueryResp"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "items"),
    2: .same(proto: "batch"),
    3: .same(proto: "total"),
  ]

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeRepeatedMessageField(value: &self.items) }()
      case 2: try { try decoder.decodeSingularMessageField(value: &self._batch) }()
      case 3: try { try decoder.decodeSingularInt32Field(value: &self.total) }()
      default: break
      }
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    // The use of inline closures is to circumvent an issue where the compiler
    // allocates stack space for every if/case branch local when no optimizations
    // are enabled. https://github.com/apple/swift-protobuf/issues/1034 and
    // https://github.com/apple/swift-protobuf/issues/1182
    if !self.items.isEmpty {
      try visitor.visitRepeatedMessageField(value: self.items, fieldNumber: 1)
    }
    try { if let v = self._batch {
      try visitor.visitSingularMessageField(value: v, fieldNumber: 2)
    } }()
    if self.total != 0 {
      try visitor.visitSingularInt32Field(value: self.total, fieldNumber: 3)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: Api_Core_WorkerGroupQueryResp, rhs: Api_Core_WorkerGroupQueryResp) -> Bool {
    if lhs.items != rhs.items {return false}
    if lhs._batch != rhs._batch {return false}
    if lhs.total != rhs.total {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}
