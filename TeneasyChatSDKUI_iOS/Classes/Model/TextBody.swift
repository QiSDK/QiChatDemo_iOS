//
//  TextBody.swift
//  Pods
//
//  Created by XiaoFu on 5/5/25.
//
import Foundation
import HandyJSON

class TextBody: HandyJSON {
    var content: String?
    var image: String?
    var video: String?
    var color: String?
    required init(){}
}




class TextImages: HandyJSON {
    required init(){}
    var message: String = ""
    var imgs: [String] = []
}
