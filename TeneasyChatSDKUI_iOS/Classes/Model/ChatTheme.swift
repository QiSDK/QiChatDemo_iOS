//
//  ChatTheme.swift
//  TeneasyChatSDKUI_iOS
//
//  聊天页主题配置:渐变背景 + 统一按钮着色
//

import UIKit

public struct ChatTheme {

    public enum GradientDirection {
        case topToBottom
        case bottomToTop
        case leftToRight
        case rightToLeft
        case topLeftToBottomRight
        case topRightToBottomLeft
    }

    /// 渐变起始颜色 (支持 alpha)
    public var gradientStartColor: UIColor

    /// 渐变结束颜色 (支持 alpha)
    public var gradientEndColor: UIColor

    /// 渐变方向
    public var gradientDirection: GradientDirection

    /// 统一按钮 / 图标着色 (返回按钮、发送按钮、附件图标等)
    public var tintColor: UIColor

    public init(
        gradientStartColor: UIColor,
        gradientEndColor: UIColor,
        gradientDirection: GradientDirection = .topToBottom,
        tintColor: UIColor
    ) {
        self.gradientStartColor = gradientStartColor
        self.gradientEndColor = gradientEndColor
        self.gradientDirection = gradientDirection
        self.tintColor = tintColor
    }

    /// SDK 内置默认主题 (App 不传时使用)
    public static let `default` = ChatTheme(
        gradientStartColor: UIColor(red: 0.95, green: 0.97, blue: 1.0, alpha: 1.0),
        gradientEndColor:   UIColor(red: 0.80, green: 0.88, blue: 1.0, alpha: 1.0),
        gradientDirection: .topToBottom,
        tintColor: UIColor(red: 69/255, green: 137/255, blue: 246/255, alpha: 1.0)
    )
}

extension ChatTheme.GradientDirection {
    var startPoint: CGPoint {
        switch self {
        case .topToBottom:           return CGPoint(x: 0.5, y: 0.0)
        case .bottomToTop:           return CGPoint(x: 0.5, y: 1.0)
        case .leftToRight:           return CGPoint(x: 0.0, y: 0.5)
        case .rightToLeft:           return CGPoint(x: 1.0, y: 0.5)
        case .topLeftToBottomRight:  return CGPoint(x: 0.0, y: 0.0)
        case .topRightToBottomLeft:  return CGPoint(x: 1.0, y: 0.0)
        }
    }

    var endPoint: CGPoint {
        switch self {
        case .topToBottom:           return CGPoint(x: 0.5, y: 1.0)
        case .bottomToTop:           return CGPoint(x: 0.5, y: 0.0)
        case .leftToRight:           return CGPoint(x: 1.0, y: 0.5)
        case .rightToLeft:           return CGPoint(x: 0.0, y: 0.5)
        case .topLeftToBottomRight:  return CGPoint(x: 1.0, y: 1.0)
        case .topRightToBottomLeft:  return CGPoint(x: 0.0, y: 1.0)
        }
    }
}
