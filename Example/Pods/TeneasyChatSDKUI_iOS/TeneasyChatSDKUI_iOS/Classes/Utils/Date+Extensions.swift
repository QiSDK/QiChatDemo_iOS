//
//  DateExtensions.swift
//  EZSwiftExtensions
//
//  Created by Goktug Yilmaz on 15/07/15.
//  Copyright (c) 2015 Goktug Yilmaz. All rights reserved.
//

import Foundation

public enum TimePassed {
    
    case year(Int)
    case month(Int)
    case day(Int)
    case hour(Int)
    case minute(Int)
    case second(Int)
    case now
}

extension TimePassed: Equatable {
    
    public static func ==(lhs: TimePassed, rhs: TimePassed) -> Bool {
        
        switch(lhs, rhs) {
        
        case (.year(let a), .year(let b)):
            return a == b
            
        case (.month(let a), .month(let b)):
            return a == b
            
        case (.day(let a), .day(let b)):
            return a == b
            
        case (.hour(let a), .hour(let b)):
            return a == b
            
        case (.minute(let a), .minute(let b)):
            return a == b
            
        case (.second(let a), .second(let b)):
            return a == b
            
        case (.now, .now):
            return true
            
        default:
            return false
        }
    }
}

/// EZSE: This Date Formatter Manager help to cache already created formatter in a synchronized Dictionary to use them in future, helps in performace improvement.
/// EZSE: This Synchronized Dictionary gets generic key, value types and used for the purpose of read, write on a dictionary Synchronized.
public class SynchronizedDictionary <Key: Hashable, Value> {
    
    fileprivate let queue = DispatchQueue(label: "SynchronizedDictionary", attributes: .concurrent)
    fileprivate var dict = [Key: Value]()
    
    func getValue(for key: Key) -> Value? {
        var value: Value?
        queue.sync {
            value = dict[key]
        }
        return value
    }
    
    func setValue(for key: Key, value: Value) {
        queue.sync {
            dict[key] = value
        }
    }
    
    func getSize() -> Int {
        return dict.count
    }
    
//    func containValue(for key: Key) -> Bool {
//        return dict.has(key)
//    }
}

class DateFormattersManager {
    public static var dateFormatters: SynchronizedDictionary = SynchronizedDictionary<String, DateFormatter>()
}

extension Date {
    
    public static let minutesInAWeek = 24 * 60 * 7
    
    /// EZSE: Initializes Date from string and format
    public init?(fromString string: String,
                 format: String,
                 timezone: TimeZone = TimeZone.autoupdatingCurrent,
                 locale: Locale = Locale.current) {
        if let dateFormatter = DateFormattersManager.dateFormatters.getValue(for: format) {
            if let date = dateFormatter.date(from: string) {
                self = date
            } else {
                return nil
            }
        } else {
            let formatter = DateFormatter()
            formatter.timeZone = timezone
            formatter.locale = locale
            formatter.dateFormat = format
            DateFormattersManager.dateFormatters.setValue(for: format, value: formatter)
            if let date = formatter.date(from: string) {
                self = date
            } else {
                return nil
            }
        }
    }
    
    /// EZSE: Initializes Date from string returned from an http response, according to several RFCs / ISO
    public init?(httpDateString: String) {
        if let rfc1123 = Date(fromString: httpDateString, format: "EEE',' dd' 'MMM' 'yyyy HH':'mm':'ss zzz") {
            self = rfc1123
            return
        }
        if let rfc850 = Date(fromString: httpDateString, format: "EEEE',' dd'-'MMM'-'yy HH':'mm':'ss z") {
            self = rfc850
            return
        }
        if let asctime = Date(fromString: httpDateString, format: "EEE MMM d HH':'mm':'ss yyyy") {
            self = asctime
            return
        }
        if let iso8601DateOnly = Date(fromString: httpDateString, format: "yyyy-MM-dd") {
            self = iso8601DateOnly
            return
        }
        if let iso8601DateHrMinOnly = Date(fromString: httpDateString, format: "yyyy-MM-dd'T'HH:mmxxxxx") {
            self = iso8601DateHrMinOnly
            return
        }
        if let iso8601DateHrMinSecOnly = Date(fromString: httpDateString, format: "yyyy-MM-dd'T'HH:mm:ssxxxxx") {
            self = iso8601DateHrMinSecOnly
            return
        }
        if let iso8601DateHrMinSecMs = Date(fromString: httpDateString, format: "yyyy-MM-dd'T'HH:mm:ss.SSSxxxxx") {
            self = iso8601DateHrMinSecMs
            return
        }
        return nil
    }
    
