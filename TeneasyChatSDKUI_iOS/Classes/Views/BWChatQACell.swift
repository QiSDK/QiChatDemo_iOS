//
//  BWChatQuestionCell.swift
//  TeneasyChatSDKUI_iOS
//
//  Created by Xiao Fu on 2024/5/16.
//

import Foundation
import UIKit

typealias BWChatQuestionCellHeightCallBack = (Double) -> ()
typealias BWChatQuestionCellQuestionClickCallBack = (QA) -> ()

class BWChatQACell: UITableViewCell {
    var heightBlock: BWChatQuestionCellHeightCallBack?
    var qaClickBlock: BWChatQuestionCellQuestionClickCallBack?
    var question: QuestionModel?
    lazy var questionView: BWQAView = {
        let view = BWQAView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        return view
    }()
    lazy var timeLab: UILabel = {
        let lab = UILabel()
        lab.font = UIFont.systemFont(ofSize: 13)
        lab.textColor = timeColor
        lab.lineBreakMode = .byTruncatingTail
        return lab
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
    
    var consultId: Int32? {
        didSet {
            if consultId != nil && self.question == nil {
                getAutoReplay(consultId: consultId!, workId: workerId)
            }
        }
    }
    
    func getAutoReplay(consultId: Int32, workId: Int32) {
        print(consultId)
        print("获取自动回复")
       //自动回复
        NetworkUtil.getAutoReplay(consultId: consultId, wId: workId) { success, model in
            if success {
                self.question = model
                if model?.autoReplyItem == nil{
                    self.isHidden = true
                    print("自动回复为空")
                }else{
                    if let autoReplyItem = model?.autoReplyItem {
                        self.isHidden = false
                        print("获取到自动回复：" + (autoReplyItem.name ?? ""))
                        self.questionView.setup(model: model!)
                    }
                }
            }
        }
    }
    
    var model: ChatModel? {
        didSet {
            
            guard let msg = model?.message else { return }
           
            self.timeLab.text = msg.msgTime.date.toString(format: "yyyy-MM-dd HH:mm:ss")
        }
    }
    
    override required init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        self.iconView.image = UIImage.svgInit("icon_server_def2")
        self.contentView.addSubview(self.iconView)
        self.iconView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(12)
            make.top.equalToSuperview().offset(12)
            make.width.height.equalTo(iconWidth)
        }
        self.contentView.addSubview(self.timeLab)
        self.timeLab.snp.makeConstraints { make in
            make.left.equalTo(self.iconView.snp.right).offset(16)
            make.top.equalToSuperview().offset(5)
            make.height.equalTo(0)
            make.right.equalToSuperview().offset(-12)
        }
        contentView.addSubview(questionView)
        
        questionView.snp.makeConstraints { make in
            make.left.equalTo(timeLab.snp.left)
            make.width.equalToSuperview().offset(-50-iconWidth-16)
            //make.width.equalTo(168)
            make.height.equalTo(50)
            //make.bottom.equalToSuperview()
            make.top.equalTo(timeLab.snp.bottom).offset(5)
        }
        
        questionView.heightCallback = { [weak self] (height: Double) in
            self?.questionView.snp.updateConstraints { make in
                make.height.equalTo(height)
            }
            self?.timeLab.snp.updateConstraints { make in
                make.height.equalTo(20)
            }
            self?.heightBlock!(height)
        }
        questionView.qaCellClick = { [weak self] (model: QA) in
            self?.qaClickBlock!(model)
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
