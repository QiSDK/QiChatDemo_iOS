// DO NOT EDIT.
// swift-format-ignore-file
//
// Generated by the Swift generator plugin for the protocol buffer compiler.
// Source: api/core/regular_reply.proto
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

/// 创建
public struct Api_Core_RegularReplyCreateRequest {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  /// 间隔定时回复时间，毫秒级
  public var regularTime: UInt64 = 0

  /// 咨询组Id
  public var consultID: Int64 = 0

  /// 1-开启，2-关闭
  public var replyType: Int32 = 0

  /// 回复名称
  public var name: String = String()

  /// 回复内容
  public var content: String = String()

  /// 回复图片
  public var imageUrls: CommonListString {
    get {return _imageUrls ?? CommonListString()}
    set {_imageUrls = newValue}
  }
  /// Returns true if `imageUrls` has been explicitly set.
  public var hasImageUrls: Bool {return self._imageUrls != nil}
  /// Clears the value of `imageUrls`. Subsequent reads from it will return its default value.
  public mutating func clearImageUrls() {self._imageUrls = nil}

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public init() {}

  fileprivate var _imageUrls: CommonListString? = nil
}

public struct Api_Core_RegularReplyCreateResponse {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  public var id: Int64 = 0

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public init() {}
}

/// 删除
public struct Api_Core_RegularReplyDeleteRequest {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  /// 主键id
  public var id: Int64 = 0

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public init() {}
}

/// 全量更新
public struct Api_Core_RegularReplyUpdateRequest {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  /// 主键id 
  public var id: Int64 = 0

  /// 间隔定时回复时间，毫秒级
  public var regularTime: UInt64 = 0

  /// 咨询组Id
  public var consultID: Int64 = 0

  /// 1-开启，2-关闭
  public var replyType: Int32 = 0

  /// 回复名称
  public var name: String = String()

  /// 回复内容
  public var content: String = String()

  /// 回复图片
  public var imageUrls: CommonListString {
    get {return _imageUrls ?? CommonListString()}
    set {_imageUrls = newValue}
  }
  /// Returns true if `imageUrls` has been explicitly set.
  public var hasImageUrls: Bool {return self._imageUrls != nil}
  /// Clears the value of `imageUrls`. Subsequent reads from it will return its default value.
  public mutating func clearImageUrls() {self._imageUrls = nil}

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public init() {}

  fileprivate var _imageUrls: CommonListString? = nil
}

/// 查询定时回复
public struct Api_Core_RegularReplyQueryRequest {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  /// 指定主键id查询，可选
  public var id: Int64 = 0

  /// 指定咨询组Id查询，可选
  public var consultID: Int64 = 0

  /// 指定reply状态查询，可选
  public var replyType: Int32 = 0

  /// 页数
  public var page: UInt32 = 0

  /// 每页大小
  public var pageSize: UInt32 = 0

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public init() {}
}

public struct Api_Core_RegularReplyItem {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  /// 主键id 
  public var id: Int64 = 0

  /// 间隔定时回复时间，毫秒级
  public var regularTime: UInt64 = 0

  /// 咨询组Id
  public var consultID: Int64 = 0

  /// 咨询组name
  public var consultName: String = String()

  /// 1-开启，2-关闭
  public var replyType: Int32 = 0

  /// 绑定的商户ID
  public var tenantID: Int64 = 0

  /// 回复名称
  public var name: String = String()

  /// 回复内容
  public var content: String = String()

  /// 回复图片
  public var imageUrls: CommonListString {
    get {return _imageUrls ?? CommonListString()}
    set {_imageUrls = newValue}
  }
  /// Returns true if `imageUrls` has been explicitly set.
  public var hasImageUrls: Bool {return self._imageUrls != nil}
  /// Clears the value of `imageUrls`. Subsequent reads from it will return its default value.
  public mutating func clearImageUrls() {self._imageUrls = nil}

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public init() {}

  fileprivate var _imageUrls: CommonListString? = nil
}

/// 查询定时回复返回
public struct Api_Core_RegularReplyResponse {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  public var items: [Api_Core_RegularReplyItem] = []

