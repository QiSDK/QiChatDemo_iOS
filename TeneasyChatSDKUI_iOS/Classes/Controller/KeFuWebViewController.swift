//
//  FullVideoViewController.swift
//  TeneasyChatSDKUI_iOS
//
//  Created by Xuefeng on 9/7/24.
//

import Foundation
import WebKit

class KeFuWebViewController: UIViewController {
    lazy var headerView: UIView = {
        let v = UIView(frame: CGRect.zero)
        if #available(iOS 13.0, *) {
            v.backgroundColor = UIColor.tertiarySystemBackground
        } else {
            // Fallback on earlier versions
        }
        return v
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
    
    lazy var imageView: WKWebView = {
        let v = WKWebView(frame: CGRect.zero)
        if #available(iOS 13.0, *) {
            v.backgroundColor = UIColor.systemBackground
        } else {
            // Fallback on earlier versions
        }
        return v
    }()
    
    lazy var headerClose: UIButton = {
        let btn = UIButton(frame: CGRect.zero)
        btn.setImage(UIImage.svgInit("backicon", size: CGSize(width: 40, height: 40)), for: UIControl.State.normal)
        if #available(iOS 13.0, *) {
            btn.setImage(UIImage.svgInit("backicon", size: CGSize(width: 40, height: 40))?.withTintColor(UIColor.systemGray), for: UIControl.State.normal)
        }
        btn.addTarget(self, action: #selector(closeClick), for: UIControl.Event.touchUpInside)
        return btn
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            self.view.backgroundColor = UIColor.secondarySystemBackground
            setStatusBar(backgroundColor: UIColor.tertiarySystemBackground)
        } else {
            // Fallback on earlier versions
        }
        
        view.addSubview(headerView)
        view.addSubview(imageView)
        headerView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalTo(60)
            make.top.equalToSuperview().offset(kDeviceTop)
        }
        
        headerView.addSubview(headerClose)
        headerClose.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.centerY.equalToSuperview()
        }
        
        headerView.addSubview(headerTitle)
        headerTitle.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.centerX.equalToSuperview()
            make.width.equalTo(260)
        }
        headerTitle.textAlignment = .center

        imageView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
            make.top.equalTo(headerView.snp.bottom)
        }
        
        imageView.contentMode = .scaleAspectFill
    }

    @objc func closeClick() {
        dismiss(animated: false, completion: nil)
    }

    func configure(with url: URL, workerName: String) {
        //if let url = URL(string: "https://example.com/your-image.jpg") {
                   let request = URLRequest(url: url)
            imageView.load(request)
             //  }
        headerTitle.text = workerName
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
       
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
