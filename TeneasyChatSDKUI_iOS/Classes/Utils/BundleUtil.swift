//
//  BundleUtil.swift
//  TeneasyChatSDKUI_iOS
//
//  Created by XiaoFu on 2023/2/1.
//

import UIKit
import Foundation

class BundleUtil {
    
    /*static func getCurrentBundle() -> Bundle{
        
        let podBundle = Bundle(for: ChatViewController.self)
        
        let bundleURL = podBundle.url(forResource: "TeneasyChatSdkUI_iOS", withExtension: "bundle")
        
        if bundleURL == nil {
            if podBundle.bundlePath.contains("TeneasyChatSDKUI_iOS") {   // carthage
                return podBundle
            }
        }
        
        if bundleURL != nil {
            let bundle = Bundle(url: bundleURL!)!
            return bundle
        } else{
            return Bundle.main
        }
    }*/
    
    static func getCurrentBundle() -> Bundle{
        
        let frameworkClass: AnyClass = KeFuViewController.self
        guard let moduleName = String(reflecting: KeFuViewController.self).components(separatedBy: ".").first else {
            fatalError("Couldn't determine module name from class \(frameworkClass)")
        }

        let frameworkBundle = Bundle(for: frameworkClass)
        guard let resourceBundleURL = frameworkBundle.url(forResource: moduleName, withExtension: "bundle"),
              let resourceBundle = Bundle(url: resourceBundleURL) else {
            fatalError("\(moduleName).bundle not found in \(frameworkBundle)")
        }

        return resourceBundle
    }
    
    public static func resourceBundle(for frameworkClass: AnyClass) -> Bundle {
           guard let moduleName = String(reflecting: frameworkClass).components(separatedBy: ".").first else {
               fatalError("Couldn't determine module name from class \(frameworkClass)")
           }

           let frameworkBundle = Bundle(for: frameworkClass)

           guard let resourceBundleURL = frameworkBundle.url(forResource: moduleName, withExtension: "bundle"),
                 let resourceBundle = Bundle(url: resourceBundleURL) else {
               fatalError("\(moduleName).bundle not found in \(frameworkBundle)")
           }
        
        print(resourceBundleURL)

           return resourceBundle
       }
}
