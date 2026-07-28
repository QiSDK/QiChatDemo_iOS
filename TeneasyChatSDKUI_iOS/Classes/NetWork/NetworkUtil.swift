//
//  NetUtil.swift
//  TeneasyChatSDKUI_iOS
//
//  Created by Xiao Fu on 2023/2/8.
//

import Foundation

enum NetworkUtil {
    // 获取客服的姓名和头像
    /* static func getWorker(workerId: Int32, done: @escaping ((_ success: Bool, _ data: WorkerModel?) -> Void)) {
         let task = ChatApi.queryWorker(workerId: workerId)
         print("请求路径: \(task.baseURL)\(task.path)===\(task.method)")
         print("请求header: \(String(describing: task.headers))")
         ChatProvider.request(ChatApi.queryWorker(workerId: workerId)) { result in
             switch result {
                 case .success(let response):
                     print(response)
                     let dic = try? response.mapJSON() as? [String: Any]
                     print(dic)
                     let result = BaseRequestResult<WorkerModel>.deserialize(from: dic)

                     if result?.code == 0 {
                         done(true, result?.data)
                     } else {
                         done(false, nil)
                     }
                 case .failure(let error):
                     print(error)
                     done(false, nil)
             }
         }
     } */

    /*
     {
         "chatId":"0",
       "count": 50,
       "consultId": 1
     }
     */

    // 获取聊天记录
    static func getHistory(consultId: Int32, done: @escaping ((_ success: Bool, _ data: HistoryModel?) -> Void)) {
        let task = ChatApi.queryHistory(consultId: consultId, userId: userId, chatId: chatId, count: 50)
        print("请求路径: \(task.baseURL)\(task.path)===\(task.method)")
        print("请求header: \(String(describing: task.headers))")
        ChatProvider.request(task) { result in
            switch result {
                case .success(let response):
                    print(response)
                    let result = JSONCoding.decode(BaseRequestResult<HistoryModel>.self, from: response.data)

                if result?.code == 0 {
                    done(true, result?.data)
                } else {
                    done(false, nil)
                    logError(request: "", header: String(describing: task.headers), resp: JSONCoding.encodeToString(result) ?? "解析失败", code: response.statusCode, url: "\(task.baseURL)\(task.path)")
                }
            case .failure(let error):
                print(error)
            logError(request: "", header: String(describing: task.headers), resp: String(describing: error), code: 101, url: "\(task.baseURL)\(task.path)")
                done(false, nil)
            }
        }
    }

    // 获取问题类型
    static func getEntrance(done: @escaping ((_ success: Bool, _ data: EntranceModel?) -> Void)) {
        let task = ChatApi.queryEntrance
        print("请求路径: \(task.baseURL)\(task.path)===\(task.method)")
        print("请求header: \(String(describing: task.headers))")
        ChatProvider.request(task) { result in
            switch result {
                case .success(let response):
                    print(response)
                    let result = JSONCoding.decode(BaseRequestResult<EntranceModel>.self, from: response.data)

                    if result?.code == 0 {
                        done(true, result?.data)
                    } else {
                        done(false, nil)
                        logError(request: "", header: "\(task.headers?["x-token"] ?? "")", resp: JSONCoding.encodeToString(result) ?? "解析失败", code: response.statusCode, url: "\(task.baseURL)\(task.path)")
                        print(result?.msg ?? "")
                    }
                case .failure(let error):
                    print(error)
                logError(request: "", header: "\(task.headers?["x-token"] ?? "")", resp: error.localizedDescription, code: 101, url: "\(task.baseURL)\(task.path)")
                    done(false, nil)
            }
        }
    }
    
    // 根据消息ID获取消息体
    static func queryMessage(msgIds: [String], done: @escaping ((_ success: Bool, _ data: ReplyList?) -> Void)) {
        let task = ChatApi.queryMessage(chatId: chatId, msgIds: msgIds)
        print("请求路径: \(task.baseURL)\(task.path)===\(task.method)")
        print("请求header: \(String(describing: task.headers))")
        ChatProvider.request(task) { result in
            switch result {
                case .success(let response):

                let result = JSONCoding.decode(BaseRequestResult<ReplyList>.self, from: response.data)

                if result?.code == 0 {
                    done(true, result?.data)
                } else {
                    done(false, nil)
                    logError(request: "", header: String(describing: task.headers), resp: JSONCoding.encodeToString(result) ?? "解析失败", code: response.statusCode, url: "\(task.baseURL)\(task.path)")
                }
            case .failure(let error):
                print(error)
            logError(request: "", header: String(describing: task.headers), resp: String(describing: error), code: 101, url: "\(task.baseURL)\(task.path)")
                done(false, nil)
            }
        }
    }

