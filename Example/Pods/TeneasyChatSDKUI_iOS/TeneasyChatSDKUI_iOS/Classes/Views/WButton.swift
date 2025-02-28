//
//  FFButton.swift
//  ProgramIOS
//
//  Created by apple01 on 2021/1/11.
//

import UIKit

public typealias BlockButtonAction = (_ sender: WButton) -> Void

open class WButton: UIButton {
    
    open var action: BlockButtonAction?
    
    public init() {
        super.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        defaultInit()
    }
    
    public init(action: @escaping BlockButtonAction) {
        super.init(frame: CGRect.zero)
        self.action = action
        defaultInit()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        defaultInit()
    }
    
    public init(frame: CGRect, action: @escaping BlockButtonAction) {
        super.init(frame: frame)
        self.action = action
        defaultInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        defaultInit()
    }
    
    private func defaultInit() {
        addTarget(self, action: #selector(WButton.didPressed(_:)), for: UIControl.Event.touchUpInside)
    }
    
    @objc open func didPressed(_ sender: WButton) {
        action?(sender)
    }
    
    open func addAction(_ action: @escaping BlockButtonAction) {
        self.action = action
    }
    //禁用按钮高亮状态
    open override var isHighlighted: Bool{
        set{
            
        }
        get {
            return false
        }
    }
    
    // Return true so that menu controller can display
    open override var canBecomeFirstResponder: Bool { return true }
    
    // Return true to show menu for given action
    // Action is in UIResponderStandardEditActions
    open override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
       
        return action == #selector(copy(_:))
    }
    
    open override func copy(_ sender: Any?) {
        print(#function)
        self.copyToBoard(text: copyValue)
    }
    var copyValue:String = ""
    private func copyToBoard(text:String){
        UIPasteboard.general.string = text
    }
}

class WLable:UILabel{
    // Return true so that menu controller can display
    override var canBecomeFirstResponder: Bool { return true }
    // Return true to show menu for given action
    // Action is in UIResponderStandardEditActions
    open override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
    
        return action == #selector(copy(_:))
    }
    
    override func copy(_ sender: Any?) {
        self.copyToBoard(text: copyValue)
    }
    var copyValue:String = ""
    private func copyToBoard(text:String){
        UIPasteboard.general.string = text
    }
    
}

extension UITextView {
    
    /// 给textView插入表情图片，比如😊
    public func insertEmotionAttributedString(emotionAttributedString:NSAttributedString) {
        let content:NSMutableAttributedString = self.attributedText.mutableCopy() as! NSMutableAttributedString;
        let location = self.selectedRange.location;
        content.insert(emotionAttributedString, at: location);
        content.addAttributes([.font:self.font,.foregroundColor:self.textColor], range: NSRange(location: location, length: emotionAttributedString.length))
        self.attributedText = content;
        let range = NSRange(location: (location + emotionAttributedString.length), length: 0)
        self.selectedRange = range;
    }
    
    
    /// 给textView插入表情的文本，比如[微笑]
    public  func insertEmotion(emotionKey:String)  {
        let content:NSMutableAttributedString = self.attributedText.mutableCopy() as! NSMutableAttributedString;
        let location = self.selectedRange.location;
        let attr = NSAttributedString(string: emotionKey, attributes: [.font:self.font,.foregroundColor:self.textColor])
        content.insert(attr, at: location)
        self.attributedText = content;
        let range = NSRange(location: (location + emotionKey.count), length: 0)
        self.selectedRange = range;
    }
    
    
    /// 删除表情
    public func deleteEmotion() ->Bool {
        ///点的是删除按钮，获得光标所在的位置
        let location = self.selectedRange.location;
        if location == 0 {return false};
        
        // 先获取前半段
        let headresult = self.text.substring(at: 0, length: location);
        if headresult.hasPrefix("]") {
            //最后一位是]
            for (i,char) in headresult.enumerated().reversed() {
                if char == "[" {
                    let  content = self.attributedText.mutableCopy() as! NSMutableAttributedString;
                    //砍掉[XXX]，重新赋值前半段
                    content.deleteCharacters(in: NSRange(location: i-1, length: -i + 1))
                    self.attributedText = content;
                    //重新设置光标位置
                    let range = NSRange(location:  headresult.count, length:0);
                    self.selectedRange = range;
                    return true
                }
            }
        }
        return false;
    }
    
    /// 转换 【】
    public  func normalText() -> String {
        let normalMutableString = self.attributedText.mutableCopy() as! NSMutableAttributedString;
        self.attributedText.enumerateAttribute(.attachment, in: NSRange(location: 0, length: self.attributedText.length), options: .reverse) { value, range, stop in
            if let attachmen = value as? BNSTextAttachment {
                let newRange = NSRange(location: range.location, length: range.length);
                normalMutableString.replaceCharacters(in: newRange, with: attachmen.displayText)
            }
        }
        return normalMutableString.string
    }
}
