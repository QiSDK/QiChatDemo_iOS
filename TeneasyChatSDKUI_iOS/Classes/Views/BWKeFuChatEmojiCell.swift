//
//  BWKeFuChatEmojiCellCollectionViewCell.swift
//  ProgramIOS
//
//  Created by XiaoFu on 2021/8/20.
//

import UIKit

class BWKeFuChatEmojiCell: UICollectionViewCell {
    private var imgView: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        let imgView = UIImageView()
        contentView.addSubview(imgView)
        imgView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        self.imgView = imgView
    }
    
    static func cell(collectionView:UICollectionView, indexPath:IndexPath, model:BEmotion) -> Self {
        
        let cellId = "\(self.self)"
        
        collectionView.register(self.self, forCellWithReuseIdentifier: cellId)

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as? BWKeFuChatEmojiCell
        
        cell?.updateUI(collectionView: collectionView, indexPath: indexPath, model: model)
        
        return cell as! Self
    }
    
    private func updateUI(collectionView:UICollectionView, indexPath:IndexPath, model:BEmotion) {
        imgView.image = model.image;
    }
}

