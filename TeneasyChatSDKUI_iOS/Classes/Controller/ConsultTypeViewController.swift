//
//  ConsultTypeViewController.swift
//  TeneasyChatSDKUI_iOS-TeneasyChatSDKUI_iOS
//
//  Created by Xiao Fu on 2024/5/10.
//

import UIKit
import TeneasyChatSDK_iOS
import SwiftProtobuf

/// 咨询类型视图控制器 - 用于展示不同类型的客服咨询入口
open class ConsultTypeViewController: UIViewController {
    // MARK: - Properties (属性)
    /// 最大重试次数
    private let maxRetryAttempts = 3
    /// 当前重试次数
    private var retryTimes = 0
    
    // MARK: - UI Components (UI组件)
    /// 入口视图 - 展示各种咨询类型的主视图
    private lazy var entranceView: BWEntranceView = {
        let view = BWEntranceView()
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        return view
    }()
    
    /// 头部视图容器
    private lazy var headerView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = UIColor.makeBackgroundColor()
        return view
    }()
    
    /// 头部标题标签
    private lazy var headerTitle: UILabel = {
        let label = UILabel(frame: .zero)
        label.text = "客服"
        label.textColor = UIColor.makeLabelColor()
        label.textAlignment = .center
        return label
    }()
    
    /// 关闭按钮
    private lazy var headerClose: UIButton = {
        let button = UIButton(frame: .zero)
        let image = UIImage.svgInit("backicon", size: CGSize(width: 40, height: 40))
        button.setImage(makeButtonImage(image), for: .normal)
        button.addTarget(self, action: #selector(closeClick), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Lifecycle Methods (生命周期方法)
    /// 视图加载完成
    open override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureEntranceView()
        initializeToken()
        // 获取线路之后，获取咨询类型列表
                         /* 获取咨询列表有3个接口：
                         1. 普通咨询列表 + 隐藏咨询列表, 使用接口：v1/api/query-entrance-hidden
                         2. 普通咨询列表, 使用接口：v1/api/query-entrance
                         3. 获取特定咨询列表, 使用接口：v1/api/query-consult-user
                        */
        entranceView.getEntrance()
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 每次回到页面时刷新数据，确保未读数是最新的
        entranceView.getEntrance()
    }
    
    // MARK: - Private Methods (私有方法)
    /// 设置UI界面
    private func setupUI() {
        setupBackgroundColors()
        setupViewHierarchy()
        setupConstraints()
        setStatusBar(backgroundColor: UIColor.makeStatusBarColor())
    }
    
    /// 设置背景颜色
    private func setupBackgroundColors() {
        if #available(iOS 13.0, *) {
            entranceView.backgroundColor = .secondarySystemBackground
            view.backgroundColor = .secondarySystemBackground
        } else {
            entranceView.backgroundColor = .white
        }
    }
    
    /// 设置视图层级
    private func setupViewHierarchy() {
        view.addSubview(headerView)
        view.addSubview(entranceView)
        headerView.addSubview(headerTitle)
        headerView.addSubview(headerClose)
    }
    
    /// 设置约束
    private func setupConstraints() {
        headerView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.equalTo(50)
            make.top.equalToSuperview().offset(kDeviceTop)
        }
        
        headerTitle.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.centerX.equalToSuperview()
            make.width.equalTo(150)
        }
        
        headerClose.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.centerY.equalToSuperview()
        }
        
        entranceView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(headerView.snp.bottom).offset(12)
            make.bottom.equalToSuperview()
        }
    }
    
    /// 配置入口视图
    private func configureEntranceView() {
        // 处理数据回调
        entranceView.callBack = { [weak self] dataCount in
            self?.handleEntranceCallback(dataCount: dataCount)
        }
        
        // 处理单元格点击
        entranceView.cellClick = { [weak self] consultID in
            print("consultId:\(consultID)")
            self?.handleConsultSelection(consultID: consultID)
        }
    }
    
    /// 处理入口回调
    private func handleEntranceCallback(dataCount: Int) {
        guard dataCount < 1, retryTimes < maxRetryAttempts else { return }
        lineCheck()
        retryTimes += 1
    }
    
    /// 处理咨询类型选择
    private func handleConsultSelection(consultID: Int32) {
        let viewController = KeFuViewController()
        viewController.consultId = Int64(consultID)
        viewController.modalPresentationStyle = .fullScreen
        present(viewController, animated: true)
    }
    
    /// 初始化Token
    private func initializeToken() {
        xToken = UserDefaults.standard.string(forKey: PARAM_XTOKEN) ?? ""
    }
    
    /// 关闭按钮点击事件
    @objc private func closeClick() {
        dismiss(animated: true)
    }
}

// MARK: - LineDetectDelegate (线路检测代理)
extension ConsultTypeViewController: LineDetectDelegate {
    /// 检查线路
    func lineCheck() {
        let lineLB = LineDetectLib(lines, delegate: self, tenantId: merchantId)
        lineLB.getLine()
    }
    
    /// 使用检测到的线路
    public func useTheLine(line: String) {
        domain = line
        entranceView.getEntrance()
    }
    
    /// 处理线路错误
    public func lineError(error: TeneasyChatSDK_iOS.Result) {
        guard error.Code == 1008 else { return }
        view.makeToast(error.Message)
        NetworkUtil.logError(
            request: lines,
            header: "",
            resp: error.Message,
            code: error.Code,
            url: "v1/api/verify"
        )
    }
}

// MARK: - UI Helpers (UI辅助方法)
private extension ConsultTypeViewController {
    /// 设置状态栏
    func setStatusBar(backgroundColor: UIColor) {
        let statusBarFrame = makeStatusBarFrame()
        let statusBarView = UIView(frame: statusBarFrame)
        statusBarView.backgroundColor = backgroundColor
        view.addSubview(statusBarView)
    }
    
    /// 创建状态栏框架
    func makeStatusBarFrame() -> CGRect {
        if #available(iOS 13.0, *) {
            return CGRect(x: 0, y: 0, width: kScreenWidth, height: kDeviceTop)
        } else {
            return UIApplication.shared.statusBarFrame
        }
    }
    
    /// 创建按钮图片
    func makeButtonImage(_ image: UIImage?) -> UIImage? {
        if #available(iOS 13.0, *) {
            return image?.withTintColor(.systemGray)
        }
        return image
    }
}

// MARK: - UIColor Extensions (UIColor扩展)
private extension UIColor {
    /// 创建背景颜色
    static func makeBackgroundColor() -> UIColor {
        if #available(iOS 13.0, *) {
            return .tertiarySystemBackground
        }
        return .white
    }
    
    /// 创建标签颜色
    static func makeLabelColor() -> UIColor {
        if #available(iOS 13.0, *) {
            return .label
        }
        return .black
    }
    
    /// 创建状态栏颜色
    static func makeStatusBarColor() -> UIColor {
        if #available(iOS 13.0, *) {
            return .tertiarySystemBackground
        }
        return .white
    }
}
