import UIKit
import TeneasyChatSDKUI_iOS

class ViewController: QuestionViewController  {
    
   /* lazy var supportBtn:UIButton = {
        let btn = UIButton()
        btn.setTitle("联系客服", for: .normal)
        btn.backgroundColor = .clear
        btn.setTitleColor(UIColor.blue, for: .normal)
        btn.addTarget(self, action: #selector(buttonClick), for: .touchUpInside)
        return btn
    }()
    
     func initSubViews() {
      
        
         self.view.addSubview(supportBtn)
        supportBtn.snp.makeConstraints { make in
           
            make.right.equalToSuperview().offset(-20)
            make.bottom.equalToSuperview().offset(-20)
        }
    }
    

    
    @objc func buttonClick(){
        let vc = WKeFu()
        //vc.token = "CCcQARgCIBwo6_7VjN8w.Pa47pIINpFETl5RxrpTPqLcn8RVBAWrGW_ogyzQipI475MLhNPFFPkuCNEtsYvabF9uXMKK2JhkbRdZArUK3DQ"
        //navigationController?.pushViewController(vc, animated: true)
        navigationController?.present(vc, animated: true)
    }
*/
    
    override func viewDidLoad() {
//        super.token = "COYBEAEYCSDwASju7YmY9TE.DysXYuQR8VbjQJ7ukHxtMLjD5YKNdAt_mDM3U-tGFN3-qnqjDlh8yu0qGoRXqi7pEUS-Ev8LxCDt6U4TFi5EAg&ty=103&c=111&dt=1715085123474"//XiaoFua001
        //super.token = "CAEQARjeCSBXKLK3no7pMA.4ZFT0KP1_DaEtPcdVhSyL9Q4Aolk16-bCgT6P8tm-cMOUEl-m1ygdpeIXx9iDaZbTcxEcRqW0gr6v7cuUjY2Cg"//起信
        super.viewDidLoad()
    }
}
