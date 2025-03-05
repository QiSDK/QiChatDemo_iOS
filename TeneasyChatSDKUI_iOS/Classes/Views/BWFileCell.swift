//
//  BWFileCell.swift
//  TeneasyChatSDKUI_iOS
//
//  Created by 陈亮 on 2025/3/5.
//

class BWFileCell: UITableViewCell {
    lazy var contentBgView: UIView = {
        let img = UIImageView()
        return img
    }()

    lazy var fileIcon: UIImageView = {
        let img = UIImageView()
        return img
    }()
    
    lazy var fileNameLab: UILabel = {
        let lab = UILabel()
        lab.font = UIFont.systemFont(ofSize: 13)
        lab.textColor = UIColor.black
        return lab
    }()

    lazy var fileSizeLab: UILabel = {
        let lab = UILabel()
        lab.font = UIFont.systemFont(ofSize: 13)
        lab.textColor = UIColor.gray
        return lab
    }()
    
    lazy var arrowView: UIImageView = {
        let img = UIImageView()
        return img
    }()

    lazy var timeLab: UILabel = {
        let lab = UILabel()
        lab.font = UIFont.systemFont(ofSize: 13)
        if #available(iOS 13.0, *) {
            lab.textColor = UIColor.systemGray2
        } else {
            // Fallback on earlier versions
        }
        lab.lineBreakMode = .byTruncatingTail
        return lab
    }()
    
    lazy var iconView: UIImageView = {
        let img = UIImageView()
        img.layer.cornerRadius = iconWidth * 0.5
        img.layer.masksToBounds = true
        return img
    }()

    let fileIconWidth: CGFloat = 36
    let cellWidth: CGFloat = 200
    let cellHeight: CGFloat = 56

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
        
        self.contentView.addSubview(self.contentBgView)
        self.contentView.addSubview(self.arrowView)
        self.contentView.addSubview(self.fileIcon)
        self.contentView.addSubview(self.timeLab)
        self.contentView.addSubview(self.fileNameLab)
        self.contentView.addSubview(self.fileSizeLab)
        self.contentView.addSubview(self.iconView)

        self.contentBgView.layer.cornerRadius = 5
        self.contentBgView.layer.masksToBounds = true
    }

    var model: ChatModel? {
        didSet {
            guard let msg = model?.message else {
                return
            }
            self.timeLab.text = msg.msgTime.date.toString(format: "yyyy-MM-dd HH:mm:ss")
            self.fileNameLab.text = msg.file.fileName
            let size = Double(msg.file.size) * 0.001
            self.fileSizeLab.text = "\(size)K"
            
            self.fileIcon.image = getFileThumbnail(path: msg.file.uri)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func getFileThumbnail(path: String) -> UIImage? {
        let ext = (path.split(separator: ".").last ?? "").lowercased()
        
        //"docx","doc","pdf", "xls", "xlsx", "csv"
        var thumbnail = UIImage(named: "unknown_default", in: BundleUtil.getCurrentBundle(), compatibleWith: nil)
        if (ext == "pdf"){
            thumbnail = UIImage(named: "pdf_default", in: BundleUtil.getCurrentBundle(), compatibleWith: nil)
        }else if (ext == "xls" || ext == "xlsx" || ext == "csv"){
            thumbnail = UIImage(named: "excel_default", in: BundleUtil.getCurrentBundle(), compatibleWith: nil)
        }else if (ext == "doc" || ext == "docx"){
            thumbnail = UIImage(named: "word_default", in: BundleUtil.getCurrentBundle(), compatibleWith: nil)
        }
        return thumbnail
    }
}

class BWFileLeftCell: BWFileCell {
    required init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.iconView.image = UIImage.svgInit("icon_server_def2")
        
        self.iconView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(12)
            make.top.equalToSuperview().offset(12)
            make.width.height.equalTo(iconWidth)
        }
        self.timeLab.snp.makeConstraints { make in
            make.left.equalTo(self.iconView.snp.right).offset(16)
            make.top.equalToSuperview().offset(5)
            make.right.equalToSuperview().offset(-12)
            make.height.equalTo(20)
        }
        
        self.contentBgView.snp.makeConstraints { make in
            make.left.equalTo(self.timeLab.snp.left)
            make.top.equalTo(self.timeLab.snp.bottom).offset(0)
            make.width.equalTo(cellWidth)
            make.height.equalTo(cellHeight)
            make.bottom.equalToSuperview().priority(.low)
        }
        
        arrowView.image = UIImage.svgInit("ic_left_point")
        self.arrowView.snp.makeConstraints { make in
            make.right.equalTo(self.contentBgView.snp.left).offset(1)
            make.top.equalTo(self.contentBgView).offset(4)
        }

        self.fileIcon.snp.makeConstraints { make in
            make.left.equalTo(self.timeLab.snp.left)
            //make.top.equalToSuperview().offset(8)
            make.top.equalTo(self.timeLab.snp.bottom).offset(12)
            make.width.equalTo(fileIconWidth)
            make.height.equalTo(fileIconWidth)
        }
        //self.fileIcon.image = UIImage(named: "pdf_default", in: BundleUtil.getCurrentBundle(), compatibleWith: nil)
        self.fileNameLab.snp.makeConstraints { make in
            make.left.equalTo(self.fileIcon.snp.right).offset(10)
            make.top.equalTo(self.fileIcon.snp.top)
            make.right.equalToSuperview().offset(-10)
            make.height.equalTo(20)
        }
        self.fileSizeLab.snp.makeConstraints { make in
            make.left.equalTo(self.fileNameLab.snp.left)
            make.top.equalTo(self.fileNameLab.snp.bottom).offset(0)
            make.right.equalToSuperview().offset(-10)
            make.height.equalTo(20)
        }
        
        self.contentBgView.backgroundColor = UIColor.white
        self.fileNameLab.textColor = kHexColor(0x333333)
        self.fileSizeLab.textColor = kHexColor(0x999999)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

class BWFileRightCell: BWFileCell {
    required init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.iconView.image = UIImage.svgInit("icon_server_def2")

        self.iconView.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-12)
            make.top.equalToSuperview().offset(12)
            make.width.height.equalTo(iconWidth)
        }
        self.timeLab.snp.makeConstraints { make in
            make.right.equalTo(self.iconView.snp.left).offset(-16)
            make.top.equalToSuperview().offset(5)
            make.height.equalTo(20)
        }
        self.contentBgView.snp.makeConstraints { make in
            make.top.equalTo(self.timeLab.snp.bottom)
            make.right.equalTo(self.timeLab.snp.right)
            make.width.equalTo(cellWidth)
            make.height.equalTo(cellHeight)
            make.bottom.equalToSuperview().priority(.low)
        }

        self.fileIcon.snp.makeConstraints { make in
            make.left.equalTo(self.contentBgView.snp.left).offset(10)
            make.top.equalTo(self.timeLab.snp.bottom).offset(12)
            make.width.equalTo(fileIconWidth)
            make.height.equalTo(fileIconWidth)
        }
        //self.fileIcon.image = UIImage(named: "pdf_default", in: BundleUtil.getCurrentBundle(), compatibleWith: nil)
        self.fileNameLab.snp.makeConstraints { make in
            make.left.equalTo(self.fileIcon.snp.right).offset(0)
            make.top.equalTo(self.fileIcon.snp.top)
            make.right.equalToSuperview().offset(-10)
            make.height.equalTo(20)
        }
        self.fileSizeLab.snp.makeConstraints { make in
            make.left.equalTo(self.fileNameLab.snp.left)
            make.top.equalTo(self.fileNameLab.snp.bottom).offset(0)
            make.right.equalToSuperview().offset(-10)
            make.height.equalTo(20)
        }
        
        self.contentBgView.backgroundColor = kHexColor(0x228AFE)
        self.fileNameLab.textColor = .white
        self.fileSizeLab.textColor = .white
        
        arrowView.image = UIImage.svgInit("ic_right_point")
        self.arrowView.snp.makeConstraints { make in
            make.left.equalTo(self.contentBgView.snp.right).offset(-1)
            make.top.equalTo(self.contentBgView).offset(4)
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
