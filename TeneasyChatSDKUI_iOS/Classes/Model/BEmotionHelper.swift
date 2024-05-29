//
//  BEmotionHelper.swift
//  SkinIOS
//
//  Created by XiaoFu on 24/8/2022.
//

import UIKit
class BNSTextAttachment: NSTextAttachment {
    var displayText: String = ""
}

class BEmotionHelper: NSObject {
    static let shared = BEmotionHelper()
    
    /// 表情数据
    var emotionArray: [BEmotion] = [] {
        didSet {
            self.cacheTotalImageDictionary()
        }
    }

    /// 缓存表情
    var cacheEmojiDict: [String: UIImage] = [:]
    /// 缓存富文本
    var cacheAttributedDict: [String: NSAttributedString] = [:]
    /// 正则
    lazy var regularExpression: NSRegularExpression = {
        let regular = try! NSRegularExpression(pattern: "\\[emoticon_[1-9]\\d{0,}\\]", options: .allowCommentsAndWhitespace)
        return regular
    }()
    
    /// 初始化数据
    func cacheTotalImageDictionary() {
        self.cacheEmojiDict = [:]
        for em in self.emotionArray {
            if em.image == nil {
                em.image = UIImage(named: em.identifier, in: BundleUtil.getCurrentBundle(), compatibleWith: nil)
            }
            self.cacheEmojiDict.updateValue(em.image ?? UIImage(), forKey: em.displayName)
        }
    }
    
    /// 把整段String：@"害~你好[微笑]" 转为 @"害~你好😊"
    open func attributedStringByText(text: String, font: UIFont) -> NSMutableAttributedString {
        var emojis = self.regularExpression.matches(in: text, options: .withTransparentBounds, range: NSRange(location: 0, length: text.count))
        let intactAttributeString = NSMutableAttributedString(string: text)
        emojis = emojis.reversed()
        for obj in emojis {
            let emojiKey = text.substring(at: obj.range.location, length: obj.range.length)
            let imageAttributedString = self.obtainAttributedStringByImageKey(imageKey: emojiKey, font: font, useCache: false)
            intactAttributeString.replaceCharacters(in: obj.range, with: imageAttributedString)
        }
        
        intactAttributeString.addAttributes([.font: font], range: NSRange(location: 0, length: intactAttributeString.length))
        return intactAttributeString
    }
    
    /// @"[微笑]" 转为 @"😊"
    open func obtainAttributedStringByImageKey(imageKey: String, font: UIFont, useCache: Bool) -> NSAttributedString {
        if useCache == false {
            let image = self.cacheEmojiDict[imageKey]
            if image == nil {
                return NSAttributedString(string: "")
            }
            let attachMent = BNSTextAttachment()
            attachMent.displayText = imageKey
            attachMent.image = image
            attachMent.bounds = CGRect(x: 0, y: font.descender, width: font.lineHeight, height: font.lineHeight)
            return NSAttributedString(attachment: attachMent)
        }
        return NSAttributedString(string: "")
    }
}

extension BEmotionHelper {
    //    /// 获取emoji表情
    public static func getNewEmoji() -> [BEmotion] {
        var emojiArr: [BEmotion] = []
        for i in 1 ... 99 {
            let indentifiName = "emoticon_\(i)"
            let imgName = "[" + indentifiName + "]"
            let emotion = BEmotion(identifier: indentifiName, displayName: imgName)
            emojiArr.append(emotion)
        }
        return emojiArr
    }
    
    /// 获取菜单元素
    public static func getMenuItems() -> [BEmotion] {
        let items = [BEmotion(identifier: "icon_photo", displayName: "图片")]
        return items
    }
}

public extension String {
    /// 截取特定范围的字符串 索引从 0 开始
    /// - Parameters:
    ///   - location: 开始的索引位置
    ///   - length: 截取长度
    /// - Returns: 字符串
    func substring(at location: Int, length: Int) -> String {
        if location > self.count || (location + length > self.count) {
            assert(location < self.count && location + length <= self.count, "越界, 检查设置的范围")
        }
        var subStr = ""
        for idx in location ..< (location + length) {
            subStr += self[self.index(self.startIndex, offsetBy: idx)].description
        }
        return subStr
    }
}
