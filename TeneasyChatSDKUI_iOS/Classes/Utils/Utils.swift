//
//  Utils.swift
//  TeneasyChatSDK_iOS_Example
//
//  Created by XiaoFu on 30/1/23.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import Foundation
import AVFoundation


struct Utiles{
//    func generateThumbnail(path: URL) -> UIImage? {
//       do {
//           let asset = AVURLAsset(url: path, options: nil)
//           let imgGenerator = AVAssetImageGenerator(asset: asset)
//           imgGenerator.appliesPreferredTrackTransform = true
//           let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(value: 0, timescale: 1), actualTime: nil)
//           let thumbnail = UIImage(cgImage: cgImage)
//           return thumbnail
//       } catch let error {
//           print("*** Error generating thumbnail: \(error.localizedDescription)")
//           return nil
//       }
//    }
    
    func generateThumbnail(path: URL, completion: @escaping (UIImage?) -> Void) {
        DispatchQueue.global(qos: .background).async {
            do {
                print("缩略图的视频地址:\(path)")
                let asset = AVURLAsset(url: path, options: nil)
                let imgGenerator = AVAssetImageGenerator(asset: asset)
                imgGenerator.appliesPreferredTrackTransform = true
                let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(value: 0, timescale: 1), actualTime: nil)
                let thumbnail = UIImage(cgImage: cgImage)
                DispatchQueue.main.async {
                    completion(thumbnail)
                }
            } catch let error {
                print("*** 获取缩略图失败: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }
    }
    
    
    func generateThumbnail(path: URL, imgView: UIImageView, completion: @escaping (UIImage?) -> Void) {
        DispatchQueue.global(qos: .background).async {
            do {
                print("缩略图的视频地址:\(path)")
                let asset = AVURLAsset(url: path, options: nil)
                let imgGenerator = AVAssetImageGenerator(asset: asset)
                imgGenerator.appliesPreferredTrackTransform = true
                let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(value: 0, timescale: 1), actualTime: nil)
                let thumbnail = UIImage(cgImage: cgImage)
              
                DispatchQueue.main.async {
                    imgView.image = thumbnail
                    //completion(thumbnail)
                }
            } catch let error {
                print("*** 获取缩略图失败: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }
    }
    
    func gitImage(resourceName: String) -> [UIImage]?{
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
            return images
    }
    
    func createThumbnailImage(image: UIImage, size: CGSize) -> UIImage? {
        // Resize the image while maintaining the aspect ratio
        let scale = max(size.width/image.size.width, size.height/image.size.height)
        let width = image.size.width * scale
        let height = image.size.height * scale
        let newSize = CGSize(width: width, height: height)
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        image.draw(in: CGRect(origin: CGPoint.zero, size: newSize))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // Compress the image
        if let jpegData = newImage?.jpegData(compressionQuality: 0.8) {
            return UIImage(data: jpegData)
        } else {
            return nil
        }
    }
    
    static func formatSize(bytes: Int32) -> String {
        // Convert bytes to KB
        let kb = Double(bytes) / 1024.0
        
        // Format the KB value to show two decimal places
        var formattedSize = String(format: "%.0fKB", kb)
        
        if kb > 1024{
            formattedSize = String(format: "%.2fM", kb / 1024.0)
        }else if kb < 1{
            formattedSize = String(format: "%.2fKB", kb)
        }
        
        return formattedSize
    }
    
    
//
//    func getWiFiAddress() -> String? {
//        var address: String?
//        var ifaddr: UnsafeMutablePointer<ifaddrs>? = nil
//
//        if getifaddrs(&ifaddr) == 0 {
//            var pointer = ifaddr
//            while pointer != nil {
//                let interface = pointer?.pointee
//                let addrFamily = interface?.ifa_addr.pointee.sa_family
//
//                if addrFamily == UInt8(AF_INET) || addrFamily == UInt8(AF_INET6) {
//                    let name = String(cString: (interface?.ifa_name)!)
//                    if name == "en0" { // "en0" is the Wi-Fi interface
//                        var addr = interface?.ifa_addr.pointee
//                        let sockAddr = UnsafeMutablePointer<sockaddr_in>(withMemoryRebound(&addr, to: sockaddr_in.self, capacity: 1))
//                        address = String(cString: inet_ntoa(sockAddr.pointee.sin_addr))
//                    }
//                }
//                pointer = pointer?.pointee.ifa_next
//            }
//            freeifaddrs(ifaddr)
//        }
//
//        return address
//    }

}
