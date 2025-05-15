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
   
    func uploadSuccess(paths: Urls, filePath: String, size: Int)
    
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

var uploadProgress = 0;

struct UploadUtil {
    
    var listener : UploadListener?
    var filePath: String
    var fileData: Data
    
   //上传媒体文件
    func upload() {
        uploadProgress = 1
        let ext = filePath.split(separator: ".").last?.lowercased() ?? "$"
        
        if !fileTypes.contains(ext) && !imageTypes.contains(ext) && !videoTypes.contains(ext){
            self.listener?.uploadFailed(msg: "不支持的文件格式")
            return
        }
       
       //WWProgressHUD.showLoading("正在上传...")
       print("upload imgData: \(fileData.count)")
        let api_url = getbaseApiUrl() + "/v1/assets/upload-v4"
        guard let url = URL(string: api_url) else {
            return
        }
        
        var urlRequest = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 10.0 * 1000)
        urlRequest.httpMethod = "POST"
        urlRequest.addValue("multipart/form-data", forHTTPHeaderField: "Accept")

        urlRequest.addValue(xToken, forHTTPHeaderField: "X-Token")
        let parameterDict = NSMutableDictionary()
        parameterDict.setValue(4, forKey: "type")
 
        listener?.updateProgress(progress: uploadProgress);
     
       AF.upload(multipartFormData: { multiPart in
           for (key, value) in parameterDict {
               if let temp = value as? String {
                   multiPart.append(temp.data(using: .utf8)!, withName: key as! String)
               }
               if let temp = value as? Int {
                   multiPart.append("\(temp)".data(using: .utf8)!, withName: key as! String)
               }
           }
           

           if (fileTypes.contains(ext)){
               multiPart.append(fileData, withName: "myFile", fileName:  "\(Date().milliStamp)file.\(ext)", mimeType: self.getMimeType(for: ext))
           }
           else if (videoTypes.contains(ext)) {
               multiPart.append(fileData, withName: "myFile", fileName:  "\(Date().milliStamp)file.\(ext)", mimeType: "video/mp4")
           } else {
               multiPart.append(fileData, withName: "myFile", fileName: "\(Date().milliStamp)file.png", mimeType: "image/png")
           }
       }, with: urlRequest)
        .uploadProgress(queue: .main, closure: { progress in

        })
        .response(completionHandler: { data in
            switch data.result {
            case .success:
               if let resData = data.data {
                   guard let strData = String(data: resData, encoding: String.Encoding.utf8) else {   listener?.uploadFailed(msg: "上传失败，无法转换为UTF-8字符串"); return}
                   print(strData)
                 
                    let dic = strData.convertToDictionary()

                    if data.response?.statusCode == 200{
                        let myResult = BaseRequestResult<FilePath>.deserialize(from: dic)
                        
                        if let path = myResult?.data?.filepath{
                            let urls = Urls()
                            urls.uri = path
                            listener?.uploadSuccess(paths: urls, filePath: filePath, size: fileData.count)
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
              listener?.uploadFailed(msg: "API URL is invalid")
              return
          }
          let uuid = UUID().uuidString
          var urlRequest = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 60.0 * 1000 * 10)
          urlRequest.httpMethod = "GET"
          urlRequest.addValue("text/event-stream", forHTTPHeaderField: "Accept")
          

          urlRequest.addValue(xToken, forHTTPHeaderField: "X-Token")
          urlRequest.addValue(uuid, forHTTPHeaderField: "x-trace-id")
          
          AF.streamRequest(urlRequest)
          .uploadProgress(queue: .main, closure: { progress in
              // Current upload progress of file
              print("Upload Progress: \(progress.fractionCompleted)")
          })
          .responseStream { stream in
              print(stream)
              switch stream.result {
                  
              case .success(let response):
                  var data: Data
                  do {
                      data = try response.toData()
                      if let strData = String(data: data, encoding: .utf8) {
                          print(strData)
                      }
                  } catch {
                      listener?.uploadFailed(msg: "转换数据失败");
                      return
                  }
                  //print("Raw bytes: \(data)")
                  if let strData = String(data: data, encoding: .utf8) {
  #if DEBUG
                      print(strData)
  #endif
                      if (strData.contains("无效UploadID")){
                          listener?.uploadFailed(msg: "无效UploadID");
                          return
                      }
                      let lines = strData.components(separatedBy: "\n")
                      var event: String?
                      var data: String?
                      
                      for line in lines {
                          if line.starts(with: "event:") {
                              event = String(line.dropFirst("event: ".count))
                          } else if line.starts(with: "data:") {
                              data = String(line.dropFirst("data: ".count))
                              
                              guard let dic = data?.convertToDictionary(),
                                    let myResult = UploadPercent.deserialize(from: dic) else {
                                  listener?.uploadFailed(msg: "Failed to deserialize SSE data")
                                  return
                              }
                              
                              if (myResult.percentage == 100) {
                                  if let urls = myResult.data {
                                      // 正常上传
                                     listener?.updateProgress(progress: 100);
                                     // 上传成功
                                      listener?.uploadSuccess(paths: urls,  filePath: filePath, size: fileData.count)
                                     return
                                  } else {
                                      listener?.uploadFailed(msg: "上传100%，但没返回路径");
                                  }
                              } else {
                                  // 正常上传
                                  listener?.updateProgress(progress: myResult.percentage);
                                  print("UploadUtil 上传进度：\(myResult.percentage)")
                              }
                          }
                      }
                      
                      if let event = event, let data = data {
                          print("Event: \(event), Data: \(data)")
                      }
                  } else {
                      print("视频上传失败：")
                      listener?.uploadFailed(msg: "视频上传失败！");
                  }
              case .failure(let error):
                  listener?.uploadFailed(msg: "视频上传失败！");
                  print("视频上传失败：" + error.localizedDescription)
              case .none:
                  print("none")
              }
          }
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
