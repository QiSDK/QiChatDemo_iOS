//
//  Constant.swift
//  Pods
//
//  Created by xiao fu on 10/2/23.
//

import Foundation

let PARAM_USER_ID = "USER_ID"
let PARAM_CERT = "CERT"
let PARAM_MERCHANT_ID = "MERCHANT_ID"
let PARAM_LINES = "LINES"

//这几个是需要在设置里面配置
var lines = "https://csapi.xdev.stream,https://wcsapi.qixin14.xyz,https://wcsapi.qixin14.xyz"
var cert = "COYBEAUYASDyASiG2piD9zE.te46qua5ha2r-Caz03Vx2JXH5OLSRRV2GqdYcn9UslwibsxBSP98GhUKSGEI0Z84FRMkp16ZK8eS-y72QVE2AQ"
var merchantId: Int = 230
var userId: Int32 = 666665//1125324
 


// var lines = "https://csapi.xdev.stream,https://wcsapi.qixin14.xyz,https://wcsapi.qixin14.xyz"
//         var cert = "COEBEAUYASDjASiewpj-8TE.-1R9Mw9xzDNrSxoQ5owopxciklACjBUe43NANibVuy-XPlhqnhAOEaZpxjvTyJ6n79P5bUBCGxO7PcEFQ9p9Cg"
//         var merchantId = 225
//         var userId: Int32 = 666663


//var lines = "https://csapi.xdev.stream,https://wcsapi.qixin14.xyz,https://wcsapi.qixin14.xyz"
//var cert = "COgBEAUYASDzASitlJSF9zE.5uKWeVH-7G8FIgkaLIhvzCROkWr4D3pMU0-tqk58EAQcLftyD2KBMIdYetjTYQEyQwWLy7Lfkm8cs3aogaThAw"
//var merchantId = 232
//var userId: Int32 = 364312 //364310
 
 

//动态生成
var CONSULT_ID: Int32 = 1
var xToken = ""
var domain = "wcsapi.qixin14.xyz"  //domain
var baseUrlApi = "https://" + domain  //用于请求数据，上传图片
var baseUrlImage = "https://sssacc.wwc09.com" //用于拼接图片地址
var workerId: Int32 = 2

let PARAM_XTOKEN = "HTTPTOKEN"

let serverTimeFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSSSS'Z'"


 func convertDateStringToString(datStr: String) -> String{
    if let date = Date(fromString: datStr, format: "yyyy-MM-dd'T'HH:mm:ssZ") {
        return date.toString(format: "yyyy-MM-dd HH:mm:ss")
    }else{
        return datStr
    }
}

//yyyy-MM-dd'T'HH:mm:ss.SSSSSSSSS'Z'

func stringToDate(datStr: String) -> Date{
   if let date = Date(fromString: datStr, format: "yyyy-MM-dd'T'HH:mm:ssZ") {
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
