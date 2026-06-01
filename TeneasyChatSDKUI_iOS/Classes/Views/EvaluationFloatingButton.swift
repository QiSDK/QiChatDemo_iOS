//
//  EvaluationFloatingButton.swift
//  TeneasyChatSDKUI_iOS
//
//  客服评价浮动按钮 (常驻于输入框上方左侧)
//

import UIKit
import SnapKit

class EvaluationFloatingButton: UIButton {

    private let theme: ChatTheme

    /// 已评价/已关闭时置灰且不可点（对应 Flutter 的 _evaluationDone）
    var isDone: Bool = false {
        didSet { applyTitle() }
    }

    init(theme: ChatTheme) {
        self.theme = theme
        super.init(frame: .zero)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }

    private func setupUI() {
        backgroundColor = UIColor(white: 0.92, alpha: 0.95)
        layer.cornerRadius = 16
        layer.masksToBounds = true
        contentEdgeInsets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
        applyTitle()
    }

    private func applyTitle() {
        let starColor = isDone ? UIColor(white: 0.78, alpha: 1.0) : theme.tintColor
        let textColor = isDone ? UIColor(white: 0.6, alpha: 1.0) : UIColor(white: 0.2, alpha: 1.0)

        let title = NSMutableAttributedString(
            string: "★ ",
            attributes: [
                .foregroundColor: starColor,
                .font: UIFont.systemFont(ofSize: 16, weight: .medium)
            ]
        )
        title.append(NSAttributedString(
            string: "客服评价",
            attributes: [
                .foregroundColor: textColor,
                .font: UIFont.systemFont(ofSize: 14, weight: .medium)
            ]
        ))
        setAttributedTitle(title, for: .normal)
    }
}
