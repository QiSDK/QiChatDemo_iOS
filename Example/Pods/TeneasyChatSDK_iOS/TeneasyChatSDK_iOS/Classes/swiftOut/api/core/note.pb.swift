// DO NOT EDIT.
// swift-format-ignore-file
//
// Generated by the Swift generator plugin for the protocol buffer compiler.
// Source: api/core/note.proto
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

/// 面向前端友好的交互结构
public struct Api_Core_NoteItem {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  public var workerID: Int32 = 0

  public var workerName: String = String()

  public var createAt: SwiftProtobuf.Google_Protobuf_Timestamp {
    get {return _createAt ?? SwiftProtobuf.Google_Protobuf_Timestamp()}
    set {_createAt = newValue}
  }
  /// Returns true if `createAt` has been explicitly set.
  public var hasCreateAt: Bool {return self._createAt != nil}
  /// Clears the value of `createAt`. Subsequent reads from it will return its default value.
  public mutating func clearCreateAt() {self._createAt = nil}

  /// 客服备注的消息
  public var noteMsg: CommonMessage {
    get {return _noteMsg ?? CommonMessage()}
    set {_noteMsg = newValue}
  }
  /// Returns true if `noteMsg` has been explicitly set.
  public var hasNoteMsg: Bool {return self._noteMsg != nil}
  /// Clears the value of `noteMsg`. Subsequent reads from it will return its default value.
  public mutating func clearNoteMsg() {self._noteMsg = nil}

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public init() {}

  fileprivate var _createAt: SwiftProtobuf.Google_Protobuf_Timestamp? = nil
  fileprivate var _noteMsg: CommonMessage? = nil
}

public struct Api_Core_Note {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  public var chatNoteMsgID: Int64 = 0

  public var src: CommonMessage {
    get {return _src ?? CommonMessage()}
    set {_src = newValue}
  }
  /// Returns true if `src` has been explicitly set.
  public var hasSrc: Bool {return self._src != nil}
  /// Clears the value of `src`. Subsequent reads from it will return its default value.
  public mutating func clearSrc() {self._src = nil}

  public var notes: [Api_Core_NoteItem] = []

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public init() {}

  fileprivate var _src: CommonMessage? = nil
}

public struct Api_Core_QueryNoteRequest {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  public var chatID: Int64 = 0

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

  fileprivate var _batch: CommonBatch? = nil
}

public struct Api_Core_QueryNoteResponse {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  public var chatID: Int64 = 0

  public var total: Int64 = 0

  public var batch: CommonBatch {
    get {return _batch ?? CommonBatch()}
    set {_batch = newValue}
  }
  /// Returns true if `batch` has been explicitly set.
  public var hasBatch: Bool {return self._batch != nil}
  /// Clears the value of `batch`. Subsequent reads from it will return its default value.
  public mutating func clearBatch() {self._batch = nil}

  public var notes: [Api_Core_Note] = []

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public init() {}

  fileprivate var _batch: CommonBatch? = nil
}

public struct Api_Core_CreateNoteRequest {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  public var chatID: Int64 = 0

  public var src: CommonMessage {
    get {return _src ?? CommonMessage()}
    set {_src = newValue}
  }
  /// Returns true if `src` has been explicitly set.
  public var hasSrc: Bool {return self._src != nil}
  /// Clears the value of `src`. Subsequent reads from it will return its default value.
  public mutating func clearSrc() {self._src = nil}

  public var noteMsg: CommonMessage {
    get {return _noteMsg ?? CommonMessage()}
    set {_noteMsg = newValue}
  }
  /// Returns true if `noteMsg` has been explicitly set.
  public var hasNoteMsg: Bool {return self._noteMsg != nil}
  /// Clears the value of `noteMsg`. Subsequent reads from it will return its default value.
  public mutating func clearNoteMsg() {self._noteMsg = nil}

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public init() {}

  fileprivate var _src: CommonMessage? = nil
  fileprivate var _noteMsg: CommonMessage? = nil
}

