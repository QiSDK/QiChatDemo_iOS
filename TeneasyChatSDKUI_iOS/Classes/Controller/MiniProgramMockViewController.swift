//
//  MiniProgramMockViewController.swift
//  TeneasyChatSDKUI_iOS
//
//  内置的「小程序页面」模拟页。
//
//  当卡片带 jumpUrl（如 pages/Withdraw/Record）而宿主又没有通过 setCardJumpHandler
//  注册自己的跳转处理器时，SDK 用本页兜底，让接入方在没有真实小程序运行时的情况下
//  也能直观看到「跳转」发生。
//
//  真实接入时，宿主应注册自己的处理器，把 jumpUrl 导航到真正的小程序容器 / 原生页 /
//  WebView；本页仅用于演示。对齐 Flutter MiniProgramMockPage / Android MiniProgramMockActivity。
//

import Foundation
import UIKit

class MiniProgramMockViewController: UIViewController {

    private let jumpUrl: String
    private let jumpCategory: Int?
    private let theme: ChatTheme

    init(jumpUrl: String, jumpCategory: Int?, theme: ChatTheme = .default) {
        self.jumpUrl = jumpUrl
        self.jumpCategory = jumpCategory
        self.theme = theme
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = titleFor(jumpUrl)

        if navigationController != nil {
            navigationItem.leftBarButtonItem = UIBarButtonItem(
                barButtonSystemItem: .close, target: self, action: #selector(onClose))
        }

        let tint = theme.tintColor

        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 12
        view.addSubview(stack)
        stack.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.left.greaterThanOrEqualToSuperview().offset(24)
            make.right.lessThanOrEqualToSuperview().offset(-24)
        }

        let titleLab = UILabel()
        titleLab.text = "模拟打开小程序页面"
        titleLab.font = UIFont.boldSystemFont(ofSize: 18)
        titleLab.textColor = tint
        stack.addArrangedSubview(titleLab)

        let pathLab = UILabel()
        pathLab.text = jumpUrl
        pathLab.font = UIFont.monospacedSystemFont(ofSize: 14, weight: .regular)
        pathLab.textColor = .darkGray
        pathLab.numberOfLines = 0
        pathLab.textAlignment = .center
        stack.addArrangedSubview(pathLab)

        if let category = jumpCategory {
            let catLab = UILabel()
            catLab.text = "jumpCategory：\(category)"
            catLab.font = UIFont.systemFont(ofSize: 13)
            catLab.textColor = .gray
            stack.addArrangedSubview(catLab)
        }

        let hintLab = UILabel()
        hintLab.text = "这是 SDK 内置的占位页。真实接入时由宿主注册处理器，\n把此路径导航到真正的小程序 / 原生页 / WebView。"
        hintLab.font = UIFont.systemFont(ofSize: 12)
        hintLab.textColor = .gray
        hintLab.numberOfLines = 0
        hintLab.textAlignment = .center
        stack.addArrangedSubview(hintLab)

        let backBtn = UIButton(type: .system)
        backBtn.setTitle("返回聊天", for: .normal)
        backBtn.setTitleColor(.white, for: .normal)
        backBtn.backgroundColor = tint
        backBtn.layer.cornerRadius = 22
        backBtn.contentEdgeInsets = UIEdgeInsets(top: 12, left: 32, bottom: 12, right: 32)
        backBtn.addTarget(self, action: #selector(onClose), for: .touchUpInside)
        stack.addArrangedSubview(backBtn)
    }

    @objc private func onClose() {
        if let nav = navigationController, nav.viewControllers.first != self {
            nav.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }

    /// 从 pages/Withdraw/Record 这类路径粗略取一个可读标题（末段）。
    private func titleFor(_ url: String) -> String {
        let segs = url.split(separator: "/").filter { !$0.isEmpty }
        return segs.last.map(String.init) ?? url
    }
}
