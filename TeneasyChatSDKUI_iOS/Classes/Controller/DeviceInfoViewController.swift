//
//  DeviceInfoViewController.swift
//  TeneasyChatSDKUI_iOS
//
//  与 Flutter device_info_page 对齐的设备信息页。
//

import UIKit

open class DeviceInfoViewController: UIViewController {

    private let theme: ChatTheme
    private let backgroundGradientLayer = CAGradientLayer()
    private let cardView = UIView()
    private let stackView = UIStackView()
    private var rows: [DeviceInfoRow] = []
    private var nowRow: DeviceInfoRow?
    private var ticker: Timer?

    private let timeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return f
    }()

    public init(theme: ChatTheme = .default) {
        self.theme = theme
        super.init(nibName: nil, bundle: nil)
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open override func viewDidLoad() {
        super.viewDidLoad()
        title = "设备信息"
        view.backgroundColor = .white

        applyTheme()
        setupLayout()
        buildRows()
        startTicker()
    }

    deinit {
        ticker?.invalidate()
    }

    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        backgroundGradientLayer.frame = view.bounds
    }

    private func applyTheme() {
        backgroundGradientLayer.colors = [
            theme.gradientStartColor.cgColor,
            theme.gradientEndColor.cgColor
        ]
        backgroundGradientLayer.startPoint = theme.gradientDirection.startPoint
        backgroundGradientLayer.endPoint = theme.gradientDirection.endPoint
        view.layer.insertSublayer(backgroundGradientLayer, at: 0)

        navigationController?.navigationBar.tintColor = theme.tintColor
    }

    private func setupLayout() {
        let scroll = UIScrollView()
        scroll.alwaysBounceVertical = true
        view.addSubview(scroll)
        scroll.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }

        cardView.backgroundColor = .white
        cardView.layer.cornerRadius = 16
        cardView.layer.masksToBounds = true
        scroll.addSubview(cardView)
        cardView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.bottom.equalToSuperview().offset(-16)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.width.equalTo(scroll.snp.width).offset(-32)
        }

        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        cardView.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func buildRows() {
        let memberAccount: String = {
            if !userName.isEmpty { return userName }
            return "—"
        }()

        let info = Bundle.main.infoDictionary ?? [:]
        let appName = (info["CFBundleDisplayName"] as? String)
            ?? (info["CFBundleName"] as? String)
            ?? "—"
        let appVersion = info["CFBundleShortVersionString"] as? String ?? "—"
        let buildNumber = info["CFBundleVersion"] as? String ?? ""
        let appVersionText = buildNumber.isEmpty
            ? appVersion
            : "\(appVersion)_\(buildNumber) (V3)"
        let bundleId = Bundle.main.bundleIdentifier ?? "—"
        let osVersion = "iOS_\(UIDevice.current.systemVersion)"
        let model = DeviceInfoViewController.deviceMarketingName()

        let entries: [(String, String, Bool)] = [
            ("会员账号", memberAccount, false),
            ("手机型号", model, false),
            ("应用名称", appName, false),
            ("手机系统版本", osVersion, false),
            ("APP当前版本", appVersionText, false),
            ("当前时间", timeFormatter.string(from: Date()), false),
            ("应用包名", bundleId, false),
            ("登录IP", "—", true),
            ("当前线路", domain.isEmpty ? "—" : domain, false),
            ("线路等级", "—", false),
            ("线路扫描", "—", true)
        ]

        for (i, entry) in entries.enumerated() {
            let row = DeviceInfoRow(label: entry.0, value: entry.1, multiLine: entry.2)
            rows.append(row)
            stackView.addArrangedSubview(row)
            if entry.0 == "当前时间" {
                nowRow = row
            }
            if i != entries.count - 1 {
                stackView.addArrangedSubview(makeDivider())
            }
        }
    }

    private func makeDivider() -> UIView {
        let container = UIView()
        let line = UIView()
        line.backgroundColor = UIColor(white: 0.93, alpha: 1.0)
        container.addSubview(line)
        line.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.top.bottom.equalToSuperview()
            make.height.equalTo(0.5)
        }
        return container
    }

    private func startTicker() {
        ticker?.invalidate()
        ticker = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.nowRow?.setValue(self.timeFormatter.string(from: Date()))
        }
    }

    private static func deviceMarketingName() -> String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let mirror = Mirror(reflecting: systemInfo.machine)
        let identifier = mirror.children.reduce("") { acc, element in
            guard let value = element.value as? Int8, value != 0 else { return acc }
            return acc + String(UnicodeScalar(UInt8(value)))
        }
        return iosMarketingNames[identifier] ?? identifier
    }

    private static let iosMarketingNames: [String: String] = [
        // iPhone 12
        "iPhone13,1": "iPhone 12 mini",
        "iPhone13,2": "iPhone 12",
        "iPhone13,3": "iPhone 12 Pro",
        "iPhone13,4": "iPhone 12 Pro Max",
        // iPhone 13
        "iPhone14,4": "iPhone 13 mini",
        "iPhone14,5": "iPhone 13",
        "iPhone14,2": "iPhone 13 Pro",
        "iPhone14,3": "iPhone 13 Pro Max",
        // iPhone 14
        "iPhone14,7": "iPhone 14",
        "iPhone14,8": "iPhone 14 Plus",
        "iPhone15,2": "iPhone 14 Pro",
        "iPhone15,3": "iPhone 14 Pro Max",
        // iPhone 15
        "iPhone15,4": "iPhone 15",
        "iPhone15,5": "iPhone 15 Plus",
        "iPhone16,1": "iPhone 15 Pro",
        "iPhone16,2": "iPhone 15 Pro Max",
        // iPhone 16
        "iPhone17,3": "iPhone 16",
        "iPhone17,4": "iPhone 16 Plus",
        "iPhone17,1": "iPhone 16 Pro",
        "iPhone17,2": "iPhone 16 Pro Max",
        // Simulator
        "i386": "iOS Simulator",
        "x86_64": "iOS Simulator",
        "arm64": "iOS Simulator"
    ]
}