public struct Api_Core_CreateNoteResponse {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  /// 创建后的 note
  public var note: Api_Core_Note {
    get {return _note ?? Api_Core_Note()}
    set {_note = newValue}
  }
  /// Returns true if `note` has been explicitly set.
  public var hasNote: Bool {return self._note != nil}
  /// Clears the value of `note`. Subsequent reads from it will return its default value.
  public mutating func clearNote() {self._note = nil}

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public init() {}

  fileprivate var _note: Api_Core_Note? = nil
}

public struct Api_Core_UpdateNoteRequest {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  public var chatID: Int64 = 0

  public var chatNoteMsgID: Int64 = 0

  public var createAt: SwiftProtobuf.Google_Protobuf_Timestamp {
    get {return _createAt ?? SwiftProtobuf.Google_Protobuf_Timestamp()}
    set {_createAt = newValue}
  }
  /// Returns true if `createAt` has been explicitly set.
  public var hasCreateAt: Bool {return self._createAt != nil}
  /// Clears the value of `createAt`. Subsequent reads from it will return its default value.
  public mutating func clearCreateAt() {self._createAt = nil}

  public var noteMsg: CommonMessage {
    get {return _noteMsg ?? CommonMessage()}
    set {_noteMsg = newValue}
  }
  /// Returns true if `noteMsg` has been explicitly set.
  public var hasNoteMsg: Bool {return self._noteMsg != nil}
  /// Clears the value of `noteMsg`. Subsequent reads from it will return its default value.
  public mutating func clearNoteMsg() {self._noteMsg = nil}

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public init() {}

  fileprivate var _createAt: SwiftProtobuf.Google_Protobuf_Timestamp? = nil
  fileprivate var _noteMsg: CommonMessage? = nil
}

public struct Api_Core_UpdateNoteResponse {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  /// 修改后的 note
  public var note: Api_Core_Note {
    get {return _note ?? Api_Core_Note()}
    set {_note = newValue}
  }
  /// Returns true if `note` has been explicitly set.
  public var hasNote: Bool {return self._note != nil}
  /// Clears the value of `note`. Subsequent reads from it will return its default value.
  public mutating func clearNote() {self._note = nil}

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public init() {}

  fileprivate var _note: Api_Core_Note? = nil
}

public struct Api_Core_DeleteNoteRequest {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  public var chatID: Int64 = 0

  public var chatNoteMsgID: Int64 = 0

  public var createAt: SwiftProtobuf.Google_Protobuf_Timestamp {
    get {return _createAt ?? SwiftProtobuf.Google_Protobuf_Timestamp()}
    set {_createAt = newValue}
  }
  /// Returns true if `createAt` has been explicitly set.
  public var hasCreateAt: Bool {return self._createAt != nil}
  /// Clears the value of `createAt`. Subsequent reads from it will return its default value.
  public mutating func clearCreateAt() {self._createAt = nil}

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public init() {}

  fileprivate var _createAt: SwiftProtobuf.Google_Protobuf_Timestamp? = nil
}

#if swift(>=5.5) && canImport(_Concurrency)
extension Api_Core_NoteItem: @unchecked Sendable {}
extension Api_Core_Note: @unchecked Sendable {}
extension Api_Core_QueryNoteRequest: @unchecked Sendable {}
extension Api_Core_QueryNoteResponse: @unchecked Sendable {}
extension Api_Core_CreateNoteRequest: @unchecked Sendable {}
extension Api_Core_CreateNoteResponse: @unchecked Sendable {}
extension Api_Core_UpdateNoteRequest: @unchecked Sendable {}
extension Api_Core_UpdateNoteResponse: @unchecked Sendable {}
extension Api_Core_DeleteNoteRequest: @unchecked Sendable {}
#endif  // swift(>=5.5) && canImport(_Concurrency)

// MARK: - Code below here is support for the SwiftProtobuf runtime.

fileprivate let _protobuf_package = "api.core"

