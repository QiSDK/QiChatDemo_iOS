//
//  BWQuestionDialog.swift
//  TeneasyChatSDKUI_iOS
//
//  Created by Xiao Fu on 2024/5/8.
//

import UIKit

class BWQuestionDialog: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
                
        // 设置黑色背景
        let backgroundView = UIView(frame: self.view.bounds)
        backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        self.view.addSubview(backgroundView)
    }
}
