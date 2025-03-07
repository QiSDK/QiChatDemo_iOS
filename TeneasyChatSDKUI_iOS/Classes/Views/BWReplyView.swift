//
//  BWFileCell.swift
//  TeneasyChatSDKUI_iOS
//
//  Created by Xiao Fu on 2025/3/5.
//

class BWReplyView: UIView {
    var cellTapedGesture: BWShowOriginalClickBlock?
    
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
        lab.lineBreakMode = .byTruncatingMiddle
        return lab
    }()

    lazy var fileSizeLab: UILabel = {
        let lab = UILabel()
        lab.font = UIFont.systemFont(ofSize: 13)
        lab.textColor = UIColor.gray
        return lab
    }()
    

    let fileIconWidth: CGFloat = 36
    let cellWidth: CGFloat = 200
    let cellHeight: CGFloat = 56

 
    
    @objc func openFile() {
        self.cellTapedGesture!()
    }
    

    var model: ChatModel? {
        didSet {
            guard let msg = model?.message else {
                return
            }
            
            let ext = (model?.replyItem?.fileName.split(separator: ".").last ?? "").lowercased()
            self.fileSizeLab.isHidden = true
            self.fileIcon.isHidden = true
            if fileTypes.contains(ext){
                let size = Double(msg.file.size) * 0.001
                self.fileSizeLab.text = "\(size)K"
                self.fileSizeLab.isHidden = false
            }
            
            if fileTypes.contains(ext) || imageTypes.contains(ext){
                self.fileIcon.image = getFileThumbnail(path: msg.file.uri)
                self.fileIcon.isHidden = false
                self.fileNameLab.text = model?.replyItem?.fileName
            }else{
                self.fileNameLab.text = model?.replyItem?.content
            }
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.addSubview(self.contentBgView)
        self.contentBgView.addSubview(self.fileIcon)
        self.contentBgView.addSubview(self.fileNameLab)
        self.contentBgView.addSubview(self.fileSizeLab)
    }
    
 
    
//    required init?(coder: NSCoder) {
//        super.init(coder: coder)
//    }
    
    func getFileThumbnail(path: String) -> UIImage? {
        let ext = (path.split(separator: ".").last ?? "").lowercased()
        
        //"docx","doc","pdf", "xls", "xlsx", "csv"
        var thumbnail = UIImage(named: "unknown_default", in: BundleUtil.getCurrentBundle(), compatibleWith: nil)
        if (imageTypes.contains(ext)){
            thumbnail = UIImage(named: "image_default", in: BundleUtil.getCurrentBundle(), compatibleWith: nil)
        }
        else if (videoTypes.contains(ext)){
            thumbnail = UIImage(named: "video_default", in: BundleUtil.getCurrentBundle(), compatibleWith: nil)
        }
        else if (ext == "pdf"){
            thumbnail = UIImage(named: "pdf_default", in: BundleUtil.getCurrentBundle(), compatibleWith: nil)
        }else if (ext == "xls" || ext == "xlsx" || ext == "csv"){
            thumbnail = UIImage(named: "excel_default", in: BundleUtil.getCurrentBundle(), compatibleWith: nil)
        }else if (ext == "doc" || ext == "docx"){
            thumbnail = UIImage(named: "word_default", in: BundleUtil.getCurrentBundle(), compatibleWith: nil)
        }
        return thumbnail
    }
}

class BWReplyViewLeft: BWReplyView {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.contentBgView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.top.equalToSuperview()
            make.width.equalTo(cellWidth)
            make.height.equalTo(cellHeight)
            make.bottom.equalToSuperview().priority(.low)
        }


        self.fileIcon.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.top.equalToSuperview()
            make.width.equalTo(fileIconWidth)
            make.height.equalTo(fileIconWidth)
        }
        //self.fileIcon.image = UIImage(named: "pdf_default", in: BundleUtil.getCurrentBundle(), compatibleWith: nil)
        self.fileNameLab.snp.makeConstraints { make in
            make.left.equalTo(self.fileIcon.snp.right).offset(10)
            make.top.equalTo(self.contentBgView.snp.top).offset(8)
            make.right.equalToSuperview().offset(-10)
            
            make.height.equalTo(35)
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
    
    
//    required init?(coder: NSCoder) {
//        super.init(coder: coder)
//    }
}
