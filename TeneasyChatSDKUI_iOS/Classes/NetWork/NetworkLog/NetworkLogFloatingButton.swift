//
//  NetworkLogFloatingButton.swift
//  TeneasyChatSDKUI_iOS
//
//  网络日志悬浮按钮 - 与 Android NetworkLogFloatingButton 对齐。
//  用一个「穿透窗口」在最上层显示一个可拖动按钮，点击打开 NetworkLogVC。
//  自包含，不依赖宿主的 AppWindow / TopVC 全局。
//

import UIKit

/// 穿透窗口：只有按钮区域响应触摸，其余全部透传给下层窗口
private class PassthroughWindow: UIWindow {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hit = super.hitTest(point, with: event)
        if hit == self || hit == rootViewController?.view {
            return nil
        }
        return hit
    }
}

final class NetworkLogFloatingButton {
    static let shared = NetworkLogFloatingButton()
    private init() {}

    private var floatWindow: PassthroughWindow?

    private lazy var button: UIButton = {
        let btn = UIButton(type: .custom)
        btn.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.85)
        btn.setTitle("日志", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        btn.layer.cornerRadius = 25
        btn.layer.shadowColor = UIColor.black.cgColor
        btn.layer.shadowOpacity = 0.3
        btn.layer.shadowOffset = CGSize(width: 0, height: 2)
        btn.layer.shadowRadius = 4
        btn.addTarget(self, action: #selector(openLog), for: .touchUpInside)
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        btn.addGestureRecognizer(pan)
        return btn
    }()

    /// 显示悬浮按钮（自动挂到当前前台的 window scene 上）
    func show() {
        guard floatWindow == nil else { return }
        guard let scene = Self.activeWindowScene() else { return }

        let win = PassthroughWindow(windowScene: scene)
        win.windowLevel = .statusBar + 1
        win.backgroundColor = .clear
        let rootVC = UIViewController()
        rootVC.view.backgroundColor = .clear
        rootVC.view.isUserInteractionEnabled = false
        win.rootViewController = rootVC
        win.isHidden = false
        floatWindow = win

        let size: CGFloat = 50
        button.frame = CGRect(x: win.bounds.width - size - 16,
                              y: win.bounds.height * 0.65,
                              width: size, height: size)
        win.addSubview(button)
    }

    /// 隐藏悬浮按钮
    func hide() {
        button.removeFromSuperview()
        floatWindow?.isHidden = true
        floatWindow = nil
    }

    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        guard let superview = gesture.view?.superview, let view = gesture.view else { return }
        let translation = gesture.translation(in: superview)
        view.center = CGPoint(x: view.center.x + translation.x,
                              y: view.center.y + translation.y)
        gesture.setTranslation(.zero, in: superview)

        if gesture.state == .ended {
            snapToEdge(in: superview)
        }
    }

    private func snapToEdge(in superview: UIView) {
        let margin: CGFloat = 16
        let targetX = button.center.x < superview.bounds.midX
            ? margin + button.bounds.width / 2
            : superview.bounds.width - margin - button.bounds.width / 2
        let minY = button.bounds.height / 2 + superview.safeAreaInsets.top + 8
        let maxY = superview.bounds.height - button.bounds.height / 2 - superview.safeAreaInsets.bottom - 8
        let clampedY = min(max(button.center.y, minY), maxY)
        UIView.animate(withDuration: 0.25, delay: 0,
                       usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5) {
            self.button.center = CGPoint(x: targetX, y: clampedY)
        }
    }

    @objc private func openLog() {
        NetworkLogPresenter.present()
    }

    /// 找到当前前台活跃的 window scene
    static func activeWindowScene() -> UIWindowScene? {
        let scenes = UIApplication.shared.connectedScenes
        if let active = scenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
            return active
        }
        return scenes.compactMap { $0 as? UIWindowScene }.first
    }
}
