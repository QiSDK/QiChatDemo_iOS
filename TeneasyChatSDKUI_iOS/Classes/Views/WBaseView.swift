//
//  BWBaseView.swift
//  ProgramIOS
//
//  Created by laoge on 2/6/2022.
//

import UIKit

protocol WBaseViewProtocol {
    func initConfig();/// 初始配置
    func initSubViews();/// 布局控件
    func initBindModel();/// 事件绑定处理
}

protocol WBaseViewDelegate:AnyObject {
    ///事件处理处理
    func buttonClick(index:Int,other:Any?)
}

class WBaseView: UIView,WBaseViewProtocol {
    weak var delegate:WBaseViewDelegate?
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = chatBackColor
        initConfig();
        initSubViews();
        initBindModel();
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 初始配置
    func initConfig() {}
    /// 布局
    func initSubViews() {}
    /// 事件绑定
    func initBindModel() {}
    /// 按钮方法
    @objc func buttonClick(sender:UIButton){}
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}


class WEmptyBaseView:UIView,WBaseViewProtocol {
    override init(frame: CGRect) {
        super.init(frame: frame);
        initConfig();
        initSubViews()
        initBindModel();
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initConfig() {}
    
    func initSubViews() {}
    
    func initBindModel() {}

}
