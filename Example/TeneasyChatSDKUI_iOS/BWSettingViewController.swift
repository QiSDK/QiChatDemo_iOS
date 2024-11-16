//
//  BWSettingViewController.swift
//  Alamofire
//
//  Created by Xiao Fu on 2024/5/17.
//
import SnapKit
import UIKit
import TeneasyChatSDKUI_iOS

typealias DissmissedCallback = () -> ()
class BWSettingViewController: UIViewController {
    private let linesTextField = UITextView()
    private let certTextField = UITextView()
    private let merchantIdTextField = UITextView()
    private let userIdTextField = UITextView()
    private let userNameTextField = UITextView()
    private let imgBaseUrlTextField = UITextView()
    private let maxSessionMinsTextField = UITextView()
    private let userLevelTextField = UITextView()
    
    private let submitButton = UIButton(type: .system)
    
    var callBack: DissmissedCallback?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
       //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
       //tap.cancelsTouchesInView = false
       view.addGestureRecognizer(tap)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if callBack != nil{
            callBack!()
        }
    }
    
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    private func setupUI() {
        if #available(iOS 13.0, *) {
            view.backgroundColor = UIColor.secondarySystemBackground
        } else {
            // Fallback on earlier versions
        }
        
        let labels = ["lines", "cert", "merchantId", "userId", "userName", "imageBaseUrl", "maxSessionMins", "userLevel"]
        let textFields = [linesTextField, certTextField, merchantIdTextField, userIdTextField, userNameTextField, imgBaseUrlTextField, maxSessionMinsTextField, userLevelTextField]
                
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
                    make.top.equalTo(previousView.snp.bottom).offset(10)
                } else {
                    make.top.equalToSuperview().offset(10)
                }
                make.left.equalToSuperview().offset(20)
                make.right.equalToSuperview().offset(-20)
            }
            
            textField.layer.borderWidth = 2.0
            textField.layer.borderColor = UIColor.purple.cgColor
            
            textField.snp.makeConstraints { make in
                make.top.equalTo(label.snp.bottom).offset(5)
                make.left.equalTo(label)
                make.right.equalTo(label)
                make.height.equalTo(35)
            }
            
            previousView = textField
        }
        
        submitButton.setTitle("确定", for: .normal)
        submitButton.addTarget(self, action: #selector(submitButtonTapped), for: .touchUpInside)
        view.addSubview(submitButton)
        
        submitButton.snp.makeConstraints { make in
            make.top.equalTo(userLevelTextField.snp.bottom).offset(20)
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
        let a_imgUrl = UserDefaults.standard.string(forKey: PARAM_ImageBaseURL) ?? ""
        let a_userName = UserDefaults.standard.string(forKey: PARAM_USERNAME) ?? ""
        let a_maxSessionMins = UserDefaults.standard.integer(forKey: PARAM_MAXSESSIONMINS)
        let a_userLevel = UserDefaults.standard.integer(forKey: PARAM_USERLEVEL)
        
        
        linesTextField.text = a_lines.isEmpty ? lines:a_lines
        certTextField.text = a_cert.isEmpty ? cert:a_cert
        merchantIdTextField.text = "\(a_merchantId > 0 ? a_merchantId:merchantId)"
        userIdTextField.text = "\(a_userId > 0 ? Int32(a_userId):userId)"
        userNameTextField.text = a_userName.isEmpty ? userName: a_userName
        imgBaseUrlTextField.text = a_imgUrl.isEmpty ? baseUrlImage:a_imgUrl
        maxSessionMinsTextField.text = "\(a_maxSessionMins > 0 ? a_maxSessionMins:maxSessionMinus)"
        
        userLevelTextField.text =  "\(a_userLevel > 0 ? a_userLevel:userLevel)"
    }
    
    @objc private func submitButtonTapped() {
         lines = (linesTextField.text ?? "").trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
         cert = (certTextField.text ?? "").trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        merchantId = Int((merchantIdTextField.text ?? "0").trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)) ?? 0
         userId = Int32((userIdTextField.text ?? "0").trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)) ?? 0
        baseUrlImage = imgBaseUrlTextField.text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        userName = userNameTextField.text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        maxSessionMinus = Int((maxSessionMinsTextField.text ?? "1992883").trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)) ?? 0
        userLevel = Int((userLevelTextField.text ?? "0").trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)) ?? 0

        UserDefaults.standard.set(lines, forKey: PARAM_LINES)
        UserDefaults.standard.set(cert.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines), forKey: PARAM_CERT)
        UserDefaults.standard.set(merchantId, forKey: PARAM_MERCHANT_ID)
        UserDefaults.standard.set(userId, forKey: PARAM_USER_ID)
        UserDefaults.standard.set("", forKey: PARAM_XTOKEN)
        UserDefaults.standard.set(baseUrlImage, forKey: PARAM_ImageBaseURL)
        UserDefaults.standard.set(userName, forKey: PARAM_USERNAME)
        UserDefaults.standard.set(maxSessionMinus, forKey: PARAM_MAXSESSIONMINS)
        UserDefaults.standard.set(userLevel, forKey: PARAM_USERLEVEL)
        
        dismiss(animated: true)
    }
}
