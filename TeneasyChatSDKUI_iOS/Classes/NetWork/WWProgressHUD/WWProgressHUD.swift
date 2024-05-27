//
//  WWProgressHUD.swift
//  ProgramIOS
//
//  Created by 韩寒 on 2021/7/10.
//

import UIKit
import SVProgressHUD

open class WWProgressHUD: NSObject {
    enum WWProgressHUDStatus {
        ///成功
        case success
        ///失败
        case error
        ///叹号提示
        case info
        ///等待
        case waitting
        ///只显示文字
        case onlyText
        ///过程
        case progress
    }
    
    /// 纯文字提示
    static func showTipMessage(_ msg: String?) {
        showWithStatus(hudStatus: .onlyText, text: msg, progress: 0)
        SVProgressHUD.setMinimumSize(.zero)
    }
    
    /// 带！图片的提示
    static func showInfoMsg(_ msg: String?) {
        showWithStatus(hudStatus: .info, text: msg, progress: 0)
    }
    
    ///错误 带X的图片
    static func showFailure(_ msg: String?) {
        showWithStatus(hudStatus: WWProgressHUDStatus.error, text: msg, progress: 0)
    }
    
    ///带图片 成功
    static func showSuccessWith(_ msg: String?) {
        showWithStatus(hudStatus: WWProgressHUDStatus.success, text: msg, progress: 0)
    }
    
    ///显示加载
    static func showLoading(_ msg: String? = nil) {
        showWithStatus(hudStatus: .waitting, text: msg ?? "请稍后···", progress: 0)
    }
    
    ///显示进度
    static func showProgress(_ msg: String?, progress: CGFloat) {
        showWithStatus(hudStatus: .progress, text: msg, progress: progress)
    }
    
    ///显示自定义gif动画
    static func showGif(image: String) {
        SVProgressHUD.setDefaultStyle(SVProgressHUDStyle.dark)
        SVProgressHUD.setCornerRadius(8)
//        SVProgressHUD.show(UIImage(withGIFNamed(image)), status: nil)
//        SVProgressHUD.show(UIImage(gifNamed: image), status: nil)
    }
    
    static func dismiss() {
        if SVProgressHUD.isVisible() {        
            SVProgressHUD.dismiss()
        }
    }
    
    static func showWithStatus(hudStatus status: WWProgressHUDStatus, text msg: String?, progress: CGFloat) {
        SVProgressHUD.setDefaultStyle(SVProgressHUDStyle.dark)
        SVProgressHUD.setCornerRadius(8)
        SVProgressHUD.setMinimumSize(CGSize(width: 120, height: 120))
        switch status {
        case .success:
            SVProgressHUD.showSuccess(withStatus: msg)
            SVProgressHUD.dismiss(withDelay: 2)
            break
        case .error:
            SVProgressHUD.showError(withStatus: msg)
            SVProgressHUD.dismiss(withDelay: 2)
            break
        case .info:
            SVProgressHUD.showInfo(withStatus: msg)
            SVProgressHUD.dismiss(withDelay: 2)
            break
        case .waitting:
            SVProgressHUD.show(withStatus: msg)
            SVProgressHUD.setDefaultMaskType(.clear)
            break
        case .onlyText:
            (SVProgressHUD.value(forKey: "sharedView") as? UIView)?.setValue(nil, forKey: "infoImage")
            SVProgressHUD.showInfo(withStatus: msg)
            SVProgressHUD.dismiss(withDelay: 2)
            break
        case .progress:
            SVProgressHUD.showProgress(Float(progress), status: msg)
        }
    }
}
