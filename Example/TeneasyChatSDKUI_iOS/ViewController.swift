import UIKit
import TeneasyChatSDKUI_iOS
import TeneasyChatSDK_iOS

//class ViewController: ConsultTypeViewController  {
class ViewController: UIViewController, LineDetectDelegate  {
    lazy var supportBtn:UIButton = {
        let btn = UIButton(type: .roundedRect)
        btn.setTitle("联系客服", for: .normal)
        btn.backgroundColor = .lightText
        
        btn.setTitleColor(UIColor.black, for: .normal)
        btn.addTarget(self, action: #selector(buttonClick), for: .touchUpInside)
        return btn
    }()
    
    lazy var curLineLB: UILabel = {
        let lineLB = UILabel()
        lineLB.text = "正在检测线路。。。。"
        lineLB.textColor = .gray
        lineLB.font = UIFont.systemFont(ofSize: 15)
        lineLB.alpha = 0.15
        return lineLB
    }()
    
    lazy var settingBtn: UIButton = {
        let btn = UIButton()
        btn.setTitle("设置", for: UIControl.State.normal)
        btn.setTitleColor(.lightGray, for: UIControl.State.normal)
        btn.addTarget(self, action: #selector(settingClick), for: UIControl.Event.touchUpInside)
        return btn
    }()
    
     func initSubViews() {
         self.view.addSubview(supportBtn)
        supportBtn.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
        }
         
         self.view.addSubview(curLineLB)
         curLineLB.snp.makeConstraints { make in
             make.left.equalToSuperview().offset(12)
             make.right.equalToSuperview().offset(-12)
             
             make.bottom.equalToSuperview().offset(-80)
         }
         curLineLB.textAlignment = .center
         
        
         view.addSubview(self.settingBtn)
         self.settingBtn.snp.makeConstraints { make in
             make.top.equalTo(curLineLB.snp.bottom).offset(10)
             make.right.equalToSuperview().offset(-20)
             make.bottom.equalToSuperview().offset(-50)
         }
    }
    
    //去设置页面
    @objc func settingClick() {
        //fatalError("Crash was triggered")
        let vc = BWSettingViewController()
        vc.callBack = {
            self.lineCheck()
        }
        self.present(vc, animated: true)
    }
    
    @objc func buttonClick(){
        let vc = ConsultTypeViewController()
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initSubViews()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        //从设置页面读取配置参数，读取到后分配给这些变量：lines，cert，merchantId，userId，baseUrlImage
        //可以从后台设置页面获取，也可以从App的设置页面获取
        readConfig()
        
        //做线路检测
        lineCheck()
    }
    
    func readConfig(){
        //从配置读取线路数组
         lines = UserDefaults.standard.string(forKey: PARAM_LINES) ?? lines
        
        //从配置读取Cert
        cert = UserDefaults.standard.string(forKey: PARAM_CERT) ?? cert
        
        //从配置读取商户ID
        let a_merchantId = UserDefaults.standard.integer(forKey: PARAM_MERCHANT_ID)
        if a_merchantId > 0{
            merchantId = a_merchantId
        }
        
        //从配置读取用户ID
        let a_userId = UserDefaults.standard.integer(forKey: PARAM_USER_ID)
        if a_userId > 0{
            userId = Int32(a_userId)
        }
        
        //从配置读取图片域名
        baseUrlImage = UserDefaults.standard.string(forKey: PARAM_ImageBaseURL) ?? baseUrlImage
        
        if cert.isEmpty || merchantId == 0 || userId == 0 || lines.isEmpty || baseUrlImage.isEmpty{
            curLineLB.text = "* 请在设置页面设置好参数 *"
            return
        }
               
    }
    
    //做线路检测
    func lineCheck(){
        curLineLB.text = "正在检测线路。。。。"
        //初始化线路库
        let lineLB = LineDetectLib(lines, delegate: self, tenantId: merchantId)
        //获取线路
        lineLB.getLine()
    }
    
    public func useTheLine(line: String) {
        curLineLB.text = "当前线路：\(line)"
        domain = line;
    }
    
    public func lineError(error: TeneasyChatSDK_iOS.Result) {
        //1008表示没有可用线路，请检查线路数组和商户号
        if error.Code == 1008{
            curLineLB.text = error.Message
        }
        debugPrint(error.Message)
    }
}
