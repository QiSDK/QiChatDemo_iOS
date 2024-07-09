//
//  KeFuVideoPlayerViewController.swift
//  TeneasyChatSDKUI_iOS-TeneasyChatSDKUI_iOS
//
//  Created by Xiao Fu on 2024/5/29.
//

import AVFoundation
import AVKit
import UIKit

class KeFuVideoPlayerViewController: UIViewController {
    var player: AVPlayer?
    var playerViewController: AVPlayerViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black

        playerViewController = AVPlayerViewController()
        if let playerViewController = playerViewController {
            playerViewController.player = player
            playerViewController.view.frame = view.bounds
            playerViewController.showsPlaybackControls = true
            addChild(playerViewController)
            view.addSubview(playerViewController.view)
            playerViewController.didMove(toParent: self)
        }

//        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
//        view.addGestureRecognizer(tapGestureRecognizer)
    }

//    @objc func handleTap() {
//        dismiss(animated: false, completion: nil)
//    }

    func configure(with url: URL) {
        player = AVPlayer(url: url)
        playerViewController?.player = player
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        player?.play()
    }
}
