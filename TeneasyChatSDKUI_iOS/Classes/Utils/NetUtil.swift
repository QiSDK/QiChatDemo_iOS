//
//  NetUtil.swift
//  TeneasyChatSDKUI_iOS
//
//  Created by XiaoFu on 2023/2/2.
//

import Photos

typealias RequestCompletionBlock = (_ response: URLResponse?, _ responseObject: [String: Any]?, _ error: Error?) -> Void

class NetRequest: NSObject {
    // 声明单例
    static let standard = NetRequest()

    func enqueueGETRequest(urlStr: String, completionHandler: RequestCompletionBlock? = nil) {
        let destUrl = URL(string: urlStr)!
        /// 发送请求的 session 对象
        let session = URLSession.shared
        /// 请求的 request
        var request = URLRequest(url: destUrl)
        request.httpMethod = "GET"
        // 设置请求头参数
        request.setValue("application/json; charset=UTF-8", forHTTPHeaderField: "Content-Type")

        request.timeoutInterval = 60.0

        session.configuration.timeoutIntervalForRequest = 30.0

        let task: URLSessionDataTask = session.dataTask(with: request) { data, response, error in

            guard error == nil, let data: Data = data, let _: URLResponse = response else {
                print("请求出错：\(error!.localizedDescription)")
                return
            }

            let dataStr = String(data: data, encoding: String.Encoding.utf8)!
            let responseObject = self.responseObjectFromJSONString(jsonString: dataStr)
            print("POST请求 URL=\(destUrl)")
            print("GET请求结果：\(responseObject)")
        }
        // 开始请求
        task.resume()
    }

    func enqueuePOSTRequest(urlStr: String, params: [String: Any]? = nil, completionHandler: RequestCompletionBlock? = nil) {
        let destUrl = URL(string: urlStr)!
        /// post请求参数
        let paramsData = try? JSONSerialization.data(withJSONObject: params ?? Dictionary(), options: [])

        /// 发送请求的 session 对象
        let session = URLSession.shared
        /// 请求的 request
        var request = URLRequest(url: destUrl)

        request.httpMethod = "POST"
        /// post请求参数
        request.httpBody = paramsData

        // 根据API的要求，设置请求头参数
        request.addValue("application/json; charset=UTF-8", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json; charset=UTF-8", forHTTPHeaderField: "Accept")

        /// 发送 POST请求
        let task: URLSessionDataTask = session.dataTask(with: request) { data, response, error in

            guard error == nil, let data: Data = data, let _: URLResponse = response else {
                print("请求出错：\(error!.localizedDescription)")
                return
            }

            // data 转json字符串
            let dataStr = String(data: data, encoding: String.Encoding.utf8)!
            print("dataStr = \(dataStr)")

            let responseObject = self.responseObjectFromData(data: data)

            print("POST请求 URL=\(destUrl) 参数：\(params ?? Dictionary())")
            print("POST请求结果：\(responseObject)")
        }
        // 开始请求
        task.resume()
    }

    /// jsonString 转 json
    func responseObjectFromJSONString(jsonString: String) -> [String: Any] {
        let jsonData: Data = jsonString.data(using: String.Encoding.utf8)!
        let resultDic = try? JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.mutableContainers)
        if resultDic != nil {
            return resultDic as! [String: Any]
        }
        return Dictionary()
    }

    /// data 转 JSON
    func responseObjectFromData(data: Data) -> [String: Any] {
        let resultDic = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers)
        if resultDic != nil {
            return resultDic as! [String: Any]
        }
        return Dictionary()
    }
    
    func downloadVideo(from urlString: String, completion: @escaping (Result<URL, Error>) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "Invalid URL", code: -1, userInfo: nil)))
            return
        }
        
        let session = URLSession(configuration: .default)
        let task = session.downloadTask(with: url) { tempLocalUrl, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let tempLocalUrl = tempLocalUrl else {
                completion(.failure(NSError(domain: "No temporary file", code: -2, userInfo: nil)))
                return
            }

            // Get documents directory
            let fileManager = FileManager.default
            let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!

            // Set destination path
            let destinationUrl = documentsDirectory.appendingPathComponent(url.lastPathComponent)

            // Remove file if it already exists
            if fileManager.fileExists(atPath: destinationUrl.path) {
                try? fileManager.removeItem(at: destinationUrl)
            }

            do {
                // Move file to the destination
                try fileManager.moveItem(at: tempLocalUrl, to: destinationUrl)
                completion(.success(destinationUrl))
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }
    
    func downloadAndSaveVideoToPhotoLibrary(from urlString: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "Invalid URL", code: -1, userInfo: nil)))
            return
        }
        
         var fileExtension = urlString.split(separator: ".").last;
        
        let video = "mp4, avi, mkv, mov, wmv, flv, webm";
        if (fileExtension != nil && video.contains(fileExtension!)){
            fileExtension = "mp4";
        }else{
            fileExtension = "png";
        }

        let session = URLSession(configuration: .default)
        let task = session.downloadTask(with: url) { tempLocalUrl, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let tempLocalUrl = tempLocalUrl else {
                completion(.failure(NSError(domain: "No temporary file", code: -2, userInfo: nil)))
                return
            }
            self.saveVideoWithCorrectExtension(tempLocalUrl: tempLocalUrl, ext: String(fileExtension ?? "png"), completion: completion);

        }
        task.resume()
    }
    
    func saveVideoWithCorrectExtension(tempLocalUrl: URL, ext: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let correctedUrl = documentsDirectory.appendingPathComponent("test.\(ext)" ) // Correct extension

        do {
            // Remove existing file at destination if necessary
            if fileManager.fileExists(atPath: correctedUrl.path) {
                try fileManager.removeItem(at: correctedUrl)
            }
            // Copy file with correct extension
            try fileManager.copyItem(at: tempLocalUrl, to: correctedUrl)

            // Save to Photo Library
            saveToPhotoLibrary(fileUrl: correctedUrl, ext: ext, completion: completion)

        } catch {
            completion(.failure(error))
        }
    }

    func saveToPhotoLibrary(fileUrl: URL, ext: String, completion: @escaping (Result<Void, Error>) -> Void) {
        PHPhotoLibrary.requestAuthorization { status in
            guard status == .authorized else {
                completion(.failure(NSError(domain: "Photo Library Access Denied", code: -1, userInfo: nil)))
                return
            }
            
            
            if (ext == "png"){
                PHPhotoLibrary.shared().performChanges({
                    PHAssetChangeRequest.creationRequestForAssetFromImage(atFileURL: fileUrl)
                }) { success, error in
                    if success {
                        completion(.success(()))
                    } else {
                        completion(.failure(error ?? NSError(domain: "Unknown Error", code: -2, userInfo: nil)))
                    }
                }
                
            }else{
                PHPhotoLibrary.shared().performChanges({
                    PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: fileUrl)
                }) { success, error in
                    if success {
                        completion(.success(()))
                    } else {
                        completion(.failure(error ?? NSError(domain: "Unknown Error", code: -2, userInfo: nil)))
                    }
                }
                
            }
        }
    }
}