    /// EZSE: Converts Date to String
    public func toString(dateStyle: DateFormatter.Style = .medium, timeStyle: DateFormatter.Style = .medium) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = dateStyle
        formatter.timeStyle = timeStyle
        return formatter.string(from: self)
    }
    
    /// EZSE: Converts Date to String, with format
    public func toString(format: String) -> String {
        
        let dateFormatter = getDateFormatter(for: format)
        return dateFormatter.string(from: self)
    }
    
    /// EZSE: Use to get dateFormatter from synchronized Dict via dateFormatterManager
    private func getDateFormatter(for format: String) -> DateFormatter {
        
        var dateFormatter: DateFormatter?
        if let _dateFormatter = DateFormattersManager.dateFormatters.getValue(for: format) {
            dateFormatter = _dateFormatter
        } else {
            dateFormatter = createDateFormatter(for: format)
        }
        
        return dateFormatter!
    }
    
    ///EZSE: CreateDateFormatter if formatter doesn't exist in Dict.
    private func createDateFormatter(for format: String) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        DateFormattersManager.dateFormatters.setValue(for: format, value: formatter)
        return formatter
    }
    
    /// EZSE: Calculates how many days passed from now to date
    public func daysInBetweenDate(_ date: Date) -> Double {
        var diff = self.timeIntervalSince1970 - date.timeIntervalSince1970
        diff = fabs(diff/86400)
        return diff
    }
    
    /// EZSE: Calculates how many hours passed from now to date
    public func hoursInBetweenDate(_ date: Date) -> Double {
        var diff = self.timeIntervalSince1970 - date.timeIntervalSince1970
        diff = fabs(diff/3600)
        return diff
    }
    
    /// EZSE: Calculates how many minutes passed from now to date
    public func minutesInBetweenDate(_ date: Date) -> Double {
        var diff = self.timeIntervalSince1970 - date.timeIntervalSince1970
        diff = fabs(diff/60)
        return diff
    }
    
    /// EZSE: Calculates how many seconds passed from now to date
    public func secondsInBetweenDate(_ date: Date) -> Double {
        var diff = self.timeIntervalSince1970 - date.timeIntervalSince1970
        diff = fabs(diff)
        return diff
    }
    
    /// EZSE: Easy creation of time passed String. Can be Years, Months, days, hours, minutes or seconds
    public func timePassed() -> String {
        let date = Date()
        let calendar = Calendar.autoupdatingCurrent
        let components = (calendar as NSCalendar).components([.year, .month, .day, .hour, .minute, .second], from: self, to: date, options: [])
        var str: String
        
        if components.year! >= 1 {
            components.year == 1 ? (str = "year") : (str = "years")
            return "\(components.year!) \(str) ago"
        } else if components.month! >= 1 {
            components.month == 1 ? (str = "month") : (str = "months")
            return "\(components.month!) \(str) ago"
        } else if components.day! >= 1 {
            components.day == 1 ? (str = "day") : (str = "days")
            return "\(components.day!) \(str) ago"
        } else if components.hour! >= 1 {
            components.hour == 1 ? (str = "hour") : (str = "hours")
            return "\(components.hour!) \(str) ago"
        } else if components.minute! >= 1 {
            components.minute == 1 ? (str = "minute") : (str = "minutes")
            return "\(components.minute!) \(str) ago"
        } else if components.second! >= 1 {
            components.second == 1 ? (str = "second") : (str = "seconds")
            return "\(components.second!) \(str) ago"
        } else {
            return "Just now"
        }
    }
    
    /// EZSE: Easy creation of time passed String. Can be Years, Months, days, hours, minutes or seconds. Useful for localization
    public func timePassed() -> TimePassed {
        
        let date = Date()
        let calendar = Calendar.autoupdatingCurrent
        let components = (calendar as NSCalendar).components([.year, .month, .day, .hour, .minute, .second], from: self, to: date, options: [])
        
        if components.year! >= 1 {
            return TimePassed.year(components.year!)
        } else if components.month! >= 1 {
            return TimePassed.month(components.month!)
        } else if components.day! >= 1 {
            return TimePassed.day(components.day!)
        } else if components.hour! >= 1 {
            return TimePassed.hour(components.hour!)
        } else if components.minute! >= 1 {
            return TimePassed.minute(components.minute!)
        } else if components.second! >= 1 {
            return TimePassed.second(components.second!)
        } else {
            return TimePassed.now
        }
    }
    
    /// EZSE: Check if date is in future.
    public var isFuture: Bool {
        return self > Date()
    }
    
    /// EZSE: Check if date is in past.
    public var isPast: Bool {
        return self < Date()
    }
    
    // EZSE: Check date if it is today
    public var isToday: Bool {
        let format = "yyyy-MM-dd"
        let dateFormatter = getDateFormatter(for: format)
        return dateFormatter.string(from: self) == dateFormatter.string(from: Date())
    }
    
    /// EZSE: Check date if it is yesterday
    public var isYesterday: Bool {
        let format = "yyyy-MM-dd"
        let yesterDay = Calendar.current.date(byAdding: .day, value: -1, to: Date())
        let dateFormatter = getDateFormatter(for: format)
        return dateFormatter.string(from: self) == dateFormatter.string(from: yesterDay!)
    }
    
    /// EZSE: Check date if it is tomorrow
    public var isTomorrow: Bool {
        let format = "yyyy-MM-dd"
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date())
        let dateFormatter = getDateFormatter(for: format)
        
        return dateFormatter.string(from: self) == dateFormatter.string(from: tomorrow!)
    }
    
    /// EZSE: Check date if it is within this month.
    public var isThisMonth: Bool {
        let today = Date()
        return self.month == today.month && self.year == today.year
    }
    
    /// EZSE: Check date if it is within this week.
    public var isThisWeek: Bool {
        return self.minutesInBetweenDate(Date()) <= Double(Date.minutesInAWeek)
    }
    
    /// EZSE: Get the era from the date
    public var era: Int {
        return Calendar.current.component(Calendar.Component.era, from: self)
    }
    
    /// EZSE : Get the year from the date
    public var year: Int {
        return Calendar.current.component(Calendar.Component.year, from: self)
    }
    
    /// EZSE : Get the month from the date
    public var month: Int {
        return Calendar.current.component(Calendar.Component.month, from: self)
    }
    
    /// EZSE : Get the weekday from the date
    public var weekday: String {
        let format = "EEEE"
        let dateFormatter = getDateFormatter(for: format)
        return dateFormatter.string(from: self)
    }
    
    // EZSE : Get the month from the date
    public var monthAsString: String {
        let format = "MMMM"
        let dateFormatter = getDateFormatter(for: format)
        return dateFormatter.string(from: self)
    }
    
    // EZSE : Get the day from the date
    public var day: Int {
        return Calendar.current.component(.day, from: self)
    }
    
    /// EZSE: Get the hours from date
    public var hour: Int {
        return Calendar.current.component(.hour, from: self)
    }
    
    /// EZSE: Get the minute from date
    public var minute: Int {
        return Calendar.current.component(.minute, from: self)
    }
    
    /// EZSE: Get the second from the date
    public var second: Int {
        return Calendar.current.component(.second, from: self)
    }
    
    /// EZSE : Gets the nano second from the date
    public var nanosecond: Int {
        return Calendar.current.component(.nanosecond, from: self)
    }
    
    #if os(iOS) || os(tvOS)
    
    /// EZSE : Gets the international standard(ISO8601) representation of date
    @available(iOS 10.0, *)
    @available(tvOS 10.0, *)
    public var iso8601: String {
        let formatter = ISO8601DateFormatter()
        return formatter.string(from: self)
    }
    
    #endif
}

