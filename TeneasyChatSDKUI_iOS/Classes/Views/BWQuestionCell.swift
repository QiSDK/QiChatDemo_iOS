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
        view.layer.cornerRadius = 10
        view.backgroundColor = .red
        return view
    }()
    
    lazy var unReadCountLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.backgroundColor = .clear
        label.font = UIFont.systemFont(ofSize: 10, weight: .medium)
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        return label
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
        let thumbnail = "\(baseUrlImage)\(path)"
        print(thumbnail)
        let imgUrl = URL(string: thumbnail)
        self.iconView.kf.setImage(with: imgUrl)
    }
    
    func updateUnReadCount(_ count: Int) {
        if count > 0 {
            dotView.isHidden = false
            unReadCountLabel.text = count > 99 ? "99+" : "\(count)"
            
            // 动态调整dotView的圆角
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.dotView.layer.cornerRadius = self.dotView.frame.height / 2
            }
        } else {
            dotView.isHidden = true
            unReadCountLabel.text = ""
        }
    }
    
    override required init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        if #available(iOS 13.0, *) {
            backgroundColor = UIColor.systemBackground
        } else {
            // Fallback on earlier versions
        }
                
        self.contentView.addSubview(self.titleLab)
        //self.contentView.addSubview(self.imgArrowRight)
        self.contentView.addSubview(self.dotView)
        self.contentView.addSubview(self.iconView)
        self.dotView.addSubview(self.unReadCountLabel)
        
        if #available(iOS 13.0, *) {
            self.titleLab.textColor = UIColor.label
        } else {
            // Fallback on earlier versions
        }
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
            make.left.equalTo(self.titleLab.snp.right).offset(8)
            make.top.equalToSuperview().offset(7)
            make.height.equalTo(20)
            make.width.greaterThanOrEqualTo(20)
        }
        
        self.unReadCountLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.left.greaterThanOrEqualToSuperview().offset(6)
            make.right.lessThanOrEqualToSuperview().offset(-6)
        }
        
        self.dotView.isHidden = true
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
   
}
