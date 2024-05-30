//
//  BWKeFuChatMenuView.swift
//  ProgramIOS
//
//  Created by XiaoFu on 2021/8/19.
//  其他功能视图

import UIKit
import SnapKit

protocol BWKeFuChatMenuViewDelegate: AnyObject {
    func menuView(menuView: BWKeFuChatMenuView, collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath, model: BEmotion)
}
class BWKeFuChatMenuView: UIView {
    
    public weak var delegate: BWKeFuChatMenuViewDelegate?
    
    lazy var itemArr = BEmotionHelper.getMenuItems()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .white
        let margin = 15
        let itemW = 56
        let itemH = itemW + 25
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: itemW, height: itemH)
        layout.minimumLineSpacing = CGFloat(margin)
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .horizontal
        let clcView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        clcView.dataSource = self
        clcView.delegate = self
        clcView.backgroundColor = .red
        clcView.showsVerticalScrollIndicator = false
        clcView.contentInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        if #available(iOS 11.0, *) {
            clcView.contentInsetAdjustmentBehavior = .never
        } 
        addSubview(clcView)
        clcView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        clcView.reloadData()
    }
}

extension BWKeFuChatMenuView: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return itemArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let model = itemArr[indexPath.row]
        let cell = BWKeFuChatMenuCell.cell(collectionView: collectionView, indexPath: indexPath, model: model)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let model = itemArr[indexPath.row]
        delegate?.menuView(menuView: self, collectionView: collectionView, didSelectItemAt: indexPath, model: model)
    }
}
extension UIView {
    var width: CGFloat { bounds.width }
    var height: CGFloat { bounds.height }
}