fileprivate let zodiacs: [String] = ["鼠", "猪", "狗", "鸡", "猴", "羊", "马", "蛇", "龙", "兔", "虎","牛"]

extension Date {
    /**
       根据时间戳获取 dd  hh:mm:ss
     */
    static  func getHHMMSSTimeString(teptime:TimeInterval) ->String{
        var time:Int = Int(teptime)
                  let ss = time % 60
                  time = time / 60
                  let mm = time % 60
                   time = time / 60
                  let hh = time % 24
                  time = time / 24
        var dd:Int = 0
        if time > 0 {
            dd = time
        }
        var str = ""
        if dd > 0 {
            str = str + String(format: "%02d ", dd)
        }
        str = str + String(format: "%02d:%02d:%02d", hh,mm,ss)
        return str
    }
    
//    static func getDayWithTimeInterval(time:TimeInterval) -> Int {
//        var day = Int(time)/24/3600
//    }
    
    // 当年农历年份
    func zodiac() -> Int {
        let calendar: Calendar = Calendar(identifier: .chinese)
        return calendar.component(.year, from: self)
    }
    
    /// 获取农历年份
//    func lunarDate() -> Int {
//        let formatter = DateFormatter()
//        formatter.dateStyle = .short
//        formatter.timeStyle = .none
//        formatter.locale = Locale(identifier: "zh_CN")
//        formatter.calendar = Calendar.init(identifier: .chinese)
//        let nowLunarDate = formatter.string(from: Date())
//        let year = nowLunarDate.split("-").first ?? "2022"
//        
//        return year.toInt() ?? 2022
//    }
    
