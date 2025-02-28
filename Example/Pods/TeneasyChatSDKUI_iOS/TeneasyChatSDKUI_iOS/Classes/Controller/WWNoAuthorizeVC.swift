//
//  WWNoAuthorizeVC.swift
//  WangWang
//
//  Created by XiaoFu on 2023/1/1.
//

import Foundation

class WWNoAuthorizeVC: UIViewController {
    var isPhoto: Bool = true
    
    lazy var systemBtn: UIButton = {
        let btn = UIButton(frame: CGRect.zero)
        btn.setTitleColor(UIColor.white, for: UIControl.State.normal)
        btn.backgroundColor = kMainColor
        btn.setTitle("前往系统设置", for: UIControl.State.normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        btn.layer.cornerRadius = 6
        btn.addTarget(self, action: #selector(doSystem), for: UIControl.Event.touchUpInside)
        return btn
    }()

    lazy var closeBtn: UIButton = {
        let btn = UIButton(frame: CGRect.zero)
        btn.setImage(UIImage(named: "zl_close", in: BundleUtil.getCurrentBundle(), compatibleWith: nil), for: UIControl.State.normal)
        btn.addTarget(self, action: #selector(doCloseBtn), for: UIControl.Event.touchUpInside)
        return btn
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.numberOfLines = 2
        label.font = UIFont.systemFont(ofSize: 18)
        return label
    }()
    
    lazy var middleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.numberOfLines = 4
        label.font = UIFont.systemFont(ofSize: 17)
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.buildView()
    }
    
    func buildView() {
        view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.94)
        view.addSubview(self.titleLabel)
        view.addSubview(self.middleLabel)
        view.addSubview(self.systemBtn)
        view.addSubview(self.closeBtn)
        
        if self.isPhoto {
            self.titleLabel.text = "无法访问相册中的照片"
            self.middleLabel.text = "你已关闭”起信“照片访问权限，建议允许访问「所有照片」"
        } else {
            self.titleLabel.text = "无法访问相机"
            self.middleLabel.text = "你已关闭”起信“相机访问权限，建议允许访问「相机」"
        }

        self.closeBtn.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(12)
            make.top.equalToSuperview().offset(kDeviceTop + 40)
        }
        self.titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-100)
        }
        self.middleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.left.equalToSuperview().offset(12)
            make.right.equalToSuperview().offset(-12)
            make.top.equalTo(self.titleLabel.snp.bottom).offset(20)
        }
        self.systemBtn.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-kDeviceBottom - 80)
            make.width.equalTo(160)
            make.height.equalTo(38)
        }
    }
    
    @objc func doCloseBtn() {
        dismiss(animated: true)
    }
    
    @objc func doSystem() {
        let url = URL(string: UIApplication.openSettingsURLString)
        if let url = url, UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url, options: [:],
                                          completionHandler: {
                                              _ in
                                          })
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }

    func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
        return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value) })
    }
}
