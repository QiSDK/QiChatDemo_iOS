//
//  EvaluationFloatingButton.swift
//  TeneasyChatSDKUI_iOS
//
//  客服评价浮动按钮 (常驻于输入框上方左侧)
//

import UIKit
import SnapKit

class EvaluationFloatingButton: UIButton {

    init(theme: ChatTheme) {
        super.init(frame: .zero)
        setupUI(theme: theme)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    private func setupUI(theme: ChatTheme) {
        backgroundColor = UIColor(white: 0.92, alpha: 0.95)
        layer.cornerRadius = 16
        layer.masksToBounds = true
        contentEdgeInsets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)

        let title = NSMutableAttributedString(
            string: "★ ",
            attributes: [
                .foregroundColor: theme.tintColor,
                .font: UIFont.systemFont(ofSize: 16, weight: .medium)
            ]
        )
        title.append(NSAttributedString(
            string: "客服评价",
            attributes: [
                .foregroundColor: UIColor(white: 0.2, alpha: 1.0),
                .font: UIFont.systemFont(ofSize: 14, weight: .medium)
            ]
        ))
        setAttributedTitle(title, for: .normal)
    }
}
