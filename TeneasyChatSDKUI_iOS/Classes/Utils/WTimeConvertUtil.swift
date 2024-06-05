//
//  WTimeConvertUtil.swift
//  WangWang
//
//  Created by evanchan on 2022/10/14.
//

import SwiftDate
import UIKit

class WTimeConvertUtil: NSObject {
    // 用于转换服务器的时间是GMT+0
    static func displayLocalTime(from timestamp: TimeInterval) -> String {
        let gmtDate = Date(timeIntervalSince1970: timestamp)
        let zone = NSTimeZone.system // 获得系统的时区
        let time = zone.secondsFromGMT(for: gmtDate) // 以秒为单位返回当前时间与系统格林尼治时间的差
        let msgDate = gmtDate.addingTimeInterval(TimeInterval(time)) // 然后把差的时间加上,就是当前系统准确的时间
        
        if Calendar.current.isDateInToday(gmtDate) {
            return String(format: "%.2d", msgDate.hour) + ":" + String(format: "%.2d", msgDate.minute)
        }
        else if Calendar.current.isDateInYesterday(msgDate) {
            return "昨天 " + String(format: "%.2d", msgDate.hour) + ":" + String(format: "%.2d", msgDate.minute)
        }
        else if msgDate.isThisYear() {
            return "\(msgDate.month)月\(msgDate.day)日"
        }
        else {
            return "\(msgDate.year)/\(msgDate.month)/\(msgDate.day)"
        }
    }
    
    // 把任何服务器时间转换为本地时间，很神奇的一个方案，可能会有几秒的差别
    static func displayLocalTime(from msgDate: Date) -> String {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: msgDate)
        let minutes = calendar.component(.minute, from: msgDate)
        let seconds = calendar.component(.minute, from: msgDate)
         
//        if Calendar.current.isDateInToday(msgDate) {
//            return String(format: "%.2d", hour) + ":" + String(format: "%.2d", minutes) + ":" + String(format: "%.2d", seconds)
//        }
//        else if Calendar.current.isDateInYesterday(msgDate) {
//            return "昨天 " + String(format: "%.2d", msgDate.hour) + ":" + String(format: "%.2d", msgDate.minute) + ":" + String(format: "%.2d", seconds)
//        }
//        else if msgDate.isThisYear() {
//            return "\(msgDate.month)月\(msgDate.day)日"
//        }
//        else {
//            return "\(msgDate.year)/\(msgDate.month)/\(msgDate.day)"
//        }
        
        return "\(msgDate.year)年\(msgDate.month)月\(msgDate.day)日 " + String(format: "%.2d", msgDate.hour) + ":" + String(format: "%.2d", msgDate.minute) + ":" + String(format: "%.2d", seconds)
    }
    
    static func getHourAndMinute(from date: Date) -> String {
        return String(format: "%.2d", date.hour) + ":" + String(format: "%.2d", date.minute)
        /*
         if date.hour < 5 {
             return "凌晨\(date.hour):" + String(format: "%.2d", date.minute)
         }
         else if date.hour < 12 { // hour >= 5 && hour < 12
             return "上午\(date.hour):" + String(format: "%.2d", date.minute)
         }
         else if date.hour < 17 {// hour >= 12 && hour < 17
             return date.hour == 12 ? ("下午12:" + String(format: "%.2d", date.minute)) : ("下午\(date.hour-12):" + String(format: "%.2d", date.minute))
         }
         else if date.hour < 21 {// hour >= 17 && hour < 21
             return "晚上\(date.hour-12):" + String(format: "%.2d", date.minute)
         }
         else if date.hour < 24 {// hour < 24
             return "晚上\(date.hour-12):" + String(format: "%.2d", date.minute)
         }
         return ""
         */
    }
    
    // 用于首页会话列表时单元格cell
    static func convertTimeStampToDateForHomePage(from timestamp: TimeInterval) -> String {
        let msgDate = Date(timeIntervalSince1970: timestamp)
        
        if Calendar.current.isDateInToday(msgDate) {
            return String(format: "%.2d", msgDate.hour) + ":" + String(format: "%.2d", msgDate.minute) + ":" + String(format: "%.2d", msgDate.second)
        }
        else if Calendar.current.isDateInYesterday(msgDate) {
            return "昨天 " + String(format: "%.2d", msgDate.hour) + ":" + String(format: "%.2d", msgDate.minute) + ":" + String(format: "%.2d", msgDate.second)
        }
        else if msgDate.isThisYear() {
            return "\(msgDate.month)月\(msgDate.day)日"
        }
        else {
            return "\(msgDate.year)/\(msgDate.month)/\(msgDate.day)"
        }
    }
    

     static func converDateToSystemZoneDate(convertDate:Date) -> Date{
         let date = convertDate // 获得时间对象
         let zone = NSTimeZone.system // 获得系统的时区
         let time = zone.secondsFromGMT(for: date)// 以秒为单位返回当前时间与系统格林尼治时间的差
         return date.addingTimeInterval(TimeInterval(time))// 然后把差的时间加上,就是当前系统准确的时间
     }
    
     func getLocalDate(from UTCDate: String) -> String {
            
         let dateFormatter = DateFormatter.init()

         // UTC 时间格式
         dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
         let utcTimeZone = TimeZone(abbreviation: "UTC")
         dateFormatter.timeZone = utcTimeZone

         guard let dateFormatted = dateFormatter.date(from: UTCDate) else {
             return ""
         }

         // 输出格式
         dateFormatter.timeZone = TimeZone.current
         dateFormatter.dateFormat = "yyyy:MM:dd HH:mm:ss"
         let dateString = dateFormatter.string(from: dateFormatted)

         return dateString
     }
      
}

