//
//  QuestionViewController.swift
//  TeneasyChatSDKUI_iOS-TeneasyChatSDKUI_iOS
//
//  Created by Xiao Fu on 2024/5/10.
//

import Foundation
import UIKit
import TeneasyChatSDK_iOS

//线路检测和选择咨询类型页面
open class ConsultTypeViewController: UIViewController, LineDetectDelegate {
    var retryTimes = 0
    //咨询类型页面
    lazy var entranceView: BWEntranceView = {
        let view = BWEntranceView()
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        return view
    }()
    
    lazy var headerView: UIView = {
        let v = UIView(frame: CGRect.zero)
        if #available(iOS 13.0, *) {
            v.backgroundColor = UIColor.tertiarySystemBackground
        } else {
            v.backgroundColor = UIColor.white
        }
        return v
    }()
    
    lazy var headerImg: UIImageView = {
        let img = UIImageView(frame: CGRect.zero)
        img.layer.cornerRadius = 25
        img.layer.masksToBounds = true
        img.image = UIImage.svgInit("com_moren")
        return img
    }()
    
    lazy var headerTitle: UILabel = {
        let v = UILabel(frame: CGRect.zero)
        v.text = "--"
        if #available(iOS 13.0, *) {
            v.textColor = UIColor.label
        } else {
            // Fallback on earlier versions
        }
        return v
    }()

    lazy var headerClose: UIButton = {
        let btn = UIButton(frame: CGRect.zero)
        btn.setImage(UIImage.svgInit("backicon", size: CGSize(width: 40, height: 40)), for: UIControl.State.normal)
        btn.addTarget(self, action: #selector(closeClick), for: UIControl.Event.touchUpInside)
        if #available(iOS 13.0, *) {
            btn.setImage(UIImage.svgInit("backicon", size: CGSize(width: 40, height: 40))?.withTintColor(UIColor.systemGray), for: UIControl.State.normal)
        }
        return btn
    }()
    
//    lazy var curLineLB: UILabel = {
//        let lineLB = UILabel()
//        lineLB.text = "正在检测线路。。。。"
//        lineLB.textColor = .gray
//        lineLB.font = UIFont.systemFont(ofSize: 15)
//        lineLB.alpha = 0.5
//        return lineLB
//    }()
//    
//    lazy var settingBtn: UIButton = {
//        let btn = UIButton()
//        btn.setTitle("Settings", for: UIControl.State.normal)
//        btn.setTitleColor(.lightGray, for: UIControl.State.normal)
//        btn.addTarget(self, action: #selector(settingClick), for: UIControl.Event.touchUpInside)
//        return btn
//    }()
    
    open override func viewDidLoad() {
        super.viewDidLoad()
//        if #available(iOS 13.0, *) {
//            self.view.backgroundColor = UIColor.systemBackground
//        } else {
//            // Fallback on earlier versions
//        }
        self.view.addSubview(entranceView)
        
        view.addSubview(headerView)
        headerView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalTo(50)
            make.top.equalToSuperview().offset(kDeviceTop)
        }
        //
//        headerView.addSubview(headerImg)
//        headerImg.snp.makeConstraints { make in
//            make.width.height.equalTo(50)
//            make.left.equalToSuperview().offset(12)
//            make.top.equalToSuperview().offset(5)
//        }

        headerView.addSubview(headerTitle)
        headerTitle.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.centerX.equalToSuperview()
            make.width.equalTo(150)
        }
        headerTitle.textAlignment = .center
        headerTitle.text = "客服"
        
        headerView.addSubview(headerClose)
        headerClose.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.centerY.equalToSuperview()
        }
        
        if #available(iOS 13.0, *) {
            entranceView.backgroundColor = UIColor.secondarySystemBackground
            view.backgroundColor = UIColor.secondarySystemBackground
            setStatusBar(backgroundColor: UIColor.tertiarySystemBackground)
        } else {
            entranceView.backgroundColor = UIColor.white
        }
        entranceView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalTo(headerView.snp.bottom).offset(12)
            make.bottom.equalToSuperview()//.offset(-82 - kDeviceBottom)
        }
        
        entranceView.callBack = { [weak self] (dataCount: Int) in
            if dataCount < 1 && (self?.retryTimes ?? 0) < 3{
                //如果失败，再做一次线路检测
                self?.lineCheck()
                self?.retryTimes += 1
            }
        }
        //咨询类型选择之后，把咨询ID作为全局变量
        entranceView.cellClick = {[weak self] (consultID: Int32) in
            let vc = KeFuViewController()
            vc.consultId = Int64(consultID)
            vc.modalPresentationStyle = .fullScreen
            self?.present(vc, animated: true)
        }
        
        //从配置读取用户ID
        xToken = UserDefaults.standard.string(forKey: PARAM_XTOKEN) ?? ""
        
        //线路检测成功之后，获取咨询类型列表
        entranceView.getEntrance()
    }
    
    @objc func closeClick() {
        dismiss(animated: true)
    }
    
    open override func viewWillAppear(_ animated: Bool) {
 
    }
    
    
    open override func viewWillDisappear(_ animated: Bool) {

    }
    
    //做线路检测
    func lineCheck(){
        //初始化线路库
        let lineLB = LineDetectLib(lines, delegate: self, tenantId: merchantId)
        //获取线路
        lineLB.getLine()
    }
    
    public func useTheLine(line: String) {
        domain = line;
        entranceView.getEntrance()
    }
    
    public func lineError(error: TeneasyChatSDK_iOS.Result) {
        if error.Code == 1008{
            //无可用线路
            self.view.makeToast(error.Message)
        }
    }
    
    func setStatusBar(backgroundColor: UIColor) {
        let statusBarFrame: CGRect
        if #available(iOS 13.0, *) {
            //statusBarFrame = view.window?.windowScene?.statusBarManager?.statusBarFrame ?? CGRect.zero
            statusBarFrame = CGRectMake(0, 0, kScreenWidth, kDeviceTop)
        } else {
            statusBarFrame = UIApplication.shared.statusBarFrame
        }
        let statusBarView = UIView(frame: statusBarFrame)
        statusBarView.backgroundColor = backgroundColor
        view.addSubview(statusBarView)
    }
}
