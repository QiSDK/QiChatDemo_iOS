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
        
        self.leftBubbleColor = leftBubbleColor ?? UIColor.red.withAlphaComponent(0.88)
        
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

    // MARK: - 精选主题预设

    /// 随机获取一个精选主题
    public static func random() -> ChatTheme {
        presets.randomElement() ?? .default
        //presets[1]
    }

    /// 6 套精选主题
    public static let presets: [ChatTheme] = [
        // 1. 晴空蓝 (默认蓝系,清爽专业)
        ChatTheme(
            gradientStartColor: UIColor(red: 0.94, green: 0.97, blue: 1.0, alpha: 1.0),
            gradientEndColor:   UIColor(red: 0.78, green: 0.88, blue: 1.0, alpha: 1.0),
            gradientDirection: GradientDirection.bottomToTop,
            tintColor: UIColor(red: 69/255, green: 137/255, blue: 246/255, alpha: 1.0),
            leftBubbleColor: UIColor(red: 0.94, green: 0.97, blue: 1.0, alpha: 0.3),
            leftBubbleTextColor: UIColor(white: 0.15, alpha: 1.0),
        ),
        // 2. 薄暮紫 (优雅渐变紫)
        ChatTheme(
            gradientStartColor: UIColor(red: 0.96, green: 0.93, blue: 0.98, alpha: 1.0),
            gradientEndColor:   UIColor(red: 0.82, green: 0.72, blue: 0.92, alpha: 1.0),
            tintColor: UIColor(red: 128/255, green: 90/255, blue: 210/255, alpha: 1.0),
            leftBubbleColor: UIColor(red: 0.96, green: 0.93, blue: 0.98, alpha: 0.3),
            leftBubbleTextColor: UIColor(white: 0.15, alpha: 1.0),
        ),
        // 3. 蜜桃粉 (温暖柔和)
        ChatTheme(
            gradientStartColor: UIColor(red: 1.0, green: 0.96, blue: 0.95, alpha: 1.0),
            gradientEndColor:   UIColor(red: 1.0, green: 0.85, blue: 0.82, alpha: 1.0),
            gradientDirection: GradientDirection.bottomToTop, tintColor: UIColor(red: 235/255, green: 105/255, blue: 110/255, alpha: 1.0),
            leftBubbleColor: UIColor(red: 1.0, green: 0.96, blue: 0.95, alpha: 0.3),
            leftBubbleTextColor: UIColor(white: 0.15, alpha: 1.0)
        ),
        // 4. 抹茶绿 (清新自然)
        ChatTheme(
            gradientStartColor: UIColor(red: 0.95, green: 0.98, blue: 0.93, alpha: 1.0),
            gradientEndColor:   UIColor(red: 0.82, green: 0.93, blue: 0.76, alpha: 1.0),
            tintColor: UIColor(red: 76/255, green: 175/255, blue: 80/255, alpha: 1.0),
            leftBubbleColor: UIColor(red: 0.95, green: 0.98, blue: 0.93, alpha: 0.3),
            leftBubbleTextColor: UIColor(white: 0.15, alpha: 1.0),
        ),
        // 5. 日落橙 (活力暖色)
        ChatTheme(
            gradientStartColor: UIColor(red: 1.0, green: 0.97, blue: 0.92, alpha: 1.0),
            gradientEndColor:   UIColor(red: 1.0, green: 0.88, blue: 0.72, alpha: 1.0),
            gradientDirection: GradientDirection.bottomToTop,
            tintColor: UIColor(red: 255/255, green: 152/255, blue: 0/255, alpha: 1.0),
            leftBubbleColor: UIColor(red: 1.0, green: 0.97, blue: 0.92, alpha: 0.3),
            leftBubbleTextColor: UIColor(white: 0.15, alpha: 1.0),
        ),
        // 6. 星空靛 (深邃高级感)
        ChatTheme(
            gradientStartColor: UIColor(red: 0.88, green: 0.90, blue: 0.97, alpha: 1.0),
            gradientEndColor:   UIColor(red: 0.62, green: 0.68, blue: 0.88, alpha: 1.0),
            tintColor: UIColor(red: 63/255, green: 81/255, blue: 181/255, alpha: 1.0),
            leftBubbleColor: UIColor(red: 0.88, green: 0.90, blue: 0.97, alpha: 0.3),
            leftBubbleTextColor: UIColor(white: 0.15, alpha: 1.0),
        ),
        // 7. 暗夜紫 (深色优雅,高端质感)
        ChatTheme(
            gradientStartColor: UIColor(red: 0.78, green: 0.15, blue: 0.42, alpha: 1.0),
            gradientEndColor:   UIColor(red: 0.12, green: 0.06, blue: 0.24, alpha: 1.0),
            gradientDirection: GradientDirection.bottomToTop,
            tintColor: UIColor(red: 0.58, green: 0.42, blue: 0.95, alpha: 1.0),
            leftBubbleColor: UIColor(red: 0.78, green: 0.15, blue: 0.42, alpha: 0.3),
            leftBubbleTextColor: UIColor(white: 0.9, alpha: 1.0),
            rightBubbleColor: UIColor(red: 0.50, green: 0.35, blue: 0.88, alpha: 0.92),
            rightBubbleTextColor: UIColor(white: 1.0, alpha: 0.95)
        ),
        // 8. 极简灰 (纯色背景,干净利落)
        ChatTheme(
            gradientStartColor: UIColor(red: 246/255, green: 247/255, blue: 250/255, alpha: 1.0),
            gradientEndColor:   UIColor(red: 246/255, green: 247/255, blue: 250/255, alpha: 1.0),
            tintColor: UIColor(red: 55/255, green: 120/255, blue: 244/255, alpha: 1.0),
            leftBubbleColor: UIColor(white: 1.0, alpha: 0.92),
            leftBubbleTextColor: UIColor(white: 0.15, alpha: 1.0),
            rightBubbleColor: UIColor(red: 55/255, green: 120/255, blue: 244/255, alpha: 0.92),
            rightBubbleTextColor: UIColor(white: 1.0, alpha: 0.95)
        ),
        // 9. 幻夜紫 (深紫渐变,神秘高级)
        ChatTheme(
            gradientStartColor: UIColor(red: 165/255, green: 150/255, blue: 187/255, alpha: 1.0),
            gradientEndColor:   UIColor(red: 31/255, green: 31/255, blue: 76/255, alpha: 1.0),
            gradientDirection: GradientDirection.bottomToTop,
            tintColor: UIColor(red: 155/255, green: 120/255, blue: 240/255, alpha: 1.0),
            leftBubbleColor: UIColor(red: 165/255, green: 150/255, blue: 187/255, alpha: 0.3),
            leftBubbleTextColor: UIColor(white: 0.9, alpha: 1.0),
            rightBubbleColor: UIColor(red: 120/255, green: 85/255, blue: 210/255, alpha: 0.90),
            rightBubbleTextColor: UIColor(white: 1.0, alpha: 0.95)
        )
    ]
}

/// 实现该协议的 Cell 可在 cellForRow 时接收主题
public protocol ChatThemable: AnyObject {
    func applyTheme(_ theme: ChatTheme)
}

public extension ChatTheme.GradientDirection {
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
