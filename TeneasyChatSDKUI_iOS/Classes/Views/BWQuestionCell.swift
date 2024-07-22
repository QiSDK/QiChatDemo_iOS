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
        lab.font = UIFont.systemFont(ofSize: 14)
        lab.textColor = titleColour
        lab.lineBreakMode = .byTruncatingTail
        return lab
    }()
    
    lazy var imgArrowRight: UIImageView = {
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
    
    lazy var iconView: UIImageView = {
        let img = UIImageView()
        img.layer.cornerRadius = iconWidth * 0.5
        img.layer.masksToBounds = true
        return img
    }()
    
    static func cell(tableView: UITableView) -> Self {
        let cellId = "\(Self.self)"
        var cell = tableView.dequeueReusableCell(withIdentifier: cellId)
        if cell == nil {
            cell = Self(style: .default, reuseIdentifier: cellId)
        }
        
        return cell as! Self
    }
    
    func displayThumbnail(path: String) {
        let imgUrl = URL(string: "\(baseUrlImage)\(path)")
        self.iconView.kf.setImage(with: imgUrl)
    }
    
    override required init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .white
                
        self.contentView.addSubview(self.titleLab)
        //self.contentView.addSubview(self.imgArrowRight)
        self.contentView.addSubview(self.dotView)
        self.contentView.addSubview(self.iconView)
        
        self.titleLab.textColor = .black
        self.iconView.image = UIImage.svgInit("icon_server_def2")
        self.iconView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(12)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(28)
        }
        
        self.titleLab.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(self.iconView.snp.right).offset(15)
        }
//        self.imgArrowRight.snp.makeConstraints { make in
//            make.trailing.equalToSuperview().offset(-12)
//            make.width.height.equalTo(20)
//            make.centerY.equalToSuperview()
//        }
//        self.imgArrowRight.isHidden = true
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
