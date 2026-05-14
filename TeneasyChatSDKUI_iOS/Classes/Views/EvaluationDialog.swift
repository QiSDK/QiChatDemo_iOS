//
//  EvaluationDialog.swift
//  TeneasyChatSDKUI_iOS
//
//  客服满意度评价弹窗
//

import UIKit
import SnapKit

enum EvaluationScene {
    case manual      // 用户主动点按钮打开
    case triggered   // 收到触发消息自动弹出
}

class EvaluationDialog: UIView {

    // MARK: - 属性

    private let scene: EvaluationScene
    private let config: EvaluationConfig
    private let consultId: Int32
    private let theme: ChatTheme

    private var selectedScore: Int = 0
    private let remarkMaxLength: Int = 200

    // MARK: - UI 组件

    private let dimmingView = UIView()
    private let container = UIView()
    private let titleLabel = UILabel()
    private let closeButton = UIButton(type: .system)
    private let starsStack = UIStackView()
    private var starButtons: [UIButton] = []
    private let remarkBackground = UIView()
    private let remarkTextView = UITextView()
    private let placeholderLabel = UILabel()
    private let counterLabel = UILabel()
    private let submitButton = UIButton(type: .system)
    private let loadingIndicator = UIActivityIndicatorView(style: .gray)

    // MARK: - 静态入口

    @discardableResult
    static func show(in window: UIWindow,
                     scene: EvaluationScene,
                     config: EvaluationConfig,
                     consultId: Int32,
                     theme: ChatTheme) -> EvaluationDialog {
        let dialog = EvaluationDialog(scene: scene, config: config, consultId: consultId, theme: theme)
        window.addSubview(dialog)
        dialog.snp.makeConstraints { $0.edges.equalToSuperview() }
        return dialog
    }

    // MARK: - 初始化

    private init(scene: EvaluationScene, config: EvaluationConfig, consultId: Int32, theme: ChatTheme) {
        self.scene = scene
        self.config = config
        self.consultId = consultId
        self.theme = theme
        super.init(frame: .zero)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }

    private func setupUI() {
        backgroundColor = .clear

        dimmingView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        addSubview(dimmingView)
        dimmingView.snp.makeConstraints { $0.edges.equalToSuperview() }

        container.backgroundColor = .white
        container.layer.cornerRadius = 12
        container.layer.masksToBounds = true
        addSubview(container)
        container.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(24)
            make.right.equalToSuperview().offset(-24)
            make.centerY.equalToSuperview().offset(-40)
        }

