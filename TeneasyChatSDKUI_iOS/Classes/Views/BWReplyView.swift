//
//  BWFileCell.swift
//  TeneasyChatSDKUI_iOS
//
//  Created by Xiao Fu on 2025/3/5.
//

import TeneasyChatSDK_iOS

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
    
    lazy var replyLab: UILabel = {
        let lab = UILabel()
        lab.textColor = UIColor.black
        lab.font = UIFont.systemFont(ofSize: 12)
        lab.text = "回复："
        return lab
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
    
    override init(frame: CGRect) {
            super.init(frame: frame)
            setupViews()
            setupConstraints()
        }

        required init?(coder: NSCoder) {
            super.init(coder: coder)
            setupViews()
            setupConstraints()
        }
    
    func setupViews(){
        self.addSubview(self.contentBgView)
        self.contentBgView.addSubview(self.replyLab)
        self.contentBgView.addSubview(self.fileIcon)
        self.contentBgView.addSubview(self.fileNameLab)
        self.contentBgView.addSubview(self.fileSizeLab)
    }
    
    func setupConstraints(){
        self.contentBgView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.top.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalToSuperview()
        }

        self.replyLab.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(10)
            make.top.equalToSuperview().offset(10)
            make.width.equalTo(36)
            make.height.equalTo(38)
        }
        
        //self.fileIcon.snp.removeConstraints()
        self.fileIcon.snp.makeConstraints { make in
            make.left.equalTo(self.replyLab.snp.right)
            make.top.equalToSuperview().offset(10)
            make.width.equalTo(fileIconWidth)
            make.height.equalTo(fileIconWidth)
        }
        //self.fileIcon.image = UIImage(named: "pdf_default", in: BundleUtil.getCurrentBundle(), compatibleWith: nil)
        self.fileNameLab.snp.makeConstraints { make in
            make.left.equalTo(self.fileIcon.snp.right).offset(10)
            make.top.equalTo(self.fileIcon.snp.top).offset(0)
            make.right.equalToSuperview().offset(-10)
        }
        self.fileSizeLab.snp.makeConstraints { make in
            make.left.equalTo(self.fileNameLab.snp.left)
            make.top.equalTo(self.fileNameLab.snp.bottom).offset(0)
            make.right.equalToSuperview().offset(-10)
            //make.bottom.equalToSuperview().offset(-5)
        }
    }

    let fileIconWidth: CGFloat = 36
//    let cellWidth: CGFloat = 200
//    let cellHeight: CGFloat = 56

    var model: ChatModel? {
        didSet {
            let ext = (model?.replyItem?.fileName?.split(separator: ".").last ?? "").lowercased()
            self.fileSizeLab.isHidden = true
            self.fileIcon.isHidden = true
            if fileTypes.contains(ext){
                let size = Double(model?.replyItem?.size ?? 0) * 0.001
                self.fileSizeLab.text = "\(size)K"
                self.fileSizeLab.isHidden = false
            }
            
            if fileTypes.contains(ext) || imageTypes.contains(ext) || videoTypes.contains(ext){
                self.fileIcon.image = getFileThumbnail(path: ext)
                self.fileIcon.isHidden = false
                //self.replyLab.isHidden = false
                self.fileNameLab.text = model?.replyItem?.fileName
                self.fileIcon.snp.updateConstraints { make in
                    make.width.equalTo(36)
                }
                
                self.fileNameLab.snp.updateConstraints { make in
                    make.left.equalTo(self.fileIcon.snp.right).offset(10)
                }
                self.fileNameLab.lineBreakMode = .byTruncatingMiddle
                self.fileNameLab.numberOfLines = 1
            }else{
                self.fileNameLab.text = model?.replyItem?.content
                self.fileIcon.isHidden = true
                //self.replyLab.isHidden = true
                self.fileIcon.snp.updateConstraints { make in
                    make.width.equalTo(0)
                }
                self.fileNameLab.snp.updateConstraints { make in
                    //make.left.equalToSuperview().offset(10)
                    make.left.equalTo(self.fileIcon.snp.right).offset(1)
                }
                self.fileNameLab.numberOfLines = 2
                self.fileNameLab.lineBreakMode = .byWordWrapping
            }
            
            self.sizeToFit()
            self.layoutIfNeeded()
            self.setNeedsLayout()
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
 
    }
    
    
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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.contentBgView.backgroundColor = UIColor.white
        self.fileNameLab.textColor = kHexColor(0x333333)
        self.fileSizeLab.textColor = kHexColor(0x999999)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)

    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
      
        //self.fileNameLab.textColor = UIColor.green
        

    }
    
    
//    required init?(coder: NSCoder) {
//        super.init(coder: coder)
//    }
}
