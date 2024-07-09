//
//  BWVideoCell.swift
//  TeneasyChatSDKUI_iOS
//
//  Created by Xiao Fu on 2024/5/27.
//

import AVFoundation
import Kingfisher
import UIKit

typealias BWVideoCellClickBlock = () -> ()

class BWVideoCell: UITableViewCell {
    var playBlock: BWVideoCellClickBlock?
    var gesture: UILongPressGestureRecognizer?
    var longGestCallBack: BWChatCellLongGestCallBack?
    lazy var timeLab: UILabel = {
        let lab = UILabel()
        lab.font = UIFont.systemFont(ofSize: 13)
        lab.textColor = timeColor
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
    
   
    
    lazy var iconView: UIImageView = {
        let img = UIImageView()
        img.layer.cornerRadius = iconWidth * 0.5
        img.layer.masksToBounds = true
        return img
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
//        self.playBtn.isHidden = true
//        self.player?.play()
        playBlock!()
    }
    
    override required init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
            
        self.contentView.addSubview(self.iconView)
        self.contentView.addSubview(self.timeLab)
        self.contentView.addSubview(self.videoBackgroundView)
        self.videoBackgroundView.backgroundColor = UIColor.black
        self.videoBackgroundView.addSubview(self.playBtn)
        self.playBtn.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(60)
            make.height.equalTo(60)
        }
        self.setupPlayerLayer()
        
        self.gesture = UILongPressGestureRecognizer(target: self, action: #selector(self.longGestureClick(tap:)))
        self.contentView.addGestureRecognizer(self.gesture!)
    }

    var model: ChatModel? {
        didSet {
            guard let msg = model?.message else {
                return
            }
            self.timeLab.text = msg.msgTime.date.toString(format: "yyyy-MM-dd HH:mm:ss")
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
    
    @objc func longGestureClick(tap: UILongPressGestureRecognizer) {
        self.longGestCallBack?(tap)
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
        self.player?.seek(to: CMTime.zero)
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

        self.iconView.image = UIImage.svgInit("icon_server_def2")

        self.iconView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(12)
            make.top.equalToSuperview().offset(12)
            make.width.height.equalTo(iconWidth)
        }
        self.timeLab.snp.makeConstraints { make in
            make.left.equalTo(self.iconView.snp.right).offset(16)
            make.top.equalToSuperview().offset(5)
            make.right.equalToSuperview().offset(-12)
            make.height.equalTo(20)
        }
        self.videoBackgroundView.snp.makeConstraints { make in
            make.top.equalTo(self.timeLab.snp.bottom).offset(10)
            make.left.equalTo(self.timeLab.snp.left)
            make.width.equalTo(178)
            make.height.equalTo(114)
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

class BWVideoRightCell: BWVideoCell {
    required init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.iconView.image = UIImage.svgInit("icon_server_def2")

        self.iconView.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-12)
            make.top.equalToSuperview().offset(12)
            make.width.height.equalTo(iconWidth)
        }
        self.timeLab.snp.makeConstraints { make in
            make.right.equalTo(self.iconView.snp.left).offset(-16)
            make.top.equalToSuperview().offset(5)
            make.height.equalTo(20)
        }
        self.videoBackgroundView.snp.makeConstraints { make in
            make.top.equalTo(self.timeLab.snp.bottom)
            make.right.equalTo(self.timeLab.snp.right)
            make.width.equalTo(178)
            make.height.equalTo(114)
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
