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
        v.backgroundColor = .white
        return v
    }()
    
    lazy var imageView: WKWebView = {
        let v = WKWebView(frame: CGRect.zero)
        v.backgroundColor = titleColour
        return v
    }()
    
    lazy var headerClose: UIButton = {
        let btn = UIButton(frame: CGRect.zero)
        btn.setImage(UIImage.svgInit("backicon", size: CGSize(width: 40, height: 40)), for: UIControl.State.normal)
        btn.addTarget(self, action: #selector(closeClick), for: UIControl.Event.touchUpInside)
        return btn
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        
        view.addSubview(headerView)
        view.addSubview(imageView)
        headerView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalTo(40)
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
        //if let url = URL(string: "https://example.com/your-image.jpg") {
                   let request = URLRequest(url: url)
            imageView.load(request)
             //  }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
       
    }
}
