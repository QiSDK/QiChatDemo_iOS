//
//  BWKeFuChatMenuCellCollectionViewCell.swift
//  ProgramIOS
//
//  Created by XiaoFu on 2021/8/20.
//

import UIKit
import SnapKit

class BWKeFuChatMenuCell: UICollectionViewCell {
    private var imgView: UIImageView!
    private var titleLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        let imgView = UIImageView()
        let bgView = UIView()
        bgView.backgroundColor = .white
        contentView.addSubview(bgView)
//        bgView.setCornerRadius(radius: 10)
        bgView.snp.makeConstraints { make in
            make.top.equalTo(15)
            make.centerX.equalToSuperview()
            make.size.equalTo(56)
        }
        imgView.contentMode = .center
        bgView.addSubview(imgView)
        imgView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        self.imgView = imgView
        
//        let titleLabel = UILabel(font: 12, color: .black, alignment: .left)
        let titleLabel = UILabel.init(frame: CGRect.zero)
        titleLabel.textAlignment = .left
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(bgView.snp.bottom).offset(6)
            make.centerX.equalToSuperview()
        }
        self.titleLabel = titleLabel
    }
    
    static func cell(collectionView:UICollectionView, indexPath:IndexPath, model:BEmotion) -> Self {
        
        let cellId = "\(self.self)"
        
        collectionView.register(self.self, forCellWithReuseIdentifier: cellId)

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as? BWKeFuChatMenuCell
        
        cell?.updateUI(collectionView: collectionView, indexPath: indexPath, model: model)
        
        return cell as! Self
    }
    
    private func updateUI(collectionView:UICollectionView, indexPath:IndexPath, model:BEmotion) {
        imgView.image = UIImage(named: model.identifier, in: BundleUtil.getCurrentBundle(), compatibleWith: nil)
        if imgView.image == nil{
//            imgView.image = UIImage.svgInit(model.identifier,size: .init(width: 24, height: 21))
        }
        titleLabel.text = model.displayName
    }
}
