//
//  Constant.swift
//  Pods
//
//  Created by xiao fu on 10/2/23.
//

import Foundation
import SwiftProtobuf
import TeneasyChatSDK_iOS

public let PARAM_USER_ID = "USER_ID"
public let PARAM_CERT = "CERT"
public let PARAM_MERCHANT_ID = "MERCHANT_ID"
public let PARAM_LINES = "LINES"
public let PARAM_ImageBaseURL = "IMAGEURL"
public let PARAM_USERNAME = "userName"
public let PARAM_MAXSESSIONMINS = "MaxSessionMins"
public let PARAM_USERLEVEL = "USERLEVEL"

/// 聊天SDK实例
private(set) var lib: ChatLib = ChatLib.shared

//这几个是需要在设置里面配置
//public var lines = ""
//public var cert = ""
//public var merchantId: Int = 0
//public var userId: Int32 = 0//1125324
//public var baseUrlImage = "" //用于拼接图片地址

//新环境
//阿福-tester, [25 Jun 2025 at 4:04:46 PM]:
//public var lines = "https://csh5-3-test.qlbig05.xyz"
//public var cert = "CKoCEAUYASDzAijxtOqVnDI.xU1eyoac8wM8LLOVmH2IOP3RaT2F92FfzzfeQE5kWbnvGHf5HK7ZouJY5ITuATewkH2_H4vUiuFzaBULd2j6Dw"
//public var  merchantId: Int = 298
//public var userId: Int32 = 666665//1125324
//public var baseUrlImage = "https://images-3-test.qlbig05.xyz" //用于拼接图片地址


//这几个是需要在设置里面配置
public var lines = "https://csapi.hfxg.xyz,https://xxx.qixin14.xxx"
public var cert = "COYBEAUYASDyASiG2piD9zE.te46qua5ha2r-Caz03Vx2JXH5OLSRRV2GqdYcn9UslwibsxBSP98GhUKSGEI0Z84FRMkp16ZK8eS-y72QVE2AQ"
public var userId: Int32 = 666665//1125324
public var baseUrlImage = "https://imagesacc.hfxg.xyz" //用于拼接图片地址
public var merchantId: Int = 230

//阿福
//public var  cert = "CKoCEAUYASDzAijxtOqVnDI.xU1eyoac8wM8LLOVmH2IOP3RaT2F92FfzzfeQE5kWbnvGHf5HK7ZouJY5ITuATewkH2_H4vUiuFzaBULd2j6Dw"
//public var cert = "COEBEAUYASDjASiewpj-8TE.-1R9Mw9xzDNrSxoQ5owopxciklACjBUe43NANibVuy-XPlhqnhAOEaZpxjvTyJ6n79P5bUBCGxO7PcEFQ9p9Cg"

//public var lines = "https://csapi.hfxg.xyz,https://xxx.qixin14.xxx"
//public var cert = "COgBEAUYASDzASitlJSF9zE.5uKWeVH-7G8FIgkaLIhvzCROkWr4D3pMU0-tqk58EAQcLftyD2KBMIdYetjTYQEyQwWLy7Lfkm8cs3aogaThAw"
//public var merchantId = 232
//public var userId: Int32 = 364312 //364310

public var userLevel = 8
 


/*Asai*/
//public var lines = "https://csapi.hfxg.xyz,https://xxx.qixin14.xxx"
//public var cert = "COgBEAUYfyD6ASiusLSp-jE.zTbKuX1Uhra_SFIbyN9p_i_hcAWpU3F8YdD2GYV7ixPMLSO8vSC_Y7OR3_3-VoRQJODwG0rr2GfUUzp_GDQJBA"
//public var merchantId: Int = 232
//public var userId: Int32 = 849//1125324

/*
 客服：gz001/woheni12
 */

//动态生成
//public var CONSULT_ID: Int32 = 1
var xToken = ""
public var userName = "王五"
public var maxSessionMinus = 19999999
public var domain = ""  //domain
//var baseUrlApi = "https://" + domain  //用于请求数据，上传图片
var workerId: Int32 = 2
var chatId = "0"
//未发送出去的消息列表
var unSentMessage: [Int64: [ChatModel]] = [999: []]

var reportRequest = ReportRequest()

public let PARAM_XTOKEN = "HTTPTOKEN"

let serverTimeFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSSSS'Z'"

var iconWidth = 38.0
var imgHeight = 114.0
let titleColour = kHexColor(0x484848)
let timeColor = kHexColor(0xC4C4C4)

let blueColor = UIColor(red: 69/255, green: 137/255, blue: 246/255, alpha: 1.0)
//let chatBackColor = kHexColor(0xf6f6f6)
//let panelBack = kHexColor(0xf4f4f4)

let chatBackColor = UIColor.systemGray
let panelBack = UIColor.lightGray


let serverDateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"


func getCustomParam() -> String{
    let custom = Custom()
    custom.username = "李四"
    custom.platform = 1
    custom.userlevel = userLevel
    let c = custom.toJSONString()?.urlEncoded
    return c ?? ""
}

//#f4f4f4

 func convertDateStringToString(datStr: String) -> String{
    if let date = Date(fromString: datStr, format: serverDateFormat) {
        return date.toString(format: "yyyy-MM-dd HH:mm:ss")
    }else{
        return datStr
    }
}

//yyyy-MM-dd'T'HH:mm:ss.SSSSSSSSS'Z'

func stringToDate(datStr: String) -> Date{
   if let date = Date(fromString: datStr, format: serverDateFormat) {
       return date
   }
    return Date()
}

func stringToDate(datStr: String, format: String) -> Date{
   if let date = Date(fromString: datStr, format: format) {
       return date
   }
    return Date()
}

func getbaseApiUrl() -> String{
    return "https://" + domain
}

func stringToTimeStamp(datStr: String) -> Google_Protobuf_Timestamp{
    let date = stringToDate(datStr: datStr, format: serverTimeFormat)
    
    let localDate = WTimeConvertUtil.converDateToSystemZoneDate(convertDate:date)
    return intervalToTimeStamp(timeInterval: localDate.timeIntervalSince1970)
}

func intervalToTimeStamp(timeInterval: TimeInterval) -> Google_Protobuf_Timestamp{
    // Convert TimeInterval to Google_Protobuf_Timestamp
    var timestamp = Google_Protobuf_Timestamp()
    timestamp.seconds = Int64(timeInterval)
    timestamp.nanos = Int32((timeInterval - Double(Int64(timeInterval))) * 1_000_000_000)
    return timestamp
}

// Function to delay execution
 func delayExecution(seconds: Double, completion: @escaping () -> Void) {
     DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
         completion()
     }
 }

/*
 把注释那些加好，以后别人就照着demo对接
 
 bug list:
 3.demo ----浏览客服端发送的图片需要点击图片时 放大独立浏览图片
 */