extension Api_Core_NoteItem: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = _protobuf_package + ".NoteItem"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .standard(proto: "worker_id"),
    2: .standard(proto: "worker_name"),
    3: .standard(proto: "create_at"),
    4: .standard(proto: "note_msg"),
  ]

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularInt32Field(value: &self.workerID) }()
      case 2: try { try decoder.decodeSingularStringField(value: &self.workerName) }()
      case 3: try { try decoder.decodeSingularMessageField(value: &self._createAt) }()
      case 4: try { try decoder.decodeSingularMessageField(value: &self._noteMsg) }()
      default: break
      }
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    // The use of inline closures is to circumvent an issue where the compiler
    // allocates stack space for every if/case branch local when no optimizations
    // are enabled. https://github.com/apple/swift-protobuf/issues/1034 and
    // https://github.com/apple/swift-protobuf/issues/1182
    if self.workerID != 0 {
      try visitor.visitSingularInt32Field(value: self.workerID, fieldNumber: 1)
    }
    if !self.workerName.isEmpty {
      try visitor.visitSingularStringField(value: self.workerName, fieldNumber: 2)
    }
    try { if let v = self._createAt {
      try visitor.visitSingularMessageField(value: v, fieldNumber: 3)
    } }()
    try { if let v = self._noteMsg {
      try visitor.visitSingularMessageField(value: v, fieldNumber: 4)
    } }()
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: Api_Core_NoteItem, rhs: Api_Core_NoteItem) -> Bool {
    if lhs.workerID != rhs.workerID {return false}
    if lhs.workerName != rhs.workerName {return false}
    if lhs._createAt != rhs._createAt {return false}
    if lhs._noteMsg != rhs._noteMsg {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Api_Core_Note: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = _protobuf_package + ".Note"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .standard(proto: "chat_note_msg_id"),
    2: .same(proto: "src"),
    3: .same(proto: "notes"),
  ]

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularInt64Field(value: &self.chatNoteMsgID) }()
      case 2: try { try decoder.decodeSingularMessageField(value: &self._src) }()
      case 3: try { try decoder.decodeRepeatedMessageField(value: &self.notes) }()
      default: break
      }
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    // The use of inline closures is to circumvent an issue where the compiler
    // allocates stack space for every if/case branch local when no optimizations
    // are enabled. https://github.com/apple/swift-protobuf/issues/1034 and
    // https://github.com/apple/swift-protobuf/issues/1182
    if self.chatNoteMsgID != 0 {
      try visitor.visitSingularInt64Field(value: self.chatNoteMsgID, fieldNumber: 1)
    }
    try { if let v = self._src {
      try visitor.visitSingularMessageField(value: v, fieldNumber: 2)
    } }()
    if !self.notes.isEmpty {
      try visitor.visitRepeatedMessageField(value: self.notes, fieldNumber: 3)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: Api_Core_Note, rhs: Api_Core_Note) -> Bool {
    if lhs.chatNoteMsgID != rhs.chatNoteMsgID {return false}
    if lhs._src != rhs._src {return false}
    if lhs.notes != rhs.notes {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Api_Core_QueryNoteRequest: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = _protobuf_package + ".QueryNoteRequest"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .standard(proto: "chat_id"),
    2: .same(proto: "batch"),
  ]

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularInt64Field(value: &self.chatID) }()
      case 2: try { try decoder.decodeSingularMessageField(value: &self._batch) }()
      default: break
      }
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    // The use of inline closures is to circumvent an issue where the compiler
    // allocates stack space for every if/case branch local when no optimizations
    // are enabled. https://github.com/apple/swift-protobuf/issues/1034 and
    // https://github.com/apple/swift-protobuf/issues/1182
    if self.chatID != 0 {
      try visitor.visitSingularInt64Field(value: self.chatID, fieldNumber: 1)
    }
    try { if let v = self._batch {
      try visitor.visitSingularMessageField(value: v, fieldNumber: 2)
    } }()
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: Api_Core_QueryNoteRequest, rhs: Api_Core_QueryNoteRequest) -> Bool {
    if lhs.chatID != rhs.chatID {return false}
    if lhs._batch != rhs._batch {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Api_Core_QueryNoteResponse: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = _protobuf_package + ".QueryNoteResponse"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .standard(proto: "chat_id"),
    2: .same(proto: "total"),
    3: .same(proto: "batch"),
    4: .same(proto: "notes"),
  ]

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularInt64Field(value: &self.chatID) }()
      case 2: try { try decoder.decodeSingularInt64Field(value: &self.total) }()
      case 3: try { try decoder.decodeSingularMessageField(value: &self._batch) }()
      case 4: try { try decoder.decodeRepeatedMessageField(value: &self.notes) }()
      default: break
      }
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    // The use of inline closures is to circumvent an issue where the compiler
    // allocates stack space for every if/case branch local when no optimizations
    // are enabled. https://github.com/apple/swift-protobuf/issues/1034 and
    // https://github.com/apple/swift-protobuf/issues/1182
    if self.chatID != 0 {
      try visitor.visitSingularInt64Field(value: self.chatID, fieldNumber: 1)
    }
    if self.total != 0 {
      try visitor.visitSingularInt64Field(value: self.total, fieldNumber: 2)
    }
    try { if let v = self._batch {
      try visitor.visitSingularMessageField(value: v, fieldNumber: 3)
    } }()
    if !self.notes.isEmpty {
      try visitor.visitRepeatedMessageField(value: self.notes, fieldNumber: 4)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: Api_Core_QueryNoteResponse, rhs: Api_Core_QueryNoteResponse) -> Bool {
    if lhs.chatID != rhs.chatID {return false}
    if lhs.total != rhs.total {return false}
    if lhs._batch != rhs._batch {return false}
    if lhs.notes != rhs.notes {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Api_Core_CreateNoteRequest: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = _protobuf_package + ".CreateNoteRequest"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .standard(proto: "chat_id"),
    2: .same(proto: "src"),
    3: .standard(proto: "note_msg"),
  ]

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularInt64Field(value: &self.chatID) }()
      case 2: try { try decoder.decodeSingularMessageField(value: &self._src) }()
      case 3: try { try decoder.decodeSingularMessageField(value: &self._noteMsg) }()
      default: break
      }
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    // The use of inline closures is to circumvent an issue where the compiler
    // allocates stack space for every if/case branch local when no optimizations
    // are enabled. https://github.com/apple/swift-protobuf/issues/1034 and
    // https://github.com/apple/swift-protobuf/issues/1182
    if self.chatID != 0 {
      try visitor.visitSingularInt64Field(value: self.chatID, fieldNumber: 1)
    }
    try { if let v = self._src {
      try visitor.visitSingularMessageField(value: v, fieldNumber: 2)
    } }()
    try { if let v = self._noteMsg {
      try visitor.visitSingularMessageField(value: v, fieldNumber: 3)
    } }()
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: Api_Core_CreateNoteRequest, rhs: Api_Core_CreateNoteRequest) -> Bool {
    if lhs.chatID != rhs.chatID {return false}
    if lhs._src != rhs._src {return false}
    if lhs._noteMsg != rhs._noteMsg {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Api_Core_CreateNoteResponse: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = _protobuf_package + ".CreateNoteResponse"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "note"),
  ]

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularMessageField(value: &self._note) }()
      default: break
      }
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    // The use of inline closures is to circumvent an issue where the compiler
    // allocates stack space for every if/case branch local when no optimizations
    // are enabled. https://github.com/apple/swift-protobuf/issues/1034 and
    // https://github.com/apple/swift-protobuf/issues/1182
    try { if let v = self._note {
      try visitor.visitSingularMessageField(value: v, fieldNumber: 1)
    } }()
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: Api_Core_CreateNoteResponse, rhs: Api_Core_CreateNoteResponse) -> Bool {
    if lhs._note != rhs._note {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Api_Core_UpdateNoteRequest: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = _protobuf_package + ".UpdateNoteRequest"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .standard(proto: "chat_id"),
    2: .standard(proto: "chat_note_msg_id"),
    3: .standard(proto: "create_at"),
    4: .standard(proto: "note_msg"),
  ]

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularInt64Field(value: &self.chatID) }()
      case 2: try { try decoder.decodeSingularInt64Field(value: &self.chatNoteMsgID) }()
      case 3: try { try decoder.decodeSingularMessageField(value: &self._createAt) }()
      case 4: try { try decoder.decodeSingularMessageField(value: &self._noteMsg) }()
      default: break
      }
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    // The use of inline closures is to circumvent an issue where the compiler
    // allocates stack space for every if/case branch local when no optimizations
    // are enabled. https://github.com/apple/swift-protobuf/issues/1034 and
    // https://github.com/apple/swift-protobuf/issues/1182
    if self.chatID != 0 {
      try visitor.visitSingularInt64Field(value: self.chatID, fieldNumber: 1)
    }
    if self.chatNoteMsgID != 0 {
      try visitor.visitSingularInt64Field(value: self.chatNoteMsgID, fieldNumber: 2)
    }
    try { if let v = self._createAt {
      try visitor.visitSingularMessageField(value: v, fieldNumber: 3)
    } }()
    try { if let v = self._noteMsg {
      try visitor.visitSingularMessageField(value: v, fieldNumber: 4)
    } }()
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: Api_Core_UpdateNoteRequest, rhs: Api_Core_UpdateNoteRequest) -> Bool {
    if lhs.chatID != rhs.chatID {return false}
    if lhs.chatNoteMsgID != rhs.chatNoteMsgID {return false}
    if lhs._createAt != rhs._createAt {return false}
    if lhs._noteMsg != rhs._noteMsg {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Api_Core_UpdateNoteResponse: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = _protobuf_package + ".UpdateNoteResponse"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "note"),
  ]

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularMessageField(value: &self._note) }()
      default: break
      }
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    // The use of inline closures is to circumvent an issue where the compiler
    // allocates stack space for every if/case branch local when no optimizations
    // are enabled. https://github.com/apple/swift-protobuf/issues/1034 and
    // https://github.com/apple/swift-protobuf/issues/1182
    try { if let v = self._note {
      try visitor.visitSingularMessageField(value: v, fieldNumber: 1)
    } }()
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: Api_Core_UpdateNoteResponse, rhs: Api_Core_UpdateNoteResponse) -> Bool {
    if lhs._note != rhs._note {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Api_Core_DeleteNoteRequest: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = _protobuf_package + ".DeleteNoteRequest"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .standard(proto: "chat_id"),
    2: .standard(proto: "chat_note_msg_id"),
    3: .standard(proto: "create_at"),
  ]

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularInt64Field(value: &self.chatID) }()
      case 2: try { try decoder.decodeSingularInt64Field(value: &self.chatNoteMsgID) }()
      case 3: try { try decoder.decodeSingularMessageField(value: &self._createAt) }()
      default: break
      }
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    // The use of inline closures is to circumvent an issue where the compiler
    // allocates stack space for every if/case branch local when no optimizations
    // are enabled. https://github.com/apple/swift-protobuf/issues/1034 and
    // https://github.com/apple/swift-protobuf/issues/1182
    if self.chatID != 0 {
      try visitor.visitSingularInt64Field(value: self.chatID, fieldNumber: 1)
    }
    if self.chatNoteMsgID != 0 {
      try visitor.visitSingularInt64Field(value: self.chatNoteMsgID, fieldNumber: 2)
    }
    try { if let v = self._createAt {
      try visitor.visitSingularMessageField(value: v, fieldNumber: 3)
    } }()
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: Api_Core_DeleteNoteRequest, rhs: Api_Core_DeleteNoteRequest) -> Bool {
    if lhs.chatID != rhs.chatID {return false}
    if lhs.chatNoteMsgID != rhs.chatNoteMsgID {return false}
    if lhs._createAt != rhs._createAt {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}
