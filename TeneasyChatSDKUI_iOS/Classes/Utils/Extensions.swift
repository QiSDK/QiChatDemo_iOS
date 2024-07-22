//
//  Extensions.swift
//  TeneasyChatSDKUI_iOS
//
//  Created by Xuefeng on 9/7/24.
//

import Foundation
import SVGKit

extension UIView {

  // OUTPUT 1
  func dropShadow(scale: Bool = true) {
    layer.masksToBounds = false
    layer.shadowColor = UIColor.black.cgColor
    layer.shadowOpacity = 0.5
    layer.shadowOffset = CGSize(width: -1, height: 1)
    layer.shadowRadius = 1

    layer.shadowPath = UIBezierPath(rect: bounds).cgPath
    layer.shouldRasterize = true
    layer.rasterizationScale = scale ? UIScreen.main.scale : 1
  }

  // OUTPUT 2
  func dropShadow(color: UIColor, opacity: Float = 0.5, offSet: CGSize, radius: CGFloat = 1, scale: Bool = true) {
    layer.masksToBounds = false
    layer.shadowColor = color.cgColor
    layer.shadowOpacity = opacity
    layer.shadowOffset = offSet
    layer.shadowRadius = radius

    layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
    layer.shouldRasterize = true
    layer.rasterizationScale = scale ? UIScreen.main.scale : 1
  }
}


extension Date {
   func getFormattedDate(format: String) -> String {
        let dateformat = DateFormatter()
        dateformat.dateFormat = format
        return dateformat.string(from: self)
    }
    
    /// 时间戳转成字符串
    func timeIntervalChangeToTimeStr(dateFormat:String?) -> String {
        let formatter = DateFormatter.init()
        if dateFormat == nil {
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        }else{
            formatter.dateFormat = dateFormat
        }
        return formatter.string(from: self)
    }

    func currentTimeMillis() -> Int64 {
        return Int64(self.timeIntervalSince1970 * 1000)
    }
    
}


extension UIImage{
    ///svg初始化
    static func svgInit(_ name:String) -> UIImage?{
        //print("svg:\(name)")
        let svg = SVGKImage.init(named: name, in: BundleUtil.getCurrentBundle())
        return svg?.uiImage
    }
    
    static func svgInit(_ name:String,size:CGSize) -> UIImage?{
        let svg = SVGKImage.init(named: name, in: BundleUtil.getCurrentBundle())
        if size != .zero{
            svg?.size = size
        }
        return svg?.uiImage
    }
    
    static func svgView(_ name:String)->SVGKLayeredImageView?{
        let svg:SVGKImage=SVGKImage(named: "lt_zuixinweizhi", in: BundleUtil.getCurrentBundle())
        let svgView = SVGKLayeredImageView(svgkImage: svg)
        return svgView
    }
}
extension String {
    func textHeight(fontSize: CGFloat, width: CGFloat) -> CGFloat {
        return self.boundingRect(with: CGSize(width: width, height: CGFloat(MAXFLOAT)), options: .usesLineFragmentOrigin, attributes: [.font: UIFont.systemFont(ofSize: fontSize)], context: nil).size.height + 5
    }
    func textWidth(fontSize: CGFloat, width: CGFloat) -> CGFloat {
        return self.boundingRect(with: CGSize(width: width, height: CGFloat(MAXFLOAT)), options: .usesLineFragmentOrigin, attributes: [.font: UIFont.systemFont(ofSize: fontSize)], context: nil).size.width
    }
    
    var urlEncoded: String? {
            let allowedCharacterSet = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "~-_."))
        return self.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet)
        }

}

extension UIButton {
    enum UIButtonKey {
        static var actionKey = "actionKey"
    }

    func addActionBlock(_ closure: @escaping (_ sender: UIButton) -> Void) {
        objc_setAssociatedObject(self, &UIButtonKey.actionKey, closure, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY)
        self.addTarget(self, action: #selector(self.actionBtn), for: .touchUpInside)
    }

    @objc func actionBtn(_ sender: UIButton) {
        let obj = objc_getAssociatedObject(self, &UIButtonKey.actionKey)
        if let action = obj as? ((_ sender: UIButton) -> Void) {
            action(self)
        }
    }
}

extension UIImageView {
    static func fromGif(frame: CGRect, resourceName: String) -> UIImageView? {
        guard let path = BundleUtil.getCurrentBundle().path(forResource: resourceName, ofType: "gif") else {
            print("Gif does not exist at that path")
            return nil
        }
        let url = URL(fileURLWithPath: path)
        guard let gifData = try? Data(contentsOf: url),
            let source =  CGImageSourceCreateWithData(gifData as CFData, nil) else { return nil }
        var images = [UIImage]()
        let imageCount = CGImageSourceGetCount(source)
        for i in 0 ..< imageCount {
            if let image = CGImageSourceCreateImageAtIndex(source, i, nil) {
                images.append(UIImage(cgImage: image))
            }
        }
        let gifImageView = UIImageView(frame: frame)
        gifImageView.animationImages = images
        return gifImageView
    }
}