extension Date {
    /**
     *  是否为今天
     */
    func issToday() -> Bool {
        let calendar = Calendar.current
        let unit: Set<Calendar.Component> = [.day, .month, .year]
        let nowComps = calendar.dateComponents(unit, from: Date())
        let selfCmps = calendar.dateComponents(unit, from: self)
        
        return (selfCmps.year == nowComps.year) &&
            (selfCmps.month == nowComps.month) &&
            (selfCmps.day == nowComps.day)
    }
    
    /**
     *  是否为昨天
     */
    func issYesterday() -> Bool {
        let calendar = Calendar.current
        let unit: Set<Calendar.Component> = [.day, .month, .year]
        let nowComps = calendar.dateComponents(unit, from: Date())
        let selfCmps = calendar.dateComponents(unit, from: self)
        if selfCmps.day == nil || nowComps.day == nil {
            return false
        }
        let count = nowComps.day! - selfCmps.day!
        return (selfCmps.year == nowComps.year) &&
            (selfCmps.month == nowComps.month) &&
            (count == 1)
    }
    
    /// 只有年月日的字符串
    func dataWithYMD() -> String {
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd"
        let selfStr = fmt.string(from: self)
        let result = fmt.date(from: selfStr)!
        print(result)
        return selfStr
    }
    
    func dataWithFormat(fmtString: String) -> String {
        let fmt = DateFormatter()
        fmt.dateFormat = fmtString
        let selfStr = fmt.string(from: self)
        let result = fmt.date(from: selfStr)!
        return selfStr
    }
    
    /// 获取当前年月日的时间戳
    func timeIntervalWithYMDDate() -> TimeInterval {
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd"
        let selfStr = fmt.string(from: self)
        let result = fmt.date(from: selfStr)!
        return result.timeIntervalSinceReferenceDate + 24 * 60 * 60
    }

    /**
     *  是否为今年
     */
    func isThisYear() -> Bool {
        let calendar = Calendar.current
        let nowCmps = calendar.dateComponents([.year], from: Date())
        let selfCmps = calendar.dateComponents([.year], from: self)
        let result = nowCmps.year == selfCmps.year
        return result
    }

    /**
     *  获得与当前时间的差距
     */
    func deltaWithNow() -> DateComponents {
        let calendar = Calendar.current
        let cmps = calendar.dateComponents([.hour, .minute, .second], from: self, to: Date())
        return cmps
    }
    /**
     *  获得星期几
     */
//    func getWeekDay() -> Int {
//        let calendar = Calendar.current
//        if let weekday = calendar.dateComponents([.weekday], from: Date()).weekday {
//            //第一天是从星期天算起，weekday在 1~7之间
//            print((weekday + 5) % 7)
//            return (weekday + 5) % 7
//        }
//        return 0
//    }
}
