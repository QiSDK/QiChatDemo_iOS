//
//  BWEntranceView.swift
//  TeneasyChatSDKUI_iOS
//
//  Created by Xiao Fu on 2024/5/8.
//

import Foundation

typealias BWEntranceViewCallback = (Int) -> ()
typealias BWEntranceViewCellClick = (Int32) -> ()

class BWEntranceView: UIView {
    var callBack: BWEntranceViewCallback?
    var cellClick: BWEntranceViewCellClick?

    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15)
        label.textColor = UIColor.purple
        return label
    }()

    lazy var tableView: UITableView = {
        let view = UITableView(frame: CGRect.zero, style: UITableView.Style.plain)
        view.delegate = self
        view.dataSource = self
        view.backgroundColor = .clear
        view.tableFooterView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: kScreenWidth, height: 0.1))
        return view
    }()
    
    lazy var loading: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView()
        view.hidesWhenStopped = true
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.setupUI()
        //self.getEntrance()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupUI() {
        self.addSubview(self.loading)
        self.loading.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(30)
        }
        self.addSubview(self.titleLabel)
        self.titleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(12)
            make.top.equalToSuperview().offset(8)
        }

        self.addSubview(self.tableView)
        self.tableView.snp.makeConstraints { make in
            make.top.equalTo(self.titleLabel.snp.bottom).offset(20)
            make.bottom.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
        }


    }

    var entranceModel: EntranceModel?

    func getEntrance() {
        self.loading.startAnimating()
        //getEntrance 使用cert
        if xToken == ""{
            xToken = cert
        }
        NetworkUtil.getEntrance { success, model in
            self.loading.stopAnimating()
            if success {
                self.titleLabel.text = model?.guide ?? ""
                self.entranceModel = model
                
            } else {
                self.titleLabel.text = "没有咨询类型"
            }
            self.callBack!(self.entranceModel?.consults?.count ?? 0)
            self.tableView.reloadData()
        }
    }
}

extension BWEntranceView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.entranceModel?.consults?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = BWQuestionCell.cell(tableView: tableView)
        let list = self.entranceModel?.consults ?? []
        cell.titleLab.text = list[indexPath.row].name
        cell.dotView.isHidden = (list[indexPath.row].unread ?? 0) == 0
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        44
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let list = self.entranceModel?.consults ?? []
        let id = list[indexPath.row].consultId ?? 0
        CONSULT_ID = id
        self.cellClick!(id)
        if ((list[indexPath.row].unread ?? 0) > 0) {
            NetworkUtil.markRead(consultId: id) { success, data in
                
            }
        }
    }
}