// MARK: - Row

private final class DeviceInfoRow: UIView {
    private let labelView = UILabel()
    private let valueView = UILabel()
    private let multiLine: Bool

    init(label: String, value: String, multiLine: Bool) {
        self.multiLine = multiLine
        super.init(frame: .zero)
        setup(label: label, value: value)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }

    func setValue(_ text: String) {
        valueView.text = text
    }

    private func setup(label: String, value: String) {
        labelView.text = label
        labelView.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        labelView.textColor = UIColor(red: 0.10, green: 0.10, blue: 0.10, alpha: 1.0)

        valueView.text = value
        valueView.font = UIFont.systemFont(ofSize: 14)
        valueView.textColor = UIColor(red: 0.60, green: 0.63, blue: 0.65, alpha: 1.0)

        addSubview(labelView)
        addSubview(valueView)

        if multiLine {
            valueView.numberOfLines = 0
            valueView.textAlignment = .left
            labelView.snp.makeConstraints { make in
                make.left.equalToSuperview().offset(16)
                make.right.equalToSuperview().offset(-16)
                make.top.equalToSuperview().offset(14)
            }
            valueView.snp.makeConstraints { make in
                make.left.equalTo(labelView)
                make.right.equalTo(labelView)
                make.top.equalTo(labelView.snp.bottom).offset(8)
                make.bottom.equalToSuperview().offset(-14)
            }
        } else {
            valueView.numberOfLines = 1
            valueView.textAlignment = .right
            valueView.lineBreakMode = .byTruncatingMiddle
            labelView.setContentHuggingPriority(.required, for: .horizontal)
            labelView.setContentCompressionResistancePriority(.required, for: .horizontal)
            labelView.snp.makeConstraints { make in
                make.left.equalToSuperview().offset(16)
                make.top.equalToSuperview().offset(14)
                make.bottom.equalToSuperview().offset(-14)
            }
            valueView.snp.makeConstraints { make in
                make.left.equalTo(labelView.snp.right).offset(16)
                make.right.equalToSuperview().offset(-16)
                make.centerY.equalTo(labelView)
            }
        }
    }
}
