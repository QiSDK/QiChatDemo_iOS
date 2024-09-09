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
