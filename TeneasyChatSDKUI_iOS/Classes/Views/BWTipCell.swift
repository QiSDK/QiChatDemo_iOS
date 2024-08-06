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
        lab.font = UIFont.systemFont(ofSize: 12)
        lab.textAlignment = .center
        lab.textColor = titleColour
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
          
            let time = msg.msgTime.date.toString(format: "yyyy-MM-dd HH:mm:ss")
            //titleLab.text = time + "\n" + msg.content.data + "\n"
            
            
            // Create the attributed string
                   let attributedString = NSMutableAttributedString()
                   
                   // Add time with a specific color
                   var timeAttributes: [NSAttributedString.Key: Any] = [
                       .foregroundColor: timeColor // Change this to your desired color
                   ]
            
            if #available(iOS 13.0, *) {
                timeAttributes = [
                    .foregroundColor: UIColor.systemGray2 // Change this to your desired color
                ]
            } else {
                // Fallback on earlier versions
            }
            
                   let timeAttributedString = NSAttributedString(string: time, attributes: timeAttributes)
                   attributedString.append(timeAttributedString)
                   
                   // Add a newline
                   attributedString.append(NSAttributedString(string: "\n"))
                   
                   // Add message content with a different color
                   let contentAttributes: [NSAttributedString.Key: Any] = [
                       .foregroundColor: titleColour // Change this to your desired color
                   ]
                   let contentAttributedString = NSAttributedString(string: msg.content.data + "\n", attributes: contentAttributes)
                   attributedString.append(contentAttributedString)
                   
                   // Set the attributed string to the label
                   titleLab.attributedText = attributedString
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
   
}
