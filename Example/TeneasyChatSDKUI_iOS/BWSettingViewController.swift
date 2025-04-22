//
//  BWSettingViewController.swift
//  Alamofire
//
//  Created by Xiao Fu on 2024/5/17.
//
//  设置页面控制器 - 用于配置聊天SDK的各项参数
import SnapKit
import UIKit
import TeneasyChatSDKUI_iOS

/// 页面关闭回调函数类型定义
typealias DissmissedCallback = () -> ()

/// 设置页面控制器 - 用于配置聊天SDK的各项参数
class BWSettingViewController: UIViewController {
    // MARK: - UI 组件

    /// 服务器线路地址输入框
    private let linesTextField = UITextView()
    /// 认证证书输入框
    private let certTextField = UITextView()
    /// 商户ID输入框
    private let merchantIdTextField = UITextView()
    /// 用户ID输入框
    private let userIdTextField = UITextView()
    /// 用户名输入框
    private let userNameTextField = UITextView()
    /// 图片基础URL输入框
    private let imgBaseUrlTextField = UITextView()
    /// 最大会话时长(分钟)输入框
    private let maxSessionMinsTextField = UITextView()
    /// 用户等级输入框
    private let userLevelTextField = UITextView()

    /// 确定按钮
    private let submitButton = UIButton(type: .system)

    // MARK: - 属性

    /// 页面关闭回调
    var callBack: DissmissedCallback?


    // MARK: - 生命周期方法

    /// 视图加载完成
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()

