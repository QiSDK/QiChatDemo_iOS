//
//  BWQuestionCell.swift
//  TeneasyChatSDKUI_iOS
//
//  Created by Xiao Fu on 2024/5/8.
//

import Foundation

class BWQuestionCell: UITableViewCell {
    
    lazy var titleLab: UILabel = {
        let lab = UILabel()
        lab.font = UIFont.systemFont(ofSize: 15)
        lab.textColor = .black
        lab.lineBreakMode = .byTruncatingTail
        return lab
    }()
    
    lazy var imgView: UIImageView = {
        let v = UIImageView()
        v.image = UIImage.svgInit("arrow-right", size: CGSize.init(width: 20, height: 20))
        return v
    }()
    
    lazy var dotView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 6
        view.backgroundColor = .red
        return view
    }()
    
    static func cell(tableView: UITableView) -> Self {
        let cellId = "\(Self.self)"
        var cell = tableView.dequeueReusableCell(withIdentifier: cellId)
        if cell == nil {
            cell = Self(style: .default, reuseIdentifier: cellId)
        }
        
        return cell as! Self
    }
    
    override required init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
                
        self.contentView.addSubview(self.titleLab)
        self.contentView.addSubview(self.imgView)
        self.contentView.addSubview(self.dotView)
        self.titleLab.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(30)
        }
        self.imgView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-12)
            make.width.height.equalTo(20)
            make.centerY.equalToSuperview()
        }
        self.dotView.snp.makeConstraints { make in
            make.left.equalTo(self.titleLab.snp.right)
            make.top.equalToSuperview().offset(7)
            make.width.height.equalTo(12)
        }
        self.dotView.isHidden = true
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
   
}
