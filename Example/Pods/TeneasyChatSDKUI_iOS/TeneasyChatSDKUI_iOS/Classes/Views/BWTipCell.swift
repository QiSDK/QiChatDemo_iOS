//
//  BWQuestionCell.swift
//  TeneasyChatSDKUI_iOS
//
//  Created by Xiao Fu on 2024/5/8.
//

import Foundation

class BWTipCell: UITableViewCell {
    
    lazy var titleLab: UILabel = {
        let lab = UILabel()
        lab.font = UIFont.systemFont(ofSize: 15)
        lab.textAlignment = .center
        lab.textColor = .systemBlue
        lab.numberOfLines = 3
        
        lab.lineBreakMode = .byTruncatingTail
        return lab
    }()
    
    
    static func cell(tableView: UITableView) -> Self {
        let cellId = "\(Self.self)"
        var cell = tableView.dequeueReusableCell(withIdentifier: cellId)
        if cell == nil {
            cell = Self(style: .default, reuseIdentifier: cellId)
        }
        cell?.backgroundColor = UIColor.red
        return cell as! Self
    }
    
    override required init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
                
        self.contentView.addSubview(self.titleLab)
       
        self.titleLab.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.centerX.equalToSuperview()
        }
        
    }
    
    var model: ChatModel? {
        didSet {
            
            guard let msg = model?.message else {
                return;
            }
          
            let time = WTimeConvertUtil.displayLocalTime(from: msg.msgTime.date)
            titleLab.text = time + "\n" + msg.content.data + "\n"
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
   
}