    static func assignWorker(consultId: Int32, done: @escaping ((_ success: Bool, _ data: AssignWorker?) -> Void)) {
        let task = ChatApi.assignWorker(consultId: consultId)
        print("请求路径: \(task.baseURL)\(task.path)===\(task.method)")
        print("请求header: \(String(describing: task.headers))")
        ChatProvider.request(task) { result in
            switch result {
                case .success(let response):
                    print(response)
                    let result = JSONCoding.decode(BaseRequestResult<AssignWorker>.self, from: response.data)
                if result?.code == 0 {
                    done(true, result?.data)
                } else {
                    done(false, nil)
                    logError(request: "", header: String(describing: task.headers), resp: JSONCoding.encodeToString(result) ?? "解析失败", code: response.statusCode, url: "\(task.baseURL)\(task.path)")
                }
            case .failure(let error):
                print(error)
            logError(request: "", header: String(describing: task.headers), resp: String(describing: error), code: 101, url: "\(task.baseURL)\(task.path)")
                done(false, nil)
            }
        }
    }

    static func getAutoReplay(consultId: Int32, wId: Int32, done: @escaping ((_ success: Bool, _ data: QuestionModel?) -> Void)) {
        // #if DEBUG
        // workerId = 3
        // #endif
        let task = ChatApi.queryAutoReplay(consultId: consultId, workerId: workerId)
        print("请求路径: \(task.baseURL)\(task.path)===\(task.method) workerId =\(workerId)")
        print("请求header: \(String(describing: task.headers))")
        ChatProvider.request(task) { result in
            switch result {
                case .success(let response):
                    print(response)
                    let result = JSONCoding.decode(BaseRequestResult<QuestionModel>.self, from: response.data)

                if result?.code == 0 {
                    done(true, result?.data)
                } else {
                    done(false, nil)
                    logError(request: "", header: String(describing: task.headers), resp: JSONCoding.encodeToString(result) ?? "解析失败", code: response.statusCode, url: "\(task.baseURL)\(task.path)")
                }
            case .failure(let error):
                print(error)
                logError(request: "", header: String(describing: task.headers), resp: error.localizedDescription, code: 101, url: "\(task.baseURL)\(task.path)")
                done(false, nil)
            }
        }
    }

    static func markRead(consultId: Int32, done: @escaping ((_ success: Bool, _ data: QuestionModel?) -> Void)) {
        let task = ChatApi.markRead(consultId: consultId)
        print("请求路径: \(task.baseURL)\(task.path)===\(task.method)")
        print("请求header: \(String(describing: task.headers))")
        ChatProvider.request(task) { result in
            switch result {
                case .success(let response):
                    print(response)
                    let result = JSONCoding.decode(BaseRequestResult<QuestionModel>.self, from: response.data)
                    if result?.code == 0 {
                        done(true, result?.data)
                    } else {
                        done(false, nil)
                    }
                case .failure(let error):
                    print(error)
                    done(false, nil)
            }
        }
    }
    
    
    static func reportError(reportRequest: ReportRequest, done: @escaping ((_ success: Bool, _ data: BaseRequestResult<EmptyResponse>?) -> Void)) {
        let task = ChatApi.reportError(reportRequest: reportRequest)
        print("请求路径: \(task.baseURL)\(task.path)===\(task.method)")
        //task.headers?.description.addingPercentEscapes(using: <#T##String.Encoding#>)
        print("请求header: \(String(describing: task.headers))")
        print("正在上报错误\(reportRequest)")
        ChatProvider.request(task) { result in
            switch result {
                case .success(let response):
                    print(response)
                    let result = JSONCoding.decode(BaseRequestResult<EmptyResponse>.self, from: response.data)

                    if result?.code == 0 {
                        done(true, result)
                    } else {
                        done(false, nil)

                    }
                case .failure(let error):
                    print(error)
                    done(false, nil)
            }
        }
    }
    