        // 添加点击手势，用于关闭键盘
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        // 如果不希望点击手势干扰其他交互，可以取消下面的注释
        // tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    /// 视图即将消失
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // 执行回调函数，通知父视图控制器刷新配置
        if callBack != nil {
            callBack!()
        }
    }

    // MARK: - 事件处理

    /// 关闭键盘
    @objc func dismissKeyboard() {
        // 使视图（或其中的文本输入框）放弃第一响应者状态，从而关闭键盘
        view.endEditing(true)
    }

    // MARK: - UI 设置

    /// 设置用户界面
    private func setupUI() {
        // 设置背景颜色
        if #available(iOS 13.0, *) {
            view.backgroundColor = UIColor.secondarySystemBackground
        } else {
            view.backgroundColor = UIColor.lightGray.withAlphaComponent(0.1)
        }

        // 定义标签名称和对应的文本输入框
        let labels = ["线路地址(lines)", "认证证书(cert)", "商户ID(merchantId)", "用户ID(userId)",
                     "用户名(userName)", "图片基础URL(imageBaseUrl)", "最大会话时长(maxSessionMins)", "用户等级(userLevel)"]
        let textFields = [linesTextField, certTextField, merchantIdTextField, userIdTextField,
                         userNameTextField, imgBaseUrlTextField, maxSessionMinsTextField, userLevelTextField]

        var previousView: UIView?

        // 创建标签和文本输入框
        for (index, labelName) in labels.enumerated() {
            // 创建标签
            let label = UILabel()
            label.text = labelName
            label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
            view.addSubview(label)

            // 配置文本输入框
            let textField = textFields[index]
            textField.font = UIFont.systemFont(ofSize: 14)
            view.addSubview(textField)

            // 设置标签约束
            label.snp.makeConstraints { make in
                if let previousView = previousView {
                    make.top.equalTo(previousView.snp.bottom).offset(10)
                } else {
                    make.top.equalToSuperview().offset(50) // 增加顶部间距，避免状态栏遮挡
                }
                make.left.equalToSuperview().offset(20)
                make.right.equalToSuperview().offset(-20)
            }

            // 设置文本输入框样式和约束
            textField.layer.borderWidth = 2.0
            textField.layer.borderColor = UIColor.purple.cgColor
            textField.layer.cornerRadius = 5.0
            textField.clipsToBounds = true

            textField.snp.makeConstraints { make in
                make.top.equalTo(label.snp.bottom).offset(5)
                make.left.equalTo(label)
                make.right.equalTo(label)
                make.height.equalTo(35)
            }

            previousView = textField
        }

        // 设置确定按钮
        submitButton.setTitle("确定", for: .normal)
        submitButton.backgroundColor = UIColor.systemBlue
        submitButton.setTitleColor(UIColor.white, for: .normal)
        submitButton.layer.cornerRadius = 8.0
        submitButton.addTarget(self, action: #selector(submitButtonTapped), for: .touchUpInside)
        view.addSubview(submitButton)

        // 设置确定按钮约束
        submitButton.snp.makeConstraints { make in
            make.top.equalTo(userLevelTextField.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.width.equalTo(100)
            make.height.equalTo(40)
        }

        // 加载用户默认设置
        loadUserDefaults()
    }

    /// 从UserDefaults加载用户设置
    private func loadUserDefaults() {
        // 从UserDefaults获取保存的设置值
        let a_lines = UserDefaults.standard.string(forKey: PARAM_LINES) ?? ""
        let a_cert = UserDefaults.standard.string(forKey: PARAM_CERT) ?? ""
        let a_merchantId = UserDefaults.standard.integer(forKey: PARAM_MERCHANT_ID)
        let a_userId = UserDefaults.standard.integer(forKey: PARAM_USER_ID)
        let a_imgUrl = UserDefaults.standard.string(forKey: PARAM_ImageBaseURL) ?? ""
        let a_userName = UserDefaults.standard.string(forKey: PARAM_USERNAME) ?? ""
        let a_maxSessionMins = UserDefaults.standard.integer(forKey: PARAM_MAXSESSIONMINS)
        let a_userLevel = UserDefaults.standard.integer(forKey: PARAM_USERLEVEL)

        // 设置文本输入框的值，如果UserDefaults中没有值，则使用默认值
        linesTextField.text = a_lines.isEmpty ? lines : a_lines
        certTextField.text = a_cert.isEmpty ? cert : a_cert
        merchantIdTextField.text = "\(a_merchantId > 0 ? a_merchantId : merchantId)"
        userIdTextField.text = "\(a_userId > 0 ? Int32(a_userId) : userId)"
        userNameTextField.text = a_userName.isEmpty ? userName : a_userName
        imgBaseUrlTextField.text = a_imgUrl.isEmpty ? baseUrlImage : a_imgUrl
        maxSessionMinsTextField.text = "\(a_maxSessionMins > 0 ? a_maxSessionMins : maxSessionMinus)"
        userLevelTextField.text = "\(a_userLevel > 0 ? a_userLevel : userLevel)"
    }

    /// 确定按钮点击事件处理
    @objc private func submitButtonTapped() {
        // 获取并清理输入值
        lines = (linesTextField.text ?? "").trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        cert = (certTextField.text ?? "").trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        merchantId = Int((merchantIdTextField.text ?? "0").trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)) ?? 0
        userId = Int32((userIdTextField.text ?? "0").trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)) ?? 0
        baseUrlImage = imgBaseUrlTextField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) ?? ""
        userName = userNameTextField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) ?? ""

        maxSessionMinus = Int((maxSessionMinsTextField.text ?? "1992883").trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)) ?? 0
        userLevel = Int((userLevelTextField.text ?? "0").trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)) ?? 0

        // 验证输入值
        if lines.isEmpty || cert.isEmpty || merchantId == 0 || userId == 0 || baseUrlImage.isEmpty {
            // 显示错误提示
            let alert = UIAlertController(title: "输入错误", message: "请确保所有必填字段都已填写", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "确定", style: .default))
            present(alert, animated: true)
            return
        }

        // 保存设置到UserDefaults
        UserDefaults.standard.set(lines, forKey: PARAM_LINES)
        UserDefaults.standard.set(cert, forKey: PARAM_CERT)
        UserDefaults.standard.set(merchantId, forKey: PARAM_MERCHANT_ID)
        UserDefaults.standard.set(userId, forKey: PARAM_USER_ID)
        UserDefaults.standard.set("", forKey: PARAM_XTOKEN) // 清除token，强制重新获取
        UserDefaults.standard.set(baseUrlImage, forKey: PARAM_ImageBaseURL)
        UserDefaults.standard.set(userName, forKey: PARAM_USERNAME)
        UserDefaults.standard.set(maxSessionMinus, forKey: PARAM_MAXSESSIONMINS)
        UserDefaults.standard.set(userLevel, forKey: PARAM_USERLEVEL)

        // 关闭设置页面
        dismiss(animated: true)
    }
}
