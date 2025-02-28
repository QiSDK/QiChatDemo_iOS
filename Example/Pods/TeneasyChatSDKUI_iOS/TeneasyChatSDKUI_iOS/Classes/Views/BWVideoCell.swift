//
//  BWVideoCell.swift
//  TeneasyChatSDKUI_iOS
//
//  Created by Xiao Fu on 2024/5/27.
//

import AVFoundation
import Kingfisher
import UIKit

class BWVideoCell: UITableViewCell {
    lazy var timeLab: UILabel = {
        let lab = UILabel()
        lab.font = UIFont.systemFont(ofSize: 13)
        lab.textColor = .black
        lab.lineBreakMode = .byTruncatingTail
        return lab
    }()

    lazy var videoBackgroundView: UIView = {
        let blackBackgroundView = UIView()
        return blackBackgroundView
    }()

    lazy var playBtn: UIButton = {
        let btn = UIButton()
        //btn.setImage(UIImage(named: "playvideo", in: BundleUtil.getCurrentBundle(), compatibleWith: nil), for: .normal)
        btn.setBackgroundImage(UIImage(named: "playvideo", in: BundleUtil.getCurrentBundle(), compatibleWith: nil), for: .normal)
        //btn.setTitle("play", for: UIControl.State.normal)
        btn.addTarget(self, action: #selector(playButtonTapped), for: .touchUpInside)
        return btn
    }()
    
    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    var playerItem: AVPlayerItem?
    
    static func cell(tableView: UITableView) -> Self {
        let cellId = "\(Self.self)"
        var cell = tableView.dequeueReusableCell(withIdentifier: cellId)
        if cell == nil {
            cell = Self(style: .default, reuseIdentifier: cellId)
        }
        
        return cell as! Self
    }
    
    @objc private func playButtonTapped() {
        self.playBtn.isHidden = true
        self.player?.play()
    }
    
    override required init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
                
        self.contentView.addSubview(self.timeLab)
        self.contentView.addSubview(self.videoBackgroundView)
        self.videoBackgroundView.addSubview(self.playBtn)
        self.playBtn.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(60)
            make.height.equalTo(60)
        }
        self.setupPlayerLayer()
    }

    var model: ChatModel? {
        didSet {
            guard let msg = model?.message else {
                return
            }
            self.timeLab.text = WTimeConvertUtil.displayLocalTime(from: msg.msgTime.date)
            let videoUrl = URL(string: "\(baseUrlImage)\(msg.video.uri)")
            print(videoUrl?.absoluteString ?? "")
            if videoUrl != nil {
                self.initVideo(videoUrl: videoUrl!)
            } else {}
        }
    }
    
    private func setupPlayerLayer() {
        playerLayer = AVPlayerLayer()
        playerLayer?.videoGravity = .resizeAspect
        if let playerLayer = playerLayer {
            self.videoBackgroundView.layer.addSublayer(playerLayer)
        }
     
        self.videoBackgroundView.bringSubviewToFront(self.playBtn)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.playerLayer?.frame = self.videoBackgroundView.bounds
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.player?.pause()
        self.playerLayer?.player = nil
    }
    
    func initVideo(videoUrl: URL) {
        self.playerLayer?.isHidden = false
        self.playBtn.isHidden = false
        playerItem = AVPlayerItem(url: videoUrl)
        self.player = AVPlayer(playerItem: playerItem)
        self.playerLayer?.player = self.player
        // Observe for the AVPlayerItemDidPlayToEndTime notification
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(playerItemDidReachEnd(notification:)),
                                               name: .AVPlayerItemDidPlayToEndTime,
                                               object: playerItem)
    }
    
    @objc private func playerItemDidReachEnd(notification: Notification) {
         print("Playback finished")
         // Add your code to handle the end of playback here
        self.playBtn.isHidden = false
     }
    
    deinit {
         NotificationCenter.default.removeObserver(self)
     }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

class BWVideoLeftCell: BWVideoCell {
    required init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.timeLab.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(12)
            make.top.equalToSuperview().offset(12)
            make.right.equalToSuperview().offset(-12)
            make.height.equalTo(20)
        }
        self.videoBackgroundView.snp.makeConstraints { make in
            make.top.equalTo(self.timeLab.snp.bottom).offset(10)
            make.left.equalToSuperview().offset(12)
            make.width.equalTo(220)
            make.height.equalTo(160)
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

class BWVideoRightCell: BWVideoCell {
    required init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.timeLab.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-12)
            make.top.equalToSuperview().offset(12)
            make.height.equalTo(20)
        }
        self.videoBackgroundView.snp.makeConstraints { make in
            make.top.equalTo(self.timeLab.snp.bottom)
            make.right.equalToSuperview().offset(-12)
            make.width.equalTo(220)
            make.height.equalTo(160)
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
