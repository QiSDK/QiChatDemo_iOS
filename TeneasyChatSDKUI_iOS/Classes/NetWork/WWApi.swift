import Moya
// 生成请求封装类
let ChatProvider = MoyaProvider<ChatApi>()

enum ChatApi {
    case queryHistory(consultId: Int32 = 1, userId: Int32 = 0, chatId: Int32 = 0, count: Int32 = 50)
    case queryMessage(chatId: String, msgIds: [String])
    case queryAutoReplay(consultId: Int32 = 0, workerId: Int32 = 0)
    case queryEntrance
    case assignWorker(consultId: Int32 = 0)
    case markRead(consultId: Int32 = 0)
    case reportError(reportRequest: ReportRequest)
}

/// 实现TargetType协议
extension ChatApi: TargetType {
    /// url
   public var baseURL: URL {
        return URL(string: getbaseApiUrl())!
    }
    
    /// 请求路径
    var path: String {
        switch self {
        case .queryHistory:
            return "/v1/api/message/sync"
        case .queryMessage:
            return "/v1/api/message/reply-message/sync"
        case .queryAutoReplay:
            return "/v1/api/query-auto-reply"
        case .queryEntrance:
            return "/v1/api/query-entrance"
        case .assignWorker:
            return "/v1/api/assign-worker"
        case .markRead:
            return "/v1/api/chat/mark-read"
        case .reportError:
            return "v1/api/error-report/upload"
        }

    }
    
    /// 请求方式
    var method: Moya.Method {
        return .post
    }
    
    /// 解析格式
    var sampleData: Data {
        return "{}".data(using: String.Encoding.utf8)!
    }
    
    var task: Task {
        switch self {
        /*
         {
             "chatId":"0",
           "count": 50,
           "consultId": 1
         }
         */
        case .queryHistory(let consultId, let myUserId, let chatId, let count):
            return .requestParameters(parameters: ["consultId": consultId, "userId": myUserId, "chatId": chatId, "count": count], encoding: JSONEncoding.default)
        case .queryAutoReplay(let consultId, let workerId):
            return .requestParameters(parameters: ["consultId": consultId, "workerId": workerId], encoding: JSONEncoding.default)
        case .assignWorker(let id):
            return .requestParameters(parameters: ["consultId": id], encoding: JSONEncoding.default)
        case .queryMessage(let chatId, let msgIds):
            return .requestParameters(parameters: ["chatId": chatId, "msgIds": msgIds], encoding: JSONEncoding.default)
        case .markRead(let id):
            return .requestParameters(parameters: ["consultId": id], encoding: JSONEncoding.default)
        case .reportError(let reportRequest):
            //  request.headers("x-trace-id", UUID.randomUUID().toString())
            return .requestJSONEncodable(reportRequest)
        case .queryEntrance:
            return .requestParameters(parameters: [:], encoding: JSONEncoding.default)
        default:
            return .requestPlain
        }
    }
    
    /// 公共请求头
    var headers: [String: String]? {
        //if path.contains("error-report"){
        let uuid = UUID().uuidString
        return ["X-Token": xToken, "Content-Type": "application/json", "x-trace-id": uuid]
    }
}
