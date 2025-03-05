//
//  UploadUtil.swift
//  Pods
//
//  Created by Xuefeng on 2/12/24.
//
import Foundation
import Alamofire
import Network
import PhotosUI
import TeneasyChatSDK_iOS
import UIKit

protocol UploadListener {
    /// Called when the upload is successful.
    /// - Parameters:
    ///   - path: The path of the uploaded file.
    ///   - isVideo: A Boolean indicating whether the uploaded file is a video.
    func uploadSuccess(paths: Urls, isVideo: Bool, filePath: String?, size: Int32)
    
    /// Called to indicate the upload progress.
    /// - Parameter progress: The progress of the upload as an integer percentage (0-100).
    func updateProgress(progress: Int)
    
    /// Called when the upload fails.
    /// - Parameter msg: A message describing the failure.
    func uploadFailed(msg: String)
}

/*
 ".jpg", ".jpeg", ".png", ".webp", ".gif", ".bmp", ".jfif", ".heic": // 图片
 ".mp4", ".avi", ".mkv", ".mov", ".wmv", ".flv", ".webm": // 视频
 ".docx", ".doc", ".pdf", ".xls", ".xlsx", ".csv": // 文件
 */

struct UploadUtil {
    
    var  listener : UploadListener?;
    
    //上传媒体文件
    func upload(imgData: Data, isVideo: Bool, filePath: String?, fileSize: Int32 = 0) {
        //WWProgressHUD.showLoading("正在上传...")
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
 
        listener?.updateProgress(progress: uploadProgress);
        
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
            
            let ext = filePath?.split(separator: ".").last?.lowercased() ?? "$"
            if (filePath != nil &&  fileTypes.contains(ext)){
                multiPart.append(imgData, withName: "myFile", fileName:  "\(Date().milliStamp)file.\(ext)", mimeType: getMimeType(for: ext))
            }
            else if (isVideo) {
                multiPart.append(imgData, withName: "myFile", fileName:  "\(Date().milliStamp)file.mp4", mimeType: "video/mp4")
            } else if (imageTypes.contains(ext)){
                multiPart.append(imgData, withName: "myFile", fileName: "\(Date().milliStamp)file.png", mimeType: "image/png")
            }
        }, with: urlRequest)
        .uploadProgress(queue: .main, closure: { progress in

        })
        .response(completionHandler: { data in
            switch data.result {
            case .success:
                if let resData = data.data {
                    guard let strData = String(data: resData, encoding: String.Encoding.utf8) else {   listener?.uploadFailed(msg: "上传失败"); return}
                    print(strData)
                 
                    let dic = strData.convertToDictionary()

                    if data.response?.statusCode == 200{
                        let myResult = BaseRequestResult<FilePath>.deserialize(from: dic)
                        
                        if let path = myResult?.data?.filepath{
                            let urls = Urls()
                            urls.uri = path
                            listener?.uploadSuccess(paths: urls, isVideo: false, filePath: filePath, size: fileSize)
                            return
                        }
          
                    }else if data.response?.statusCode == 202{
                        if uploadProgress < 70{
                            uploadProgress = 70
                        }else{
                            uploadProgress += 10
                        }
                        listener?.updateProgress(progress: uploadProgress)
                        let myResult = BaseRequestResult<String>.deserialize(from: dic)
                        if !(myResult?.data ?? "").isEmpty{
                            //开始订阅视频上传
                           self.subscribeToSSE(uploadId: myResult?.data ?? "", isVideo: true)
                            return
                        }
                    }
                    listener?.uploadFailed(msg: "上传失败\(strData)");
                } else {
                    listener?.uploadFailed(msg: "上传失败");
                }
            case .failure(let error):
                listener?.uploadFailed(msg: "上传失败");
                print("上传失败：" + error.localizedDescription)
            }
        })
    }

    private func subscribeToSSE(uploadId: String, isVideo: Bool){
        let api_url = getbaseApiUrl() + "/v1/assets/upload-v4?uploadId=" + uploadId
        print("SSE 视频 url \(api_url) ---#")
        guard let url = URL(string: api_url) else {
            return
        }
        let uuid = UUID().uuidString
        var urlRequest = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 60.0 * 1000 * 10)
        urlRequest.httpMethod = "GET"
        urlRequest.addValue("text/event-stream", forHTTPHeaderField: "Accept")
        urlRequest.addValue(xToken, forHTTPHeaderField: "X-Token")
        urlRequest.addValue(uuid, forHTTPHeaderField: "x-trace-id")

        AF.upload(url, with: urlRequest)
        .uploadProgress(queue: .main, closure: { progress in
            // Current upload progress of file
            print("Upload Progress: \(progress.fractionCompleted)")
        })
        .response(completionHandler: { data in
            print(data)
            switch data.result {
                
            case .success:
                if let resData = data.data {
                    let strData = String(data: resData, encoding: String.Encoding.utf8)
#if DEBUG
                    print(strData ?? "")
#endif
                    if (strData?.contains("无效UploadID") ?? false){
                        listener?.uploadFailed(msg: "无效UploadID");
                        return
                    }
                    let lines = (strData ?? "").split(separator: "\n")
                           var event = ""
                           var data = ""
                           
                           for line in lines {
                               if line.starts(with: "event:") {
                                   event = line.replacingOccurrences(of: "event: ", with: "")
                               } else if line.starts(with: "data:") {
                                   data = line.replacingOccurrences(of: "data: ", with: "")
                                   
                                   
                                   let dic = data.convertToDictionary()
                                    let myResult = UploadPercent.deserialize(from: dic)
                                   print("视频SSE:\(String(describing: myResult))")
                                    
                                    if myResult == nil {
                                        listener?.uploadFailed(msg: "数据返回不对，视频解析失败！");
                                        return
                                    }
                                    
                                   if (myResult?.percentage == 100){
                                       //let urls = myResult?.data
                                       if let urls = myResult?.data{
                                           //上传成功
                                           listener?.uploadSuccess(paths:urls , isVideo: true, filePath: nil, size: 0)
                                       }else{
                                           listener?.uploadFailed(msg: "上传100%，但没返回路径");
                                       }
                                    }else{
                                        //正常上传
                                        listener?.updateProgress(progress: myResult?.percentage ?? 0);
                                    }
                               }
                           }
                           
                           if !event.isEmpty || !data.isEmpty {
                               print("Event: \(event), Data: \(data)")
                           }
                    
                 
                } else {
                    print("视频上传失败：")
                    listener?.uploadFailed(msg: "视频上传失败！");
                }
            case .failure(let error):
                listener?.uploadFailed(msg: "视频上传失败！");
                print("视频上传失败：" + error.localizedDescription)
            }
        })
    }
    
    private func getMimeType(for ext: String) -> String {
        switch ext.lowercased() {
        case "pdf":
            return "application/pdf"
        case "doc", "docx":
            return "application/msword"
        case "xls", "xlsx", "csv":
            return "application/vnd.ms-excel"
        default:
            return "*/*"
        }
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