  public var total: Int32 = 0

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public init() {}
}

#if swift(>=5.5) && canImport(_Concurrency)
extension Api_Core_RegularReplyCreateRequest: @unchecked Sendable {}
extension Api_Core_RegularReplyCreateResponse: @unchecked Sendable {}
extension Api_Core_RegularReplyDeleteRequest: @unchecked Sendable {}
extension Api_Core_RegularReplyUpdateRequest: @unchecked Sendable {}
extension Api_Core_RegularReplyQueryRequest: @unchecked Sendable {}
extension Api_Core_RegularReplyItem: @unchecked Sendable {}
extension Api_Core_RegularReplyResponse: @unchecked Sendable {}
#endif  // swift(>=5.5) && canImport(_Concurrency)

// MARK: - Code below here is support for the SwiftProtobuf runtime.

fileprivate let _protobuf_package = "api.core"

extension Api_Core_RegularReplyCreateRequest: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = _protobuf_package + ".RegularReplyCreateRequest"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .standard(proto: "regular_time"),
    2: .standard(proto: "consult_id"),
    3: .standard(proto: "reply_type"),
    4: .same(proto: "name"),
    5: .same(proto: "content"),
    6: .standard(proto: "image_urls"),
  ]

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularUInt64Field(value: &self.regularTime) }()
      case 2: try { try decoder.decodeSingularInt64Field(value: &self.consultID) }()
      case 3: try { try decoder.decodeSingularInt32Field(value: &self.replyType) }()
      case 4: try { try decoder.decodeSingularStringField(value: &self.name) }()
      case 5: try { try decoder.decodeSingularStringField(value: &self.content) }()
      case 6: try { try decoder.decodeSingularMessageField(value: &self._imageUrls) }()
      default: break
      }
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    // The use of inline closures is to circumvent an issue where the compiler
    // allocates stack space for every if/case branch local when no optimizations
    // are enabled. https://github.com/apple/swift-protobuf/issues/1034 and
    // https://github.com/apple/swift-protobuf/issues/1182
    if self.regularTime != 0 {
      try visitor.visitSingularUInt64Field(value: self.regularTime, fieldNumber: 1)
    }
    if self.consultID != 0 {
      try visitor.visitSingularInt64Field(value: self.consultID, fieldNumber: 2)
    }
    if self.replyType != 0 {
      try visitor.visitSingularInt32Field(value: self.replyType, fieldNumber: 3)
    }
    if !self.name.isEmpty {
      try visitor.visitSingularStringField(value: self.name, fieldNumber: 4)
    }
    if !self.content.isEmpty {
      try visitor.visitSingularStringField(value: self.content, fieldNumber: 5)
    }
    try { if let v = self._imageUrls {
      try visitor.visitSingularMessageField(value: v, fieldNumber: 6)
    } }()
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: Api_Core_RegularReplyCreateRequest, rhs: Api_Core_RegularReplyCreateRequest) -> Bool {
    if lhs.regularTime != rhs.regularTime {return false}
    if lhs.consultID != rhs.consultID {return false}
    if lhs.replyType != rhs.replyType {return false}
    if lhs.name != rhs.name {return false}
    if lhs.content != rhs.content {return false}
    if lhs._imageUrls != rhs._imageUrls {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Api_Core_RegularReplyCreateResponse: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = _protobuf_package + ".RegularReplyCreateResponse"
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

  public static func ==(lhs: Api_Core_RegularReplyCreateResponse, rhs: Api_Core_RegularReplyCreateResponse) -> Bool {
    if lhs.id != rhs.id {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Api_Core_RegularReplyDeleteRequest: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = _protobuf_package + ".RegularReplyDeleteRequest"
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

  public static func ==(lhs: Api_Core_RegularReplyDeleteRequest, rhs: Api_Core_RegularReplyDeleteRequest) -> Bool {
    if lhs.id != rhs.id {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Api_Core_RegularReplyUpdateRequest: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = _protobuf_package + ".RegularReplyUpdateRequest"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "id"),
    2: .standard(proto: "regular_time"),
    3: .standard(proto: "consult_id"),
    4: .standard(proto: "reply_type"),
    5: .same(proto: "name"),
    6: .same(proto: "content"),
    7: .standard(proto: "image_urls"),
  ]

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularInt64Field(value: &self.id) }()
      case 2: try { try decoder.decodeSingularUInt64Field(value: &self.regularTime) }()
      case 3: try { try decoder.decodeSingularInt64Field(value: &self.consultID) }()
      case 4: try { try decoder.decodeSingularInt32Field(value: &self.replyType) }()
      case 5: try { try decoder.decodeSingularStringField(value: &self.name) }()
      case 6: try { try decoder.decodeSingularStringField(value: &self.content) }()
      case 7: try { try decoder.decodeSingularMessageField(value: &self._imageUrls) }()
      default: break
      }
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    // The use of inline closures is to circumvent an issue where the compiler
    // allocates stack space for every if/case branch local when no optimizations
    // are enabled. https://github.com/apple/swift-protobuf/issues/1034 and
    // https://github.com/apple/swift-protobuf/issues/1182
    if self.id != 0 {
      try visitor.visitSingularInt64Field(value: self.id, fieldNumber: 1)
    }
    if self.regularTime != 0 {
      try visitor.visitSingularUInt64Field(value: self.regularTime, fieldNumber: 2)
    }
    if self.consultID != 0 {
      try visitor.visitSingularInt64Field(value: self.consultID, fieldNumber: 3)
    }
    if self.replyType != 0 {
      try visitor.visitSingularInt32Field(value: self.replyType, fieldNumber: 4)
    }
    if !self.name.isEmpty {
      try visitor.visitSingularStringField(value: self.name, fieldNumber: 5)
    }
    if !self.content.isEmpty {
      try visitor.visitSingularStringField(value: self.content, fieldNumber: 6)
    }
    try { if let v = self._imageUrls {
      try visitor.visitSingularMessageField(value: v, fieldNumber: 7)
    } }()
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: Api_Core_RegularReplyUpdateRequest, rhs: Api_Core_RegularReplyUpdateRequest) -> Bool {
    if lhs.id != rhs.id {return false}
    if lhs.regularTime != rhs.regularTime {return false}
    if lhs.consultID != rhs.consultID {return false}
    if lhs.replyType != rhs.replyType {return false}
    if lhs.name != rhs.name {return false}
    if lhs.content != rhs.content {return false}
    if lhs._imageUrls != rhs._imageUrls {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Api_Core_RegularReplyQueryRequest: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = _protobuf_package + ".RegularReplyQueryRequest"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "id"),
    2: .standard(proto: "consult_id"),
    3: .standard(proto: "reply_type"),
    4: .same(proto: "page"),
    5: .same(proto: "pageSize"),
  ]

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularInt64Field(value: &self.id) }()
      case 2: try { try decoder.decodeSingularInt64Field(value: &self.consultID) }()
      case 3: try { try decoder.decodeSingularInt32Field(value: &self.replyType) }()
      case 4: try { try decoder.decodeSingularUInt32Field(value: &self.page) }()
      case 5: try { try decoder.decodeSingularUInt32Field(value: &self.pageSize) }()
      default: break
      }
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if self.id != 0 {
      try visitor.visitSingularInt64Field(value: self.id, fieldNumber: 1)
    }
    if self.consultID != 0 {
      try visitor.visitSingularInt64Field(value: self.consultID, fieldNumber: 2)
    }
    if self.replyType != 0 {
      try visitor.visitSingularInt32Field(value: self.replyType, fieldNumber: 3)
    }
    if self.page != 0 {
      try visitor.visitSingularUInt32Field(value: self.page, fieldNumber: 4)
    }
    if self.pageSize != 0 {
      try visitor.visitSingularUInt32Field(value: self.pageSize, fieldNumber: 5)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: Api_Core_RegularReplyQueryRequest, rhs: Api_Core_RegularReplyQueryRequest) -> Bool {
    if lhs.id != rhs.id {return false}
    if lhs.consultID != rhs.consultID {return false}
    if lhs.replyType != rhs.replyType {return false}
    if lhs.page != rhs.page {return false}
    if lhs.pageSize != rhs.pageSize {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Api_Core_RegularReplyItem: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = _protobuf_package + ".RegularReplyItem"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "id"),
    2: .standard(proto: "regular_time"),
    3: .standard(proto: "consult_id"),
    4: .standard(proto: "consult_name"),
    5: .standard(proto: "reply_type"),
    6: .standard(proto: "tenant_id"),
    7: .same(proto: "name"),
    8: .same(proto: "content"),
    9: .standard(proto: "image_urls"),
  ]

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularInt64Field(value: &self.id) }()
      case 2: try { try decoder.decodeSingularUInt64Field(value: &self.regularTime) }()
      case 3: try { try decoder.decodeSingularInt64Field(value: &self.consultID) }()
      case 4: try { try decoder.decodeSingularStringField(value: &self.consultName) }()
      case 5: try { try decoder.decodeSingularInt32Field(value: &self.replyType) }()
      case 6: try { try decoder.decodeSingularInt64Field(value: &self.tenantID) }()
      case 7: try { try decoder.decodeSingularStringField(value: &self.name) }()
      case 8: try { try decoder.decodeSingularStringField(value: &self.content) }()
      case 9: try { try decoder.decodeSingularMessageField(value: &self._imageUrls) }()
      default: break
      }
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    // The use of inline closures is to circumvent an issue where the compiler
    // allocates stack space for every if/case branch local when no optimizations
    // are enabled. https://github.com/apple/swift-protobuf/issues/1034 and
    // https://github.com/apple/swift-protobuf/issues/1182
    if self.id != 0 {
      try visitor.visitSingularInt64Field(value: self.id, fieldNumber: 1)
    }
    if self.regularTime != 0 {
      try visitor.visitSingularUInt64Field(value: self.regularTime, fieldNumber: 2)
    }
    if self.consultID != 0 {
      try visitor.visitSingularInt64Field(value: self.consultID, fieldNumber: 3)
    }
    if !self.consultName.isEmpty {
      try visitor.visitSingularStringField(value: self.consultName, fieldNumber: 4)
    }
    if self.replyType != 0 {
      try visitor.visitSingularInt32Field(value: self.replyType, fieldNumber: 5)
    }
    if self.tenantID != 0 {
      try visitor.visitSingularInt64Field(value: self.tenantID, fieldNumber: 6)
    }
    if !self.name.isEmpty {
      try visitor.visitSingularStringField(value: self.name, fieldNumber: 7)
    }
    if !self.content.isEmpty {
      try visitor.visitSingularStringField(value: self.content, fieldNumber: 8)
    }
    try { if let v = self._imageUrls {
      try visitor.visitSingularMessageField(value: v, fieldNumber: 9)
    } }()
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: Api_Core_RegularReplyItem, rhs: Api_Core_RegularReplyItem) -> Bool {
    if lhs.id != rhs.id {return false}
    if lhs.regularTime != rhs.regularTime {return false}
    if lhs.consultID != rhs.consultID {return false}
    if lhs.consultName != rhs.consultName {return false}
    if lhs.replyType != rhs.replyType {return false}
    if lhs.tenantID != rhs.tenantID {return false}
    if lhs.name != rhs.name {return false}
    if lhs.content != rhs.content {return false}
    if lhs._imageUrls != rhs._imageUrls {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Api_Core_RegularReplyResponse: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = _protobuf_package + ".RegularReplyResponse"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "items"),
    2: .same(proto: "total"),
  ]

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeRepeatedMessageField(value: &self.items) }()
      case 2: try { try decoder.decodeSingularInt32Field(value: &self.total) }()
      default: break
      }
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.items.isEmpty {
      try visitor.visitRepeatedMessageField(value: self.items, fieldNumber: 1)
    }
    if self.total != 0 {
      try visitor.visitSingularInt32Field(value: self.total, fieldNumber: 2)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: Api_Core_RegularReplyResponse, rhs: Api_Core_RegularReplyResponse) -> Bool {
    if lhs.items != rhs.items {return false}
    if lhs.total != rhs.total {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}
