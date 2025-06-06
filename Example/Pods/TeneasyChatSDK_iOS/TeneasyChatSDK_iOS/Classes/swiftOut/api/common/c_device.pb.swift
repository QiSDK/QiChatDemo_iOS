// DO NOT EDIT.
// swift-format-ignore-file
// swiftlint:disable all
//
// Generated by the Swift generator plugin for the protocol buffer compiler.
// Source: api/common/c_device.proto
//
// For information on using the generated types, please see the documentation:
//   https://github.com/apple/swift-protobuf/

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

public enum CommonDeviceType: SwiftProtobuf.Enum, Swift.CaseIterable {
  public typealias RawValue = Int

  /// 系统平台
  case system // = 0

  /// 桌面设备
  case desktop // = 1

  /// IOS
  case ios // = 2

  /// Android
  case android // = 3
  case UNRECOGNIZED(Int)

  public init() {
    self = .system
  }

  public init?(rawValue: Int) {
    switch rawValue {
    case 0: self = .system
    case 1: self = .desktop
    case 2: self = .ios
    case 3: self = .android
    default: self = .UNRECOGNIZED(rawValue)
    }
  }

  public var rawValue: Int {
    switch self {
    case .system: return 0
    case .desktop: return 1
    case .ios: return 2
    case .android: return 3
    case .UNRECOGNIZED(let i): return i
    }
  }

  // The compiler won't synthesize support with the UNRECOGNIZED case.
  public static let allCases: [CommonDeviceType] = [
    .system,
    .desktop,
    .ios,
    .android,
  ]

}

// MARK: - Code below here is support for the SwiftProtobuf runtime.

extension CommonDeviceType: SwiftProtobuf._ProtoNameProviding {
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    0: .same(proto: "System"),
    1: .same(proto: "Desktop"),
    2: .same(proto: "Ios"),
    3: .same(proto: "Android"),
  ]
}