    static public func logError(request: String, header: String, resp: String, code: Int, url: String){
        
        print("记录错误日志")
        //无可用线路是大事件，需要上报
        let errorItem = ErrorItem()
        errorItem.code = code
        errorItem.url = url
        //errorItem.tenantId = merchantId
        
        // "platform": 1, // Platform_IOS: 1;Platform_ANDROID: 2;Platform_H5: 4;
        errorItem.platform = 1
        errorItem.created_at = Date().toString(format: "yyyy-MM-dd'T'HH:mm:ss.SSS+08:00")
        
        let errorPayload = ErrorPayload()
        errorPayload.request = request
        errorPayload.resp = resp
        errorPayload.header = header
        errorItem.payload = JSONCoding.encodeToString(errorPayload)
        
        //避免太多重复的日志，最新1条的日志，跟数组里面的最后一条做比较，如果不同，则添加
        if reportRequest.data.count > 0{
            if code != reportRequest.data[0].code && url != reportRequest.data[0].url{
                reportRequest.data.append(errorItem)
            }
        }else{
            reportRequest.data.append(errorItem)
            delayExecution(seconds: 10) {
                doReportError()
            }
        }
    }
    
    // MARK: - 客服满意度评价

    /// 获取评价配置
    static func getEvaluationConfig(done: @escaping ((_ success: Bool, _ data: EvaluationConfig?) -> Void)) {
        let task = ChatApi.evaluationConfig
        ChatProvider.request(task) { result in
            switch result {
            case .success(let response):
                let parsed = JSONCoding.decode(BaseRequestResult<EvaluationConfig>.self, from: response.data)
                if parsed?.code == 0 {
                    done(true, parsed?.data)
                } else {
                    done(false, nil)
                    logError(request: "", header: String(describing: task.headers), resp: JSONCoding.encodeToString(parsed) ?? "解析失败", code: response.statusCode, url: "\(task.baseURL)\(task.path)")
                }
            case .failure(let error):
                logError(request: "", header: String(describing: task.headers), resp: String(describing: error), code: 101, url: "\(task.baseURL)\(task.path)")
                done(false, nil)
            }
        }
    }

    /// 获取当前会话的评价状态: 0=未评价 1=已评价 2=已关闭 3=空会话
    static func getEvaluationStatus(consultId: Int32, done: @escaping ((_ success: Bool, _ data: EvaluationStatus?) -> Void)) {
        let task = ChatApi.evaluationStatus(consultId: consultId)
        ChatProvider.request(task) { result in
            switch result {
            case .success(let response):
                let parsed = JSONCoding.decode(BaseRequestResult<EvaluationStatus>.self, from: response.data)
                if parsed?.code == 0 {
                    done(true, parsed?.data)
                } else {
                    done(false, nil)
                }
            case .failure:
                done(false, nil)
            }
        }
    }

    /// 提交评价或主动关闭评价 (close=1 表示用户拒绝评价)
    static func addEvaluation(consultId: Int32, score: Int32, remark: String, close: Int32, done: @escaping ((_ success: Bool, _ errMsg: String?) -> Void)) {
        let task = ChatApi.evaluationAdd(consultId: consultId, score: score, remark: remark, close: close)
        ChatProvider.request(task) { result in
            switch result {
            case .success(let response):
                let parsed = JSONCoding.decode(BaseRequestResult<EmptyResponse>.self, from: response.data)
                if parsed?.code == 0 {
                    done(true, nil)
                } else {
                    done(false, parsed?.msg)
                }
            case .failure(let error):
                done(false, error.localizedDescription)
            }
        }
    }

    static func doReportError(){
        if reportRequest.data.count == 0{
            return
        }
        print("开始上报错误日志")
        if let jsonString = JSONCoding.encodeToString(reportRequest) {
            debugPrint(jsonString)
        }
       
        NetworkUtil.reportError(reportRequest: reportRequest){ success, data in
            if success{
                print("上报错误成功")
                reportRequest.data.removeAll()
            }else{
                print("上报错误\(data?.msg ?? "失败")")
            }
        }
    }
    
}
