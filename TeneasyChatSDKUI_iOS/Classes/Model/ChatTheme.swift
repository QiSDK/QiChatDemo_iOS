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

    /// 气泡阴影配置
    public struct BubbleShadow {
        public var color: UIColor
        public var opacity: Float
        public var radius: CGFloat
        public var offset: CGSize

        public init(color: UIColor, opacity: Float, radius: CGFloat, offset: CGSize) {
            self.color = color
            self.opacity = opacity
            self.radius = radius
            self.offset = offset
        }

        public static let `default` = BubbleShadow(
            color: .black,
            opacity: 0.06,
            radius: 6,
            offset: CGSize(width: 0, height: 2)
        )

        public static let none = BubbleShadow(color: .clear, opacity: 0, radius: 0, offset: .zero)
    }

    /// 渐变起始颜色 (支持 alpha)
    public var gradientStartColor: UIColor

    /// 渐变结束颜色 (支持 alpha)
    public var gradientEndColor: UIColor

    /// 渐变方向
    public var gradientDirection: GradientDirection

    /// 统一按钮 / 图标着色 (返回按钮、发送按钮、附件图标等)
    public var tintColor: UIColor

    /// 左侧 (客服) 气泡背景色,半透明让渐变背景透出来,与背景融合
    public var leftBubbleColor: UIColor

    /// 左侧 (客服) 气泡文字色
    public var leftBubbleTextColor: UIColor

    /// 右侧 (用户) 气泡背景色,默认从 tintColor 派生
    public var rightBubbleColor: UIColor

    /// 右侧 (用户) 气泡文字色
    public var rightBubbleTextColor: UIColor

    /// 气泡阴影
    public var bubbleShadow: BubbleShadow

    public init(
        gradientStartColor: UIColor,
        gradientEndColor: UIColor,
        gradientDirection: GradientDirection = .topToBottom,
        tintColor: UIColor,
        leftBubbleColor: UIColor? = nil,
        leftBubbleTextColor: UIColor? = nil,
        rightBubbleColor: UIColor? = nil,
        rightBubbleTextColor: UIColor? = nil,
        bubbleShadow: BubbleShadow = .default
    ) {
        self.gradientStartColor = gradientStartColor
        self.gradientEndColor = gradientEndColor
        self.gradientDirection = gradientDirection
        self.tintColor = tintColor
        self.leftBubbleColor = leftBubbleColor ?? UIColor.lightText.withAlphaComponent(0.88)
        self.leftBubbleTextColor = leftBubbleTextColor ?? UIColor(white: 0.1, alpha: 1.0)
        self.rightBubbleColor = rightBubbleColor ?? tintColor.withAlphaComponent(0.92)
        self.rightBubbleTextColor = rightBubbleTextColor ?? .white
        self.bubbleShadow = bubbleShadow
    }

    /// SDK 内置默认主题 (App 不传时使用)
    public static let `default` = ChatTheme(
        gradientStartColor: UIColor(red: 0.95, green: 0.97, blue: 1.0, alpha: 1.0),
        gradientEndColor:   UIColor(red: 0.80, green: 0.88, blue: 1.0, alpha: 1.0),
        gradientDirection: .topToBottom,
        tintColor: UIColor(red: 69/255, green: 137/255, blue: 246/255, alpha: 1.0)
    )
}

/// 实现该协议的 Cell 可在 cellForRow 时接收主题
public protocol ChatThemable: AnyObject {
    func applyTheme(_ theme: ChatTheme)
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
