//
//  BWQuestionSectionHeader.swift
//  TeneasyChatSDKUI_iOS
//
//  Created by Xiao Fu on 2024/5/8.
//

import Foundation

class BWQuestionSectionHeader: UITableViewHeaderFooterView {
    // 定义组头视图中的控件
    var titleLabel: UILabel = .init()
    var imgView: UIImageView = .init()

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)

        contentView.addSubview(imgView)
        imgView.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-12).priority(.high)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(24).priority(.high)
        }

        // 创建和布局组头视图中的控件
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(12)
            make.right.equalTo(imgView.snp.left).offset(-10).priority(.high)
            make.centerY.equalToSuperview()
        }

        // 设置内容压缩和拉伸优先级
        titleLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        imgView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
