//
//  NetworkLogPresenter.swift
//  TeneasyChatSDKUI_iOS
//
//  网络日志调试页的公开入口 - 与 Android TeneasyChatUISDK.openNetworkLog /
//  Flutter QiChatUISDK.openNetworkLog 对齐。
//
//  用法：
//  ```swift
//  // 打开网络日志页（隐藏在设置页某入口后面）
//  NetworkLogPresenter.present()
//  // 或显示可拖动悬浮按钮
//  NetworkLogPresenter.showFloatingButton()
//  NetworkLogPresenter.hideFloatingButton()
//  ```
//  日志由 NetworkLogPlugin 自动收集（ChatProvider 注册后即生效，最多保留 200 条）。
//

import UIKit

public enum NetworkLogPresenter {

    /// 打开「网络日志」页面。可选从指定 VC 弹出，不传则自动找当前顶层 VC。
    public static func present(from viewController: UIViewController? = nil) {
        let presenter = viewController ?? topViewController()
        guard let presenter = presenter else { return }
        let nav = UINavigationController(rootViewController: NetworkLogVC())
        nav.modalPresentationStyle = .fullScreen
        presenter.present(nav, animated: true)
    }

    /// 显示可拖动的「网络日志」悬浮按钮，点击打开日志页。仅建议调试期开启。
    public static func showFloatingButton() {
        NetworkLogFloatingButton.shared.show()
    }

    /// 隐藏「网络日志」悬浮按钮。
    public static func hideFloatingButton() {
        NetworkLogFloatingButton.shared.hide()
    }

    /// 找到当前顶层 VC（用于兜底 present）
    static func topViewController() -> UIViewController? {
        let scene = NetworkLogFloatingButton.activeWindowScene()
        let keyWindow = scene?.windows.first(where: { $0.isKeyWindow }) ?? scene?.windows.first
        var top = keyWindow?.rootViewController
        while let presented = top?.presentedViewController {
            top = presented
        }
        return top
    }
}
