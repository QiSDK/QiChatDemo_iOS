//
//  BWSettingViewController.swift
//  Alamofire
//
//  Created by Xiao Fu on 2024/5/17.
//
import SnapKit
import UIKit

typealias DissmissedCallback = () -> ()
class BWSettingViewController: UIViewController {
    private let linesTextField = UITextView()
    private let certTextField = UITextView()
    private let merchantIdTextField = UITextView()
    private let userIdTextField = UITextView()
    private let submitButton = UIButton(type: .system)
    
    var callBack: DissmissedCallback?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if callBack != nil{
            callBack!()
        }
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        let labels = ["lines", "cert", "merchantId", "userId"]
        let textFields = [linesTextField, certTextField, merchantIdTextField, userIdTextField]
                
        var previousView: UIView?
                
        for (index, labelName) in labels.enumerated() {
            let label = UILabel()
            label.text = labelName
            view.addSubview(label)
            
            let textField = textFields[index]
            //textField.borderStyle = .roundedRect
            view.addSubview(textField)
            
            label.snp.makeConstraints { make in
                if let previousView = previousView {
                    make.top.equalTo(previousView.snp.bottom).offset(20)
                } else {
                    make.top.equalToSuperview().offset(100)
                }
                make.left.equalToSuperview().offset(20)
                make.right.equalToSuperview().offset(-20)
            }
            
            textField.backgroundColor = UIColor.cyan
            
            textField.snp.makeConstraints { make in
                make.top.equalTo(label.snp.bottom).offset(5)
                make.left.equalTo(label)
                make.right.equalTo(label)
                make.height.equalTo(50)
            }
            
            previousView = textField
        }
        
        submitButton.setTitle("确定", for: .normal)
        submitButton.addTarget(self, action: #selector(submitButtonTapped), for: .touchUpInside)
        view.addSubview(submitButton)
        
        submitButton.snp.makeConstraints { make in
            make.top.equalTo(userIdTextField.snp.bottom).offset(40)
            make.centerX.equalToSuperview()
            make.width.equalTo(100)
            make.height.equalTo(50)
        }
        
        loadUserDefaults()
    }

    private func loadUserDefaults() {
        let a_lines = UserDefaults.standard.string(forKey: PARAM_LINES) ?? ""
        let a_cert = UserDefaults.standard.string(forKey: PARAM_CERT) ?? ""
        let a_merchantId = UserDefaults.standard.integer(forKey: PARAM_MERCHANT_ID)
        let a_userId = UserDefaults.standard.integer(forKey: PARAM_USER_ID)
        linesTextField.text = a_lines.isEmpty ? lines:a_lines
        certTextField.text = a_cert.isEmpty ? cert:a_cert
        merchantIdTextField.text = "\(a_merchantId > 0 ? a_merchantId:merchantId)"
        userIdTextField.text = "\(a_userId > 0 ? Int32(a_userId):userId)"
    }
    
    @objc private func submitButtonTapped() {
        let lines = linesTextField.text ?? ""
        let cert = certTextField.text ?? ""
        let merchantId = Int(merchantIdTextField.text ?? "0")
        let userId = Int(userIdTextField.text ?? "0")
        
        UserDefaults.standard.set(lines, forKey: PARAM_LINES)
        UserDefaults.standard.set(cert, forKey: PARAM_CERT)
        UserDefaults.standard.set(merchantId, forKey: PARAM_MERCHANT_ID)
        UserDefaults.standard.set(userId, forKey: PARAM_USER_ID)
        UserDefaults.standard.set("", forKey: PARAM_XTOKEN)
        
        
        dismiss(animated: true)
//        let alert = UIAlertController(title: "保存成功", message: "您的信息已保存。", preferredStyle: .alert)
//        alert.addAction(UIAlertAction(title: "确定", style: .default, handler: nil))
//        present(alert, animated: true, completion: nil)
    }
}
