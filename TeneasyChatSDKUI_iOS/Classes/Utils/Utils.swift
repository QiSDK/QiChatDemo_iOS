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
                let asset = AVURLAsset(url: path, options: nil)
                let imgGenerator = AVAssetImageGenerator(asset: asset)
                imgGenerator.appliesPreferredTrackTransform = true
                let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(value: 0, timescale: 1), actualTime: nil)
                let thumbnail = UIImage(cgImage: cgImage)
                DispatchQueue.main.async {
                    completion(thumbnail)
                }
            } catch let error {
                print("*** Error generating thumbnail: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }
    }
}
