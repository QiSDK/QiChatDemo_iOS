//
//  FullVideoViewController.swift
//  TeneasyChatSDKUI_iOS
//
//  Created by Xuefeng on 9/7/24.
//

import Foundation
class KeFuImageViewController: UIViewController {
    lazy var headerView: UIView = {
        let v = UIView(frame: CGRect.zero)
        if #available(iOS 13.0, *) {
            v.backgroundColor = UIColor.tertiarySystemBackground
        } else {
            // Fallback on earlier versions
        }
        return v
    }()
    
    lazy var imageView: UIImageView = {
        let v = UIImageView(frame: CGRect.zero)
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

    func configure(with url: URL) {
        self.imageView.kf.setImage(with: url)
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
