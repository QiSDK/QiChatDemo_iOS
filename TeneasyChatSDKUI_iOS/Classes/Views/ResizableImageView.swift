//
//  ResizableImageView.swift
//  TeneasyChatSDKUI_iOS
//
//  Created by Xuefeng on 28/5/24.
//

import Foundation
class ResizableImageView: UIImageView {
    override var image: UIImage? { didSet {
        guard let image = image else { return }
         // cell chuli
//        let imageAspectRatio = image.size.width / image.size.height
//        // if viewAspectRatio > imageAspectRatio {
//        // self.contentMode = .scaleAspectFill
//
//        // 图片最大高度是160，按比例算宽度
//        self.snp.updateConstraints { make in
//            make.width.equalTo(160 * imageAspectRatio)
//        }
        
    }}
}
    