    //年份生肖
    static func zodiac(year: Int) -> String {
        let zodiacIndex: Int = (year - 1) % zodiacs.count
        return zodiacs[zodiacIndex]
    }
    
    
    ///根据时间戳创建日期 10位时间戳
    ///     let date = Date(unixTimestamp: 1484239783.922743) // "Jan 12, 2017, 7:49 PM"
    ///
    /// - Parameter unixTimestamp: UNIX timestamp.
    public init(unixTimestamp: Double) {
        self.init(timeIntervalSince1970: unixTimestamp)
    }
    
    
    
    
    /// 时间戳日期按照给定的格式转化为日期字符串
    ///     Date().string(withFormat: "dd/MM/yyyy") -> "1/12/17"
    ///     Date().string(withFormat: "HH:mm") -> "23:50"
    ///     Date().string(withFormat: "dd/MM/yyyy HH:mm") -> "1/12/17 23:50"
    ///        yyyy-MM-dd HH:mm:ss
    /// - Parameter format: Date format (default is "dd/MM/yyyy").
    /// - Returns: date string.
    static func string(withFormat format: String = "yyyy-MM-dd HH:mm:ss" ,timeStamp:String,isChina:Bool = false) -> String {
        if timeStamp.count < 1 {return ""}
        let interval:TimeInterval = TimeInterval.init(timeStamp)!

        let date = Date(timeIntervalSince1970: interval/1000)  //因为是十三位时间戳所以要除1000
        //13位数时间戳 (13位数的情况比较少见)
        // let interval = CLongLong(round(nowDate.timeIntervalSince1970*1000))
        let dateFormatter = DateFormatter()
        if isChina {
            dateFormatter.timeZone = TimeZone(identifier:"Asia/Chongqing")
        }
        
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: date)
    }
    
    // 时间戳日期按照给定的格式转化为日期字符串
    ///     Date().string(withFormat: "dd/MM/yyyy") -> "1/12/17"
    ///     Date().string(withFormat: "HH:mm") -> "23:50"
    ///     Date().string(withFormat: "dd/MM/yyyy HH:mm") -> "1/12/17 23:50"
    ///        yyyy-MM-dd HH:mm:ss
    /// - Parameter format: Date format (default is "dd/MM/yyyy").
    /// - Returns: date string.
    static func string(format: String = "yyyy-MM-dd HH:mm:ss", timestamp:String) -> Date? {
        let dateFormatter = DateFormatter()
//        dateFormatter.timeZone = TimeZone(identifier:"Asia/Chongqing")
        dateFormatter.dateFormat = format
        return dateFormatter.date(from: timestamp)
    }
    
    /// Date日期按照给定的格式转化为日期字符串
    /// - Parameter format: Date format (default is "yyyy-MM-dd").
    /// - Returns: date string.
    static func stringDate(withFormat format: String = "yyyy-MM-dd" , date:Date = Date(),isChina:Bool = false) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        if isChina {
            dateFormatter.timeZone = TimeZone(identifier:"Asia/Chongqing")
        }
        return dateFormatter.string(from: date)
    }
    
    /// 时间戳转成字符串
    static func timeIntervalChangeToTimeStr(timeInterval:TimeInterval, dateFormat:String?) -> String {
        let date:NSDate = NSDate.init(timeIntervalSince1970: timeInterval)
        let formatter = DateFormatter.init()
        if dateFormat == nil {
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        }else{
            formatter.dateFormat = dateFormat
        }
        return formatter.string(from: date as Date)
    }
    
    /// 字符串转时间戳
    static func timeStrChangeTotimeInterval(timeStr: String?, dateFormat:String="yyyy-MM-dd HH:mm:ss") -> String {
        if timeStr?.count == 0 {
            return ""
        }
        let format = DateFormatter.init()
        format.dateStyle = .medium
        format.timeStyle = .short
        format.timeZone = TimeZone(identifier:"Asia/Chongqing")
//        if dateFormat == nil {
//            format.dateFormat = "yyyy-MM-dd HH:mm:ss"
//        }else{
        format.dateFormat = dateFormat
//        }
        let date = format.date(from: timeStr!)
        return date!.milliStamp
    }
    
    /// 日期字符串转化为Date类型
    ///
    /// - Parameters:
    ///   - string: 日期字符串
    ///   - dateFormat: 格式化样式，默认为“yyyy-MM-dd HH:mm:ss”
    /// - Returns: Date类型
    static func stringConvertDate(string:String, dateFormat:String="yyyy-MM-dd HH:mm:ss") -> Date {
        let dateFormatter = DateFormatter.init()
        dateFormatter.dateFormat = dateFormat
        let date = dateFormatter.date(from: string)
        return date!
    }
    
    ///计算两个时间相差几天 可把day扩展为其他
    static func numberOfDaysWithFromDate(date:Date, toDate:Date) -> Int {
        let calendar = NSCalendar.init(calendarIdentifier: .gregorian)
        let comp = calendar?.components(.day, from: date, to: toDate, options: .wrapComponents)
        return comp?.day ?? 0
    }
    
    static func numberOfMinutesWithFromDate(date:Date, toDate:Date) -> Int {
        let calendar = NSCalendar.init(calendarIdentifier: .gregorian)
        let comp = calendar?.components(.minute, from: date, to: toDate, options: .wrapComponents)
        return comp?.minute ?? 0
    }
    
    /// 获取当前 秒级 时间戳 - 10位
    var timeStamp : String {
        let timeInterval: TimeInterval = self.timeIntervalSince1970
        let timeStamp = Int(timeInterval)
        return "\(timeStamp)"
    }
    
    /// 获取当前 毫秒级 时间戳 - 13位
    var milliStamp : String {
        let timeInterval: TimeInterval = self.timeIntervalSince1970
        let millisecond = CLongLong(round(timeInterval*1000))
        return "\(millisecond)"
    }
    
    
    //MARK: 将两个时间戳间隔 显示为（几分钟前，几小时前，几天前）
    ///     将两个时间戳间隔 显示为（几分钟前，几小时前，几天前）
    /// - Parameter stamp1: int    小的时间戳
    /// - Parameter stamp2: int    大的时间戳
    /// - Returns: string (几分钟前，几小时前，几天前）
    static func twotimeStampCompare(_ stamp1:Int ,_ stamp2:Int) -> String {
        if stamp1 > stamp2 { return "0秒前" }
        let timeInterval:TimeInterval = TimeInterval((stamp2 - stamp1)/1000)
        var temp:Double = 0
        var result:String = ""
        if timeInterval/60 < 1 {
            
            //            result = "刚刚"
            result = "\(Int(timeInterval))秒前"
            
        }else if (timeInterval/60) < 60{
            
            temp = timeInterval/60
            
            result = "\(Int(temp))分钟前"
            
        }else if timeInterval/60/60 < 24 {
            
            temp = timeInterval/60/60
            
            result = "\(Int(temp))小时前"
            
        }else if timeInterval/(24 * 60 * 60) < 30 {
            
            temp = timeInterval / (24 * 60 * 60)
            
            result = "\(Int(temp))天前"
            
        }else if timeInterval/(30 * 24 * 60 * 60)  < 12 {
            
            temp = timeInterval/(30 * 24 * 60 * 60)
            
            result = "\(Int(temp))个月前"
            
        }else{
            
            temp = timeInterval/(12 * 30 * 24 * 60 * 60)
            
            result = "\(Int(temp))年前"
            
        }
        
        return result
        
    }
    
    
    
    /*
     几年几月 这个月的多少天
     */
    static func getDaysInMonth( year: Int, month: Int) -> Int {
        
        let calendar = NSCalendar.current
        
        let startComps = NSDateComponents()
        startComps.day = 1
        startComps.month = month
        startComps.year = year
        
        let endComps = NSDateComponents()
        endComps.day = 1
        endComps.month = month == 12 ? 1 : month + 1
        endComps.year = month == 12 ? year + 1 : year
        
        let startDate = calendar.date(from: startComps as DateComponents)
        let endDate = calendar.date(from:endComps as DateComponents)!
        
        let diff = calendar.dateComponents([.day], from: startDate!, to: endDate)
        
        return diff.day!;
    }
    
    
    /*
     几年几月 这个月的第一天是星期几
     */
    static func firstWeekdayInMonth(year: Int, month: Int)->Int{
        
        let calender = NSCalendar.current;
        let startComps = NSDateComponents()
        startComps.day = 1
        startComps.month = month
        startComps.year = year
        let startDate = calender.date(from: startComps as DateComponents)
        let firstWeekday = calender.ordinality(of: .weekday, in: .weekOfMonth, for: startDate!)
        let week = firstWeekday! - 1;
        
        return week ;
    }
    
    /*
     今天是星期几
     */
    func dayOfWeek() -> Int {
        let interval = self.timeIntervalSince1970;
        let days = Int(interval / 86400);// 24*60*60
        return (days - 3) % 7;
    }
    
    static func getCurrentDay() ->Int {
        
        let com = self.getComponents();
        return com.day!
    }
    
    static func getCurrentMonth() ->Int {
        
        let com = self.getComponents();
        return com.month!
    }
    
    static func getCurrentYear() ->Int {
        
        let com = self.getComponents();
        return com.year!
    }
    
    static func getComponents(date:Date = Date())->DateComponents{
        
        let calendar = NSCalendar.current;
        //这里注意 swift要用[,]这样方式写
        let com = calendar.dateComponents([.year,.month,.day,.hour,.minute], from:date);
        return com
    }
    
    
    static func getComponents(timestamp:TimeInterval)->DateComponents{
        
        let date = Date(timeIntervalSince1970: timestamp / 1000)
        let calendar = NSCalendar.current;
        //这里注意 swift要用[,]这样方式写
        let com = calendar.dateComponents([.year,.month,.day,.hour,.minute], from:date);
        return com
    }
    
    /// 获取指定日期之前的第N天
    static func getDayForDesignDaysPreviou(designDate:Date = Date(), format:String = "yyyy-MM-dd", previou:Int = 7) -> Date? {
        //当前时间
        let currentDate = designDate
        let calender = Calendar(identifier: Calendar.Identifier.gregorian)
        var comp = calender.dateComponents([.year, .month, .day, .weekday], from: currentDate)

        //当前时间是几号、周几
        let currentDay = comp.day
        let weeKDay = comp.weekday

        //如果获取当前时间的日期和周几失败，返回nil
        guard let day = currentDay, let week = weeKDay else {
            return nil
        }

        //由于1代表的是周日，因此计算出准确的周几
        var currentWeekDay = 0
        if week == 1 {
            currentWeekDay = 7
        } else {
            currentWeekDay = week - 1
        }

        //1 ... 7表示周一到周日
        //进行遍历和currentWeekDay进行比较，计算出之间的差值，即为当前日期和一周时间日期的差值，即可计算出一周时间内准备的日期
//        var dateStrs: [String] = []
        var dateResult = Date()
        for index in 1 ... previou {
            let diff = index - currentWeekDay
            comp.day = day - diff
            let date = calender.date(from: comp)
        
            //由于上述方法返回的Date为可选类型，要进行判空处理
            if let _ = date {
                if previou == index + 1 {
                    dateResult = date ?? Date()
                }
            }
        }
        //返回时间
        return dateResult
    }
    
    /// 获取指定日期之前的N天日期
    static func getDaysForDesignDaysPrevious(designDate:Date = Date(), format:String = "yyyy年MM月dd日", previous:Int = 7) -> [String]? {
        //当前时间
        let currentDate = designDate
        let calender = Calendar(identifier: Calendar.Identifier.gregorian)
        var comp = calender.dateComponents([.year, .month, .day, .weekday], from: currentDate)

        //当前时间是几号、周几
        let currentDay = comp.day
        let weeKDay = comp.weekday

        //如果获取当前时间的日期和周几失败，返回nil
        guard let day = currentDay, let week = weeKDay else {
            return nil
        }

        //由于1代表的是周日，因此计算出准确的周几
        var currentWeekDay = 0
        if week == 1 {
            currentWeekDay = 7
        } else {
            currentWeekDay = week - 1
        }

        //1 ... 7表示周一到周日
        //进行遍历和currentWeekDay进行比较，计算出之间的差值，即为当前日期和一周时间日期的差值，即可计算出一周时间内准备的日期
        var dateStrs: [String] = []
        for index in 1 ... previous {
            let diff = index - currentWeekDay
            comp.day = day - diff
            let date = calender.date(from: comp)
        
            //由于上述方法返回的Date为可选类型，要进行判空处理
            if let _ = date {
                let dateStr =  Date.stringDate(withFormat: format, date: date!, isChina: true)
                dateStrs.append(dateStr)
            }
        }

        //返回时间数组
        return dateStrs
    }
    
    /// 获取指定日期之前的N个月月份
    static func getMonthsForDesignMonthPrevious(format: String = "yyyy年MM月", design:Date = Date(), previous:Int = 10) -> [String] {
        let curDate = design
        let formater = DateFormatter()
        formater.dateFormat = format
        
        let calendar = Calendar(identifier: .gregorian)
        var lastMonthComps = DateComponents()
        var months = [String]()
        for i in 0..<previous {
            // year = 1表示1年后的时间 year = -1为1年前的日期，month day 类推
            lastMonthComps.month = -i
            let newDate = calendar.date(byAdding: lastMonthComps, to: curDate)
            let dateStr = formater.string(from: newDate!)
            months.append(dateStr)
        }
        
        return months
    }
    
    
    static func getWeekDay(timeStamp:TimeInterval) -> String {
        let weekday = ["周日","周一","周二","周三","周四","周五","周六"]
        
        let newDate = Date(timeIntervalSince1970: timeStamp / 1000)
        let calendar = Calendar(identifier: .gregorian)
        let compoents = calendar.dateComponents([.weekday], from: newDate)
        
        let weekStr = weekday[compoents.weekday! - 1]
        
        return weekStr
    }
}

