//
//  BWEntranceView.swift
//  TeneasyChatSDKUI_iOS
//
//  Created by Xiao Fu on 2024/5/8.
//

import Foundation
import UIKit

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
    
    lazy var iconView: UIImageView = {
        let img = UIImageView()
        img.layer.cornerRadius = iconWidth * 0.5
        img.layer.masksToBounds = true
        return img
    }()

    lazy var tableView: UITableView = {
        let view = UITableView(frame: CGRect.zero, style: UITableView.Style.plain)
        view.delegate = self
        view.dataSource = self
        view.backgroundColor = .clear
        view.tableFooterView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: 221, height: 0.1))
        view.separatorStyle = .none
        return view
    }()
    
    lazy var loading: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView()
        view.hidesWhenStopped = true
        return view
    }()
    
    lazy var arrowView: UIImageView = {
        let img = UIImageView()
        return img
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
            //make.left.equalToSuperview().offset(12)
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(8)
        }
        
        titleLabel.isHidden = true
        
        self.addSubview(self.iconView)
        self.iconView.image = UIImage.init(named: "qiliaoicon_withback", in: BundleUtil.getCurrentBundle(), compatibleWith: nil)
        self.iconView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(12)
            make.top.equalToSuperview().offset(20)
            make.width.height.equalTo(iconWidth)
        }
        
        self.addSubview(self.arrowView)
        self.arrowView.image = UIImage.svgInit("ic_left_point")
        self.arrowView.snp.makeConstraints { make in
            make.left.equalTo(iconView.snp.right).offset(20)
            make.top.equalToSuperview().offset(22)
            //make.width.height.equalTo(iconWidth)
        }
        

        self.addSubview(self.tableView)
        tableView.backgroundColor = UIColor.clear
        self.tableView.snp.makeConstraints { make in
            //make.top.equalTo(self.titleLabel.snp.bottom).offset(20)
            make.top.equalToSuperview().offset(20)
            make.bottom.equalToSuperview().offset(-20)
            make.left.equalTo(arrowView.snp.right)
            make.width.equalTo(221)
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
        
        if let avatar = list[indexPath.row].Works?[0].avatar{
            cell.displayThumbnail(path: avatar)
        }
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        44
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let list = self.entranceModel?.consults ?? []
        let id = list[indexPath.row].consultId ?? 0
        self.cellClick!(id)
        if ((list[indexPath.row].unread ?? 0) > 0) {
            NetworkUtil.markRead(consultId: id) { success, data in
                
            }
        }
    }
}
