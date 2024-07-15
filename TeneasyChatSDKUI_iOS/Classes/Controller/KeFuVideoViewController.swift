//
//  FullVideoViewController.swift
//  TeneasyChatSDKUI_iOS
//
//  Created by Xuefeng on 9/7/24.
//

import Foundation
import AVKit
class KeFuVideoViewController: UIViewController {
    var player: AVPlayer?
    var playerViewController: AVPlayerViewController?
    
    lazy var headerView: UIView = {
        let v = UIView(frame: CGRect.zero)
        v.backgroundColor = .white
        return v
    }()
    
    lazy var headerTitle: UILabel = {
        let v = UILabel(frame: CGRect.zero)
        v.text = "--"
        v.textColor = UIColor.black
        return v
    }()
    
    lazy var playerView: UIView = {
        let v = UIView(frame: CGRect.zero)
        v.backgroundColor = .white
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
        
        view.addSubview(playerView)
        playerView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.top.equalTo(headerView.snp.bottom)
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        playerViewController = AVPlayerViewController()
        if let playerViewController = playerViewController {
            playerViewController.player = player
            playerViewController.view.frame = playerView.bounds
            //playerViewController.view.frame = CGRect(x: 0, y: 0, width: view.width, height: view.height - 40)
            playerViewController.showsPlaybackControls = true
            addChild(playerViewController)
            playerView.addSubview(playerViewController.view)
            playerViewController.didMove(toParent: self)
        }
    }

    @objc func closeClick() {
        dismiss(animated: false, completion: nil)
    }

    func configure(with url: URL, workerName: String) {
        player = AVPlayer(url: url)
        headerTitle.text = workerName
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        player?.play()
    }
}