        titleLabel.text = "客服满意度评价"
        titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        titleLabel.textColor = UIColor(white: 0.1, alpha: 1.0)
        container.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.top.equalToSuperview().offset(20)
        }

        closeButton.setTitle("✕", for: .normal)
        closeButton.titleLabel?.font = UIFont.systemFont(ofSize: 22, weight: .regular)
        closeButton.tintColor = UIColor(white: 0.5, alpha: 1.0)
        closeButton.setTitleColor(UIColor(white: 0.5, alpha: 1.0), for: .normal)
        closeButton.addTarget(self, action: #selector(onClose), for: .touchUpInside)
        container.addSubview(closeButton)
        closeButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-12)
            make.centerY.equalTo(titleLabel)
            make.width.height.equalTo(32)
        }

        starsStack.axis = .horizontal
        starsStack.distribution = .equalSpacing
        starsStack.alignment = .center
        container.addSubview(starsStack)
        starsStack.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
            make.height.equalTo(40)
        }

        for i in 1...5 {
            let btn = UIButton(type: .system)
            btn.setTitle("★", for: .normal)
            btn.titleLabel?.font = UIFont.systemFont(ofSize: 36)
            btn.setTitleColor(UIColor(white: 0.78, alpha: 1.0), for: .normal)
            btn.tag = i
            btn.addTarget(self, action: #selector(onStarTap(_:)), for: .touchUpInside)
            starButtons.append(btn)
            starsStack.addArrangedSubview(btn)
        }

        remarkBackground.backgroundColor = UIColor(white: 0.97, alpha: 1.0)
        remarkBackground.layer.cornerRadius = 6
        remarkBackground.layer.borderWidth = 0.5
        remarkBackground.layer.borderColor = UIColor(white: 0.85, alpha: 1.0).cgColor
        container.addSubview(remarkBackground)
        remarkBackground.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.top.equalTo(starsStack.snp.bottom).offset(16)
            make.height.equalTo(108)
        }

        remarkTextView.backgroundColor = .clear
        remarkTextView.font = UIFont.systemFont(ofSize: 14)
        remarkTextView.textColor = UIColor(white: 0.1, alpha: 1.0)
        remarkTextView.delegate = self
        remarkTextView.textContainerInset = UIEdgeInsets(top: 10, left: 8, bottom: 28, right: 8)
        remarkBackground.addSubview(remarkTextView)
        remarkTextView.snp.makeConstraints { $0.edges.equalToSuperview() }

        placeholderLabel.text = "请留下宝贵意见"
        placeholderLabel.font = UIFont.systemFont(ofSize: 14)
        placeholderLabel.textColor = UIColor(white: 0.60, alpha: 1.0)
        remarkBackground.addSubview(placeholderLabel)
        placeholderLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(13)
            make.top.equalToSuperview().offset(12)
        }

        counterLabel.text = "0/\(remarkMaxLength)"
        counterLabel.font = UIFont.systemFont(ofSize: 12)
        counterLabel.textColor = UIColor(white: 0.60, alpha: 1.0)
        remarkBackground.addSubview(counterLabel)
        counterLabel.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-12)
            make.bottom.equalToSuperview().offset(-8)
        }

        submitButton.setTitle("提交", for: .normal)
        submitButton.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        submitButton.setTitleColor(.white, for: .normal)
        submitButton.layer.cornerRadius = 18
        submitButton.layer.masksToBounds = true
        submitButton.addTarget(self, action: #selector(onSubmit), for: .touchUpInside)
        container.addSubview(submitButton)
        submitButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(remarkBackground.snp.bottom).offset(16)
            make.width.equalTo(120)
            make.height.equalTo(36)
            make.bottom.equalToSuperview().offset(-20)
        }
        applySubmitEnabled(false)

        loadingIndicator.hidesWhenStopped = true
        submitButton.addSubview(loadingIndicator)
        loadingIndicator.snp.makeConstraints { $0.center.equalToSuperview() }
    }

    // MARK: - 交互

    @objc private func onStarTap(_ sender: UIButton) {
        selectedScore = sender.tag
        for (idx, btn) in starButtons.enumerated() {
            let filled = (idx < selectedScore)
            btn.setTitleColor(filled ? theme.tintColor : UIColor(white: 0.78, alpha: 1.0), for: .normal)
        }
        applySubmitEnabled(true)
    }

    @objc private func onClose() {
        if scene == .triggered {
            // 用户在自动弹出的评价框上点 X → 告知后端不再弹
            NetworkUtil.addEvaluation(consultId: consultId, score: 0, remark: "", close: 1) { _, _ in }
        }
        dismiss()
    }

    @objc private func onSubmit() {
        guard selectedScore > 0 else { return }
        let remark = remarkTextView.text ?? ""

        submitButton.isEnabled = false
        submitButton.setTitle("", for: .normal)
        loadingIndicator.startAnimating()

        NetworkUtil.addEvaluation(consultId: consultId, score: Int32(selectedScore), remark: remark, close: 0) { [weak self] success, errMsg in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.loadingIndicator.stopAnimating()
                self.submitButton.setTitle("提交", for: .normal)
                if success {
                    self.dismiss()
                    if let scoreConfig = self.config.configs.first(where: { $0.score == self.selectedScore }),
                       scoreConfig.status == 1, !scoreConfig.feedback.isEmpty {
                        WWProgressHUD.showInfoMsg(scoreConfig.feedback)
                    }
                } else {
                    self.submitButton.isEnabled = true
                    WWProgressHUD.showInfoMsg(errMsg ?? "评价提交失败")
                }
            }
        }
    }

    func dismiss() {
        removeFromSuperview()
    }

    private func applySubmitEnabled(_ enabled: Bool) {
        submitButton.isEnabled = enabled
        submitButton.backgroundColor = enabled ? theme.tintColor : UIColor(white: 0.82, alpha: 1.0)
    }
}

// MARK: - UITextViewDelegate

extension EvaluationDialog: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        if textView.text.count > remarkMaxLength {
            textView.text = String(textView.text.prefix(remarkMaxLength))
        }
        let count = textView.text.count
        counterLabel.text = "\(count)/\(remarkMaxLength)"
        placeholderLabel.isHidden = count > 0
    }
}
