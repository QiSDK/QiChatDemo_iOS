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

    public func useTheLine(line: String) {
        curLineLB.text = "当前线路：\(line)"
        domain = line;
        
        //线路检测成功之后，获取咨询类型列表
        entranceView.getEntrance()
    }
    
    public func lineError(error: TeneasyChatSDK_iOS.Result) {
        //1008表示没有可用线路，请检查线路数组和商户号
        if error.Code == 1008{
            curLineLB.text = error.Message
        }
        debugPrint(error.Message)
    }
    
    //咨询类型页面
    lazy var entranceView: BWEntranceView = {
        let view = BWEntranceView()
        view.backgroundColor = UIColor.white
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        return view
    }()
    
    lazy var headerView: UIView = {
        let v = UIView(frame: CGRect.zero)
        v.backgroundColor = .white
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
        v.textColor = UIColor.black
        return v
    }()

    lazy var headerClose: UIButton = {
        let btn = UIButton(frame: CGRect.zero)
        btn.setImage(UIImage.svgInit("backicon", size: CGSize(width: 40, height: 40)), for: UIControl.State.normal)
        btn.addTarget(self, action: #selector(closeClick), for: UIControl.Event.touchUpInside)
        return btn
    }()
    
    lazy var curLineLB: UILabel = {
        let lineLB = UILabel()
        lineLB.text = "正在检测线路。。。。"
        lineLB.textColor = .gray
        lineLB.font = UIFont.systemFont(ofSize: 15)
        lineLB.alpha = 0.5
        return lineLB
    }()
    
    lazy var settingBtn: UIButton = {
        let btn = UIButton()
        btn.setTitle("Settings", for: UIControl.State.normal)
        btn.setTitleColor(.lightGray, for: UIControl.State.normal)
        btn.addTarget(self, action: #selector(settingClick), for: UIControl.Event.touchUpInside)
        return btn
    }()
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.view.addSubview(entranceView)
        
        view.addSubview(headerView)
        headerView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalTo(40)
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
        
        entranceView.backgroundColor = .groupTableViewBackground
        entranceView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalTo(headerView.snp.bottom).offset(12)
            make.bottom.equalToSuperview().offset(-82 - kDeviceBottom)
        }
        
        self.view.addSubview(curLineLB)
        curLineLB.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(12)
            make.right.equalToSuperview().offset(-12)
            
            make.top.equalTo(entranceView.snp.bottom).offset(10)
        }
        curLineLB.textAlignment = .center
        
        entranceView.callBack = { (dataCount: Int) in
        }
        //咨询类型选择之后，把咨询ID作为全局变量
        entranceView.cellClick = {[weak self] (consultID: Int32) in
            let vc = KeFuViewController()
            vc.consultId = Int64(consultID)
            vc.modalPresentationStyle = .fullScreen
            self?.present(vc, animated: true)
        }
        
        view.addSubview(self.settingBtn)
        self.settingBtn.snp.makeConstraints { make in
            make.top.equalTo(curLineLB.snp.bottom).offset(10)
            make.right.equalToSuperview().offset(-20)
        }
        
    }
    
    @objc func closeClick() {
        dismiss(animated: true)
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        //确保每次来到这个页面都做一次线路检测
        lineCheck()
    }
    
    
    open override func viewWillDisappear(_ animated: Bool) {

    }
    
    //去设置页面
    @objc func settingClick() {
        let vc = BWSettingViewController()
        vc.callBack = {
            self.lineCheck()
        }
        self.present(vc, animated: true)
    }
    
    //做线路检测
    func lineCheck(){
        curLineLB.text = "正在检测线路。。。。"
        
        //从配置读取线路数组
        lines = UserDefaults.standard.string(forKey: PARAM_LINES) ?? lines
        
        //从配置读取Cert
        cert = UserDefaults.standard.string(forKey: PARAM_CERT) ?? cert
        
        //从配置读取商户ID
        let a_merchantId = UserDefaults.standard.integer(forKey: PARAM_MERCHANT_ID)
        if a_merchantId > 0{
            merchantId = a_merchantId
        }
        
        //从配置读取用户ID
        let a_userId = UserDefaults.standard.integer(forKey: PARAM_USER_ID)
        if a_userId > 0{
            userId = Int32(a_userId)
        }
        
        //从配置读取图片域名
        baseUrlImage = UserDefaults.standard.string(forKey: PARAM_ImageBaseURL) ?? baseUrlImage
        
        if cert.isEmpty || merchantId == 0 || userId == 0 || lines.isEmpty || baseUrlImage.isEmpty{
            curLineLB.text = "* 请在设置页面设置好参数 *"
            return
        }
        
        //从配置读取用户ID
        xToken = UserDefaults.standard.string(forKey: PARAM_XTOKEN) ?? ""
        
        //初始化线路库
        let lineLB = LineDetectLib(lines, delegate: self, tenantId: merchantId)
        //获取线路
        lineLB.getLine()
    }
}
