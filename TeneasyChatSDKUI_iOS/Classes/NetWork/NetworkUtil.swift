//
//  NetUtil.swift
//  TeneasyChatSDKUI_iOS
//
//  Created by Xiao Fu on 2023/2/8.
//

import Foundation
import HandyJSON

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
        let task = ChatApi.queryHistory(consultId: consultId, userId: userId, chatId: 0, count: 50)
        print("请求路径: \(task.baseURL)\(task.path)===\(task.method)")
        print("请求header: \(String(describing: task.headers))")
        ChatProvider.request(task) { result in
            switch result {
                case .success(let response):
                    print(response)
                    let dic = try? response.mapJSON() as? [String: Any]
                    // print(dic)
                    let result = BaseRequestResult<HistoryModel>.deserialize(from: dic)

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

    // 获取问题类型
    static func getEntrance(done: @escaping ((_ success: Bool, _ data: EntranceModel?) -> Void)) {
        let task = ChatApi.queryEntrance
        print("请求路径: \(task.baseURL)\(task.path)===\(task.method)")
        print("请求header: \(String(describing: task.headers))")
        ChatProvider.request(task) { result in
            switch result {
                case .success(let response):
                    print(response)
                    let dic = try? response.mapJSON() as? [String: Any]
                    // print(dic)
                    let result = BaseRequestResult<EntranceModel>.deserialize(from: dic)

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

    static func assignWorker(consultId: Int32, done: @escaping ((_ success: Bool, _ data: AssignWorker?) -> Void)) {
        let task = ChatApi.assignWorker(consultId: consultId)
        print("请求路径: \(task.baseURL)\(task.path)===\(task.method)")
        print("请求header: \(String(describing: task.headers))")
        ChatProvider.request(task) { result in
            switch result {
                case .success(let response):
                    print(response)
                    let dic = try? response.mapJSON() as? [String: Any]
                    // print(dic)
                    let result = BaseRequestResult<AssignWorker>.deserialize(from: dic)
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
                    let dic = try? response.mapJSON() as? [String: Any]
//                     print("=====\(dic)")
                    let result = BaseRequestResult<QuestionModel>.deserialize(from: dic)

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

    static func markRead(consultId: Int32, done: @escaping ((_ success: Bool, _ data: QuestionModel?) -> Void)) {
        let task = ChatApi.markRead(consultId: consultId)
        print("请求路径: \(task.baseURL)\(task.path)===\(task.method)")
        print("请求header: \(String(describing: task.headers))")
        ChatProvider.request(task) { result in
            switch result {
                case .success(let response):
                    print(response)
                    let dic = try? response.mapJSON() as? [String: Any]
//                    print("=====\(dic)")
                    let result = BaseRequestResult<QuestionModel>.deserialize(from: dic)
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
}
