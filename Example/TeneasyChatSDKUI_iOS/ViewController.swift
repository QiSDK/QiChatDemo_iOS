import UIKit
import TeneasyChatSDKUI_iOS
import TeneasyChatSDK_iOS

//class ViewController: ConsultTypeViewController  {
class ViewController: UIViewController, LineDetectDelegate, GlobalMessageDelegate  {
    lazy var supportBtn:UIButton = {
        let btn = UIButton(type: .roundedRect)
        btn.setTitle("联系客服", for: .normal)
        if #available(iOS 13.0, *) {
            btn.backgroundColor = UIColor.tertiarySystemFill
        } else {
            // Fallback on earlier versions
        }
        
        btn.contentEdgeInsets = UIEdgeInsets(top: 12, left: 20, bottom: 12, right: 20)
        //btn.setTitleColor(UIColor.black, for: .normal)
        btn.addTarget(self, action: #selector(buttonClick), for: .touchUpInside)
        return btn
    }()
    
    lazy var unReadCountLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.backgroundColor = .red
        label.font = UIFont.systemFont(ofSize: 12)
        label.textAlignment = .center
        label.layer.cornerRadius = 10
        label.layer.masksToBounds = true
        //label.isHidden = true
        return label
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
        
        self.view.addSubview(unReadCountLabel)
        unReadCountLabel.snp.makeConstraints { make in
            make.bottom.equalTo(supportBtn.snp.top).offset(-5)
            make.left.equalTo(supportBtn.snp.right).offset(-5)
            make.width.height.equalTo(20)
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
             make.left.equalToSuperview().offset(20)
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
        
        globalMessageDelegate = self
        updateUnReadCount()

        if #available(iOS 13.0, *) {
            self.view.backgroundColor = UIColor.systemBackground
        } else {
            // Fallback on earlier versions
        }
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

        // 模拟宿主"调自己接口拿到 service_keyword 配置后喂进 SDK"
        loadAutoCardKeywords()

        if cert.isEmpty || merchantId == 0 || userId == 0 || lines.isEmpty || baseUrlImage.isEmpty{
            curLineLB.text = "* 请在设置页面设置好参数 *"
            return
        }

    }

    /// demo：从内置示例 JSON 读取 result[0].service_keyword 并设置到 UISDK。
    /// 真实接入时这里换成宿主自己的 HTTP 请求结果。
    func loadAutoCardKeywords() {
        let sampleJson = """
        {
          "code": "1", "message": "ok",
          "result": [
            {
              "type": "1", "questions": [],
              "service_keyword": [
                { "id": 7, "questionType": 1, "category": 4, "subject": "请选择补单类型", "content": ["充值补单","提现补单","转账补单"], "keywords": ["补单","漏单","未上分"], "weight": 100 },
                { "id": 4, "questionType": 1, "category": 2, "subject": "请选择提现相关问题", "content": ["提现未到账","提现审核中","提现限额"], "keywords": ["提现","取款","出款"], "weight": 90 },
                { "id": 1, "questionType": 1, "category": 1, "subject": "请选择要咨询的充值类型", "content": ["充值未到账","充值失败","充值问题咨询"], "keywords": ["充值","冲值","上分"], "weight": 100 },
                { "id": 5, "questionType": 2, "category": 2, "subject": "提现进度查询", "content": "提现一般在2小时内到账，节假日可能延迟", "jumpCategory": 1, "jumpUrl": "pages/Withdraw/Record", "rightImageUrl": "https://imgjy.yxlady.com/upload/img/jy_jh/20220429024059_22614.jpg", "keywords": ["提现未到账","提现没到","取款未到账"], "weight": 95 },
                { "id": 6, "questionType": 2, "category": 2, "subject": "提现失败处理指南", "content": "常见原因：1.未绑定银行卡 2.银行卡信息错误 3.未满足流水要求", "jumpCategory": 1, "jumpUrl": "pages/User/BankCard", "rightImageUrl": "https://www.bing.com/th?id=OHR.MasaiGiraffe_ROW6806132366_1920x1200.jpg&rf=LaDigue_1920x1200.jpg", "keywords": ["提现失败","提现不成功","取款失败"], "weight": 95 }
              ]
            }
          ]
        }
        """
        guard let data = sampleJson.data(using: .utf8),
              let obj = try? JSONSerialization.jsonObject(with: data),
              let root = obj as? [String: Any],
              let result = root["result"] as? [[String: Any]],
              let first = result.first,
              let list = first["service_keyword"] as? [[String: Any]] else {
            return
        }
        setAutoCardKeywords(list)
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
        UserDefaults.standard.set(line, forKey: PARAM_DOMAIN)
        debugPrint("存储domain:\(domain)")
        updateUnReadCount()
        globalMessageDelegate = self
        // 线路确定后，初始化全局ChatLib
        GlobalChatManager.shared.initializeGlobalChat()
        GlobalChatManager.shared.connectIfNeeded()
    }
    
    public func lineError(error: TeneasyChatSDK_iOS.Result) {
        //1008表示没有可用线路，请检查线路数组和商户号
        if error.Code == 1008{
            curLineLB.text = error.Message
        
            domain = ""
            //记得在这上报错误日志哦
        }
        debugPrint(error.Message)
    }
    
    // MARK: - GlobalMessageDelegate
    public func onUnReadCountChanged() {
        DispatchQueue.main.async {
            self.updateUnReadCount()
        }
    }
    
    private func updateUnReadCount() {
        let totalCount = GlobalMessageManager.shared.getTotalUnReadCount()
        
        if totalCount > 0 {
            unReadCountLabel.isHidden = false
            unReadCountLabel.text = totalCount > 99 ? "99+" : "\(totalCount)"
        } else {
            unReadCountLabel.isHidden = true
        }
        debugPrint("total unRead Count\(totalCount)")
    }
    
}
