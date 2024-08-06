//
//  BWKeFuChatEmojiView.swift
//  ProgramIOS
//
//  Created by XiaoFu on 2022/02/17.
//  表情视图

import UIKit

protocol BWKeFuChatEmojiViewDelegate: AnyObject {
    func emojiView(emojiView: BWKeFuChatEmojiView, collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath, model: BEmotion)
    func emojiView(emojiView: BWKeFuChatEmojiView, didSelectDelete btn: WButton)
}

class BWKeFuChatEmojiView: UIView {
    
    public weak var delegate: BWKeFuChatEmojiViewDelegate?
    
    lazy var emojiArr = BEmotionHelper.getNewEmoji();
    
    var deleteBtn:WButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = chatBackColor
        
        //Bar 视图
        let toolView = UIView()
        if #available(iOS 13.0, *) {
            toolView.backgroundColor = UIColor.tertiarySystemBackground
        } else {
            // Fallback on earlier versions
        }
        addSubview(toolView)
        
        //表情按钮
        let emoImageView = UIButton(type: .custom)
        emoImageView.isUserInteractionEnabled = false
        var image = UIImage.svgInit("h5_biaoqing")
        if #available(iOS 13.0, *) {
            image = UIImage.svgInit("h5_biaoqing")?.withTintColor(UIColor.systemGray)
        }
        emoImageView.setImage(image, for: .normal)
        emoImageView.backgroundColor = .white
        emoImageView.layer.cornerRadius = 5
        emoImageView.contentMode = .scaleAspectFit
        emoImageView.layer.masksToBounds = true
        toolView.addSubview(emoImageView)
        
        //删除按钮
        deleteBtn = WButton()
        var image1 = UIImage.svgInit("h5_qingchu")
        if #available(iOS 13.0, *) {
            image1 = UIImage.svgInit("h5_biaoqing")?.withTintColor(UIColor.systemGray)
        }
        var image2 = UIImage.svgInit("h5_biaoqing")
        if #available(iOS 13.0, *) {
            image2 = UIImage.svgInit("h5_biaoqing")?.withTintColor(UIColor.systemGray)
        }
        deleteBtn.setImage(image1, for: .normal)
        deleteBtn.setImage(image2, for: .disabled)
        deleteBtn.isEnabled = false
        toolView.addSubview(deleteBtn)
        deleteBtn.addTarget(self, action: #selector(deleteBtnAction(sender:)), for: UIControl.Event.touchUpInside)
        
        toolView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(50)
        }
        emoImageView.snp.makeConstraints { make in
            make.left.equalTo((8))
            make.top.equalTo(4)
            make.width.height.equalTo(39)
        }
        deleteBtn.snp.makeConstraints { make in
            make.top.equalTo(6)
            make.width.equalTo(50)
            make.height.equalTo(38)
            make.right.equalTo((-8))
        }
        
        //表情视图
        let margin = (15)
        let itemWH = (Int(kScreenWidth) - (2 * 10) - (8 * margin)) / 9
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: itemWH, height: itemWH)
        layout.minimumLineSpacing = CGFloat(margin)
        layout.minimumInteritemSpacing = CGFloat(margin)
        let clcView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        clcView.dataSource = self
        clcView.delegate = self
        clcView.backgroundColor = .clear
        clcView.showsVerticalScrollIndicator = false
        clcView.contentInset = UIEdgeInsets(top: 44, left: 0, bottom: 0, right: 0)
        addSubview(clcView)
        let allEmotionLabel = UILabel.init(frame: CGRect.zero)
        allEmotionLabel.textAlignment = .left
        allEmotionLabel.text = "所有表情"
        clcView.addSubview(allEmotionLabel)
        allEmotionLabel.snp.makeConstraints { make in
            make.left.equalTo(0)
            make.top.equalTo(-32)
            make.height.equalTo(20)
        }
        
        clcView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset((10))
            make.right.equalToSuperview().offset(-10)
            make.top.equalTo(toolView.snp.bottom         )
            make.bottom.equalToSuperview()
        }
    }
}

extension BWKeFuChatEmojiView: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return emojiArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let model = emojiArr[indexPath.row]
        let cell = BWKeFuChatEmojiCell.cell(collectionView: collectionView, indexPath: indexPath, model: model)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let model = emojiArr[indexPath.row]
        delegate?.emojiView(emojiView: self, collectionView: collectionView, didSelectItemAt: indexPath, model: model)
        setDeleteButtonState(enable: true)
    }
}

extension BWKeFuChatEmojiView {
    @objc private func deleteBtnAction(sender: WButton) {
        delegate?.emojiView(emojiView: self, didSelectDelete: sender)
        
    }
    
    public func setDeleteButtonState(enable:Bool) {
        deleteBtn.isEnabled = enable
    }
}

