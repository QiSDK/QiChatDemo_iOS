//
//  NetworkLogVC.swift
//  TeneasyChatSDKUI_iOS
//
//  网络日志列表页 + 详情页 - 与 Android NetworkLogActivity/DetailActivity 对齐。
//  展示 UISDK 经由 ChatProvider 发出的 HTTP 请求，点击进入详情。自包含 UIKit，无外部基类依赖。
//

import UIKit
import SnapKit

open class NetworkLogVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    private var logs: [NetworkLog] { NetworkLogBuffer.shared.logs }

    private lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.delegate = self
        tv.dataSource = self
        tv.backgroundColor = UIColor(white: 0.96, alpha: 1)
        tv.separatorStyle = .singleLine
        tv.rowHeight = UITableView.automaticDimension
        tv.estimatedRowHeight = 80
        tv.register(NetworkLogCell.self, forCellReuseIdentifier: "NetworkLogCell")
        tv.tableFooterView = UIView()
        return tv
    }()

    open override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(white: 0.96, alpha: 1)
        title = "网络日志"
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "清空", style: .plain, target: self, action: #selector(clearLogs))
        if navigationController?.viewControllers.first === self {
            navigationItem.leftBarButtonItem = UIBarButtonItem(
                barButtonSystemItem: .close, target: self, action: #selector(closeSelf))
        }

        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
        NotificationCenter.default.addObserver(
            self, selector: #selector(onLogsChanged),
            name: .teneasyNetworkLogDidChange, object: nil)
    }

    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: .teneasyNetworkLogDidChange, object: nil)
    }

    @objc private func onLogsChanged() {
        tableView.reloadData()
    }

    @objc private func clearLogs() {
        NetworkLogBuffer.shared.clear()
    }

    @objc private func closeSelf() {
        dismiss(animated: true)
    }

    // MARK: - UITableViewDataSource / Delegate

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return logs.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NetworkLogCell", for: indexPath) as! NetworkLogCell
        cell.configure(with: logs[indexPath.row])
        return cell
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let detailVC = NetworkLogDetailVC(log: logs[indexPath.row])
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

// MARK: - NetworkLogCell

private class NetworkLogCell: UITableViewCell {

    private let urlLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = UIColor(white: 0.2, alpha: 1)
        label.numberOfLines = 2
        return label
    }()

    private let statusLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 12)
        label.textAlignment = .right
        return label
    }()

    private let infoLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 11)
        label.textColor = UIColor(white: 0.6, alpha: 1)
        label.numberOfLines = 1
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        accessoryType = .disclosureIndicator

        contentView.addSubview(urlLabel)
        contentView.addSubview(statusLabel)
        contentView.addSubview(infoLabel)

        statusLabel.snp.makeConstraints { make in
            make.right.equalTo(-8)
            make.top.equalTo(12)
            make.width.equalTo(60)
        }
        urlLabel.snp.makeConstraints { make in
            make.left.equalTo(15)
            make.top.equalTo(12)
            make.right.equalTo(statusLabel.snp.left).offset(-8)
        }
        infoLabel.snp.makeConstraints { make in
            make.left.equalTo(15)
            make.top.equalTo(urlLabel.snp.bottom).offset(4)
            make.right.equalTo(-15)
            make.bottom.equalTo(-12)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with log: NetworkLog) {
        if let url = URL(string: log.url) {
            urlLabel.text = "\(log.method) \(url.path)"
        } else {
            urlLabel.text = "\(log.method) \(log.url)"
        }

        let code = log.httpStatusCode
        if code >= 200 && code < 300 {
            statusLabel.textColor = .systemGreen
        } else if code < 0 {
            statusLabel.textColor = .systemRed
        } else {
            statusLabel.textColor = .systemOrange
        }
        statusLabel.text = "\(code)"

        let df = DateFormatter()
        df.dateFormat = "HH:mm:ss"
        let timeStr = df.string(from: log.timestamp)
        let durationStr = String(format: "%.0fms", log.duration * 1000)
        infoLabel.text = "\(timeStr) | \(durationStr) | apiCode:\(log.apiCode)"
    }
}

// MARK: - NetworkLogDetailVC

private class NetworkLogDetailVC: UIViewController {

    private let log: NetworkLog

    private lazy var textView: UITextView = {
        let tv = UITextView()
        tv.isEditable = false
        tv.font = UIFont(name: "Menlo", size: 12) ?? UIFont.systemFont(ofSize: 12)
        tv.textColor = UIColor(white: 0.2, alpha: 1)
        tv.backgroundColor = UIColor(white: 0.96, alpha: 1)
        return tv
    }()

    init(log: NetworkLog) {
        self.log = log
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "日志详情"
        view.backgroundColor = UIColor(white: 0.96, alpha: 1)

        var text = ""
        text += "== 请求 ==\n"
        text += "\(log.method) \(log.url)\n\n"

        text += "-- Headers --\n"
        for (key, value) in log.requestHeaders.sorted(by: { $0.key < $1.key }) {
            text += "\(key): \(value)\n"
        }

        if let body = log.requestBodyPlain {
            text += "\n-- Request Body --\n"
            text += formatJSON(body) + "\n"
        }

        text += "\n== 响应 ==\n"
        text += "HTTP Status: \(log.httpStatusCode)\n"
        text += "API Code: \(log.apiCode)\n"
        text += "API Msg: \(log.apiMsg)\n"

        text += "耗时: \(String(format: "%.3f", log.duration))s\n"

        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        text += "时间: \(df.string(from: log.timestamp))\n"

        if let error = log.error {
            text += "\n-- Error --\n\(error)\n"
        }

        if let responseBody = log.responseBody {
            text += "\n-- Response Body --\n"
            text += formatJSON(responseBody) + "\n"
        }

        textView.text = text

        view.addSubview(textView)
        textView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func formatJSON(_ string: String) -> String {
        guard let data = string.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data),
              let prettyData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted),
              let prettyStr = String(data: prettyData, encoding: .utf8) else {
            return string
        }
        return prettyStr
    }
}
