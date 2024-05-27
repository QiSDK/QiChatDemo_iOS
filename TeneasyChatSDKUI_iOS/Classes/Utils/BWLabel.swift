//
//  BWLabel.swift
//  TeneasyChatSDKUI_iOS_Example
//
//  Created by XiaoFu on 2023/2/1.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit
open class BWLabel: UILabel {
   open var textInsets: UIEdgeInsets = .zero
    open override func drawText(in rect: CGRect) {
           super.drawText(in: rect.insetBy(dx: textInsets.left, dy: textInsets.bottom))
       }
    open override func textRect(forBounds bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
           let insets = textInsets
           var rect = super.textRect(forBounds: bounds, limitedToNumberOfLines: numberOfLines)
           rect.size.width += (insets.left + insets.right)
           rect.size.height += (insets.top + insets.bottom)
           return rect
       }
}
