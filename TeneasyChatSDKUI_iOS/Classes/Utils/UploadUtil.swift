//
//  UploadUtil.swift
//  Pods
//
//  Created by Xuefeng on 2/12/24.
//

import Alamofire
import Network
import PhotosUI
import TeneasyChatSDK_iOS
import UIKit

class UploadUtil{
    
    //上传媒体文件
    func upload(imgData: Data, isVideo: Bool) {
        WWProgressHUD.showLoading("正在上传...")
        let api_url = getbaseApiUrl() + "/v1/assets/upload-v4"
        guard let url = URL(string: api_url) else {
            return
        }
        
        var urlRequest = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 10.0 * 1000)
        urlRequest.httpMethod = "POST"
        urlRequest.addValue("multipart/form-data", forHTTPHeaderField: "Accept")
        urlRequest.httpBody = imgData
        
        urlRequest.addValue(xToken, forHTTPHeaderField: "X-Token")
        
        // Set Your Parameter
        let parameterDict = NSMutableDictionary()
        parameterDict.setValue(4, forKey: "type")
        // parameterDict.setValue("phot.png", forKey: "myFile")
        
        // Now Execute
        AF.upload(multipartFormData: { multiPart in
            for (key, value) in parameterDict {
                if let temp = value as? String {
                    multiPart.append(temp.data(using: .utf8)!, withName: key as! String)
                }
                if let temp = value as? Int {
                    multiPart.append("\(temp)".data(using: .utf8)!, withName: key as! String)
                }
            }
            if (isVideo) {
                
                multiPart.append(imgData, withName: "myFile", fileName:  "\(Date().milliStamp)file.mp4", mimeType: "video/mp4")
            } else {
                multiPart.append(imgData, withName: "myFile", fileName: "\(Date().milliStamp)file.png", mimeType: "image/png")
            }
        }, with: urlRequest)
        .uploadProgress(queue: .main, closure: { progress in
            // Current upload progress of file
            print("Upload Progress: \(progress.fractionCompleted)")
        })
        .response(completionHandler: { data in
            WWProgressHUD.dismiss()
            switch data.result {
            case .success:
                if let resData = data.data {
                    let path = String(data: resData, encoding: String.Encoding.utf8)
#if DEBUG
                    print(path ?? "")
#endif
                    let myResult = try? JSONDecoder().decode(UploadResult.self, from: resData)
                    
                    if myResult == nil {
                        WWProgressHUD.showFailure("数据返回不对，解析失败！")
                        return
                    }
                    
                    if myResult?.code != 200 && myResult?.code != 202 {
                        WWProgressHUD.showFailure(myResult?.message)
                        return
                    }
                    
                    print(myResult?.data?.filepath ?? "filePath is null")
                    
                    //图片上传成功
                    if myResult?.code == 200{
                        
                    }else{
                        //开始订阅视频上传
                        self.subscribeToSSE(uploadId: myResult?.data?.filepath ?? "", isVideo: true)
                    }
                    
                    
//                    if !isVideo{
//                        self.sendImage(url: myResult?.data?.filepath ?? "")
//                    }else{
//                        self.sendVideo(url: myResult?.data?.filepath ?? "")
//                    }
                } else {
                    print("图片上传失败：")
                    WWProgressHUD.showFailure("上传失败！")
                }
            case .failure(let error):
                WWProgressHUD.showFailure("上传失败！")
                print("图片上传失败：" + error.localizedDescription)
            }
        })
    }
    
    private func subscribeToSSE(uploadId: String, isVideo: Bool){
        let api_url = getbaseApiUrl() + "/v1/assets/upload-v4/" + uploadId
        guard let url = URL(string: api_url) else {
            return
        }
        let uuid = UUID().uuidString
        var urlRequest = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 10.0 * 1000)
        urlRequest.httpMethod = "POST"
        urlRequest.addValue("text/event-stream", forHTTPHeaderField: "Accept")
        urlRequest.addValue(xToken, forHTTPHeaderField: "X-Token")
        urlRequest.addValue(uuid, forHTTPHeaderField: "x-trace-id")

        // Now Execute
        AF.upload(url, with: urlRequest)
        .uploadProgress(queue: .main, closure: { progress in
            // Current upload progress of file
            print("Upload Progress: \(progress.fractionCompleted)")
        })
        .response(completionHandler: { data in
            WWProgressHUD.dismiss()
            switch data.result {
            case .success:
                if let resData = data.data {
                    let path = String(data: resData, encoding: String.Encoding.utf8)
#if DEBUG
                    print(path ?? "")
                    
#endif
                   var dic = path?.convertToDictionary()
                    //let dic = try? data.mapJSON() as? [String: Any]
                    let myResult = BaseRequestResult<UploadPercent>.deserialize(from: dic)
                    
                    if myResult == nil {
                        WWProgressHUD.showFailure("数据返回不对，解析失败！")
                        return
                    }
    
                    
                    if myResult?.code != 200{
                        WWProgressHUD.showFailure("上传失败！\(myResult?.code ?? 0) \(myResult?.msg ?? "")")
                        return
                    }
                    
                    if (myResult?.data?.percentage == 100){
                        //上传成功
                        
                    }else{
                        //正常上传
                    }
                    
                    
//                    if !isVideo{
//                        self.sendImage(url: myResult?.data?.filepath ?? "")
//                    }else{
//                        self.sendVideo(url: myResult?.data?.filepath ?? "")
//                    }
                } else {
                    print("图片上传失败：")
                    WWProgressHUD.showFailure("上传失败！")
                }
            case .failure(let error):
                WWProgressHUD.showFailure("上传失败！")
                print("图片上传失败：" + error.localizedDescription)
            }
        })
    }
}

extension String {
    func convertToDictionary() -> [String: Any]? {
        if let data = data(using: .utf8) {
            return try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        }
        return nil
    }
}
