//
//  PopView.swift
//  TestSwift
//
//  Created by lyj on 16/5/7.
/*
    GitHub：https://github.com/TangledHusky/SwiftPopMenu
 
    功能：
    只需要传入菜单箭头点位置、菜单宽度、数据源即可。
 
    1、支持任意点弹出（点是基于整个屏幕位置）
    2、会根据点位置自动计算菜单位置
    3、背景色、文字等支持自定义设置
    4、菜单最大宽度=屏幕-边距    最大高度=屏幕高度一半
 */

import UIKit

protocol SwiftPopMenuDelegate: NSObjectProtocol {
    func swiftPopMenuDidSelectIndex(index: Int)
}

public enum SwiftPopMenuConfigure {
    case PopMenuTextFont(UIFont) // 菜单文字字体
    case PopMenuTextColor(UIColor) // 菜单文字颜色
    case PopMenuBackgroudColor(UIColor) // 菜单背景色
    case popMenuCornorRadius(CGFloat) // 菜单圆角
    case popMenuItemHeight(CGFloat) // 菜单行高度
    case popMenuSplitLineColor(UIColor) // 菜单分割线颜色
    case popMenuIconLeftMargin(CGFloat) // icon左间距
    case popMenuMargin(CGFloat) // 菜单与屏幕边距
    case popMenuAlpha(CGFloat) // 菜单背景透明度
    case popMenuIsIconRight(Bool) // icon在右 文字在做
    case popMenuNoPoint(Bool) // 不要三角
}

public class SwiftPopMenu: UIView {
    // delegate
    weak var delegate: SwiftPopMenuDelegate?
    // block
    public var didSelectMenuBlock: ((_ index: Int, _ name: String) -> Void)?
    
    let KScrW: CGFloat = UIScreen.main.bounds.size.width
    let KScrH: CGFloat = UIScreen.main.bounds.size.height
    
    // ／*  -----------------------  外部参数 通过configure设置 ---------------------------- *／
    // 区域外背景透明度
    private var popMenuOutAlpha: CGFloat = 0.01
    // 背景色
    private var popMenuBgColor: UIColor = .init(red: 76/255.0, green: 76/255.0, blue: 76/255.0, alpha: 1)
    // 圆角弧度
    private var popMenuCornorRadius: CGFloat = 6
    // 文字颜色
    private var popMenuTextColor: UIColor = .white
    // 字体大小等
    private var popMenuTextFont: UIFont = UIFont.systemFont(ofSize: 13)
    // 菜单高度
    private var popMenuItemHeight: CGFloat = 64
    // 菜单分割线颜色
    private var popMenuSplitLineColor: UIColor = .init(red: 222/255.0, green: 222/255.0, blue: 222/255.0, alpha: 0.5)
    // icon左间距 右也如此
    private var popMenuIconLeftMargin: CGFloat = 0.0
    // 菜单与屏幕边距
    private var popMenuMargin: CGFloat = 20
    // icon在右
    private var isIconRight: Bool = false
    /// 没指向
    private var isNoPoint: Bool = false
    /// 箭头在上再下
    private var updown: Int = 1
    // ／*  -----------------------  外部参数 over------------------------------------------ *／
    
    private var arrowPoint: CGPoint = .zero // 小箭头位置
    private var arrowViewWidth: CGFloat = 15 // 三角箭头宽
    private var arrowViewHeight: CGFloat = 10 // 三角箭头高
    private var popData: [(icon: String, title: String)]! // 数据源
    
    static let cellID: String = "SwiftPopMenuCellID"
    private var myFrame: CGRect! // tableview  frame
    private var arrowView: UIView!
    
    var collecttionView: UICollectionView!
    
    ///   初始化菜单
    ///
    /// - Parameters:
    ///   - menuWidth: 菜单宽度
    ///   - arrow: 箭头位置是popmenu相对整个屏幕的位置
    ///   - datas: 数据源，icon允许传空，数据源没数据，不会显示菜单
    ///   - configure: 配置信息，可不传
    init(menuWidth: CGFloat, arrow: CGPoint, datas: [(icon: String, title: String)], configures: [SwiftPopMenuConfigure] = [], upDown: Int) {
        super.init(frame: UIScreen.main.bounds)
        frame = UIScreen.main.bounds
        // 读取配置
        configures.forEach { config in
            switch config {
                case let .PopMenuTextFont(value):
                    popMenuTextFont = value
                case let .PopMenuTextColor(value):
                    popMenuTextColor = value
                case let .PopMenuBackgroudColor(value):
                    popMenuBgColor = value
                case let .popMenuCornorRadius(value):
                    popMenuCornorRadius = value
                case let .popMenuItemHeight(value):
                    popMenuItemHeight = value
                case let .popMenuSplitLineColor(value):
                    popMenuSplitLineColor = value
                case let .popMenuIconLeftMargin(value):
                    popMenuIconLeftMargin = value
                case let .popMenuMargin(value):
                    popMenuMargin = value
                case let .popMenuAlpha(value):
                    popMenuOutAlpha = value
                case let .popMenuIsIconRight(value):
                    isIconRight = value
                case .popMenuNoPoint:
                    if upDown == 2 {
                        isNoPoint = true
                    } else {
                        isNoPoint = false
                    }
                    
                default:
                    break
            }
        }
        updown = upDown
        popData = datas
        // 设置myFrame size  ,original会在后面计算
        var num = 0
        if popData.count > 10 {
            num = 3
        } else if popData.count > 5 {
            num = 2
        } else {
            num = 1
        }
        myFrame = CGRect(x: 0, y: 0, width: menuWidth, height: popMenuItemHeight * CGFloat(num)+(isNoPoint ?10.0 : 0.0))
//        myFrame.size.height = min(KScrH/2, myFrame.height)
//        myFrame.size.width = min(KScrW-popMenuMargin*2, myFrame.width)
        
        // 设置肩头，与屏幕间隔10
        arrowPoint = arrow
        arrowPoint.x = max(popMenuMargin, min(arrowPoint.x, KScrW-popMenuMargin))
    }
    
    @available(*, unavailable)
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initViews() {
        backgroundColor = UIColor.black.withAlphaComponent(popMenuOutAlpha)
        myFrame.origin = arrowPoint
        let arrowPs = getArrowPoints()
        myFrame.origin = arrowPs.3
        // 箭头
        if !isNoPoint {
            let isarrowUP = arrowPs.4
            arrowView = UIView(frame: CGRect(x: myFrame.origin.x, y: isarrowUP ? myFrame.origin.y-arrowViewHeight : myFrame.origin.y+myFrame.height, width: myFrame.width, height: arrowViewHeight))
            let layer = CAShapeLayer()
            let path = UIBezierPath()
            path.move(to: arrowPs.0)
            path.addLine(to: arrowPs.1)
            path.addLine(to: arrowPs.2)
            layer.path = path.cgPath
            layer.fillColor = popMenuBgColor.cgColor
            arrowView.layer.addSublayer(layer)
            addSubview(arrowView)
        }
        
        let layout = UICollectionViewFlowLayout()
        collecttionView = UICollectionView(frame: CGRect(x: myFrame.origin.x, y: myFrame.origin.y, width: myFrame.width, height: myFrame.height), collectionViewLayout: layout)
        // view.isScrollEnabled = false
        collecttionView.register(SwiftPopMenuCell.self, forCellWithReuseIdentifier: "SwiftPopMenuCell")
        collecttionView.backgroundColor = popMenuBgColor
        collecttionView.layer.cornerRadius = popMenuCornorRadius
        collecttionView.layer.masksToBounds = true
        collecttionView.delegate = self
        collecttionView.dataSource = self
        collecttionView.bounces = false
        layout.minimumInteritemSpacing = 0.0
        layout.minimumLineSpacing = 0.0
        UIView.animate(withDuration: 0.3) {
            self.addSubview(self.collecttionView)
        }
    }
   
    /// 计算箭头位置
    ///
    /// - Returns: (三角箭头顶，三角箭头左，三角箭头右，tableview 原点，是否箭头朝上)
    func getArrowPoints() -> (CGPoint, CGPoint, CGPoint, CGPoint, Bool) {
        if arrowPoint.x <= popMenuMargin {
            arrowPoint.x = popMenuMargin
        }
        if arrowPoint.x >= KScrW-popMenuMargin {
            arrowPoint.x = KScrW-popMenuMargin
        }
        var originalPoint = CGPoint.zero
        
        // 箭头中间距离左边距离
        var arrowMargin: CGFloat = popMenuMargin
        if arrowPoint.x < KScrW/2 {
            if arrowPoint.x > myFrame.width/2 {
                arrowMargin = myFrame.width/2
                originalPoint = CGPoint(x: arrowPoint.x-myFrame.width/2, y: arrowPoint.y+arrowViewHeight)
            } else {
                arrowMargin = arrowPoint.x-popMenuMargin
                originalPoint = CGPoint(x: popMenuMargin, y: arrowPoint.y+arrowViewHeight)
            }
//
        } else {
//
            if (KScrW-arrowPoint.x) < myFrame.width/2 {
                arrowMargin = (myFrame.width-KScrW+arrowPoint.x)
                originalPoint = CGPoint(x: KScrW-popMenuMargin-myFrame.width, y: arrowPoint.y+arrowViewHeight)
//
//
            } else {
                arrowMargin = myFrame.width/2
                originalPoint = CGPoint(x: arrowPoint.x-myFrame.width/2, y: arrowPoint.y+arrowViewHeight)
            }
        }
        
        // 箭头朝上
        if updown == 1 {
            return (CGPoint(x: arrowMargin, y: 0), CGPoint(x: arrowMargin-arrowViewWidth/2, y: arrowViewHeight), CGPoint(x: arrowMargin+arrowViewWidth/2, y: arrowViewHeight), originalPoint, true)
            
        } else if updown == 0 { // 箭头朝下
//            originalPoint.y = arrowPoint.y-myFrame.height-arrowViewHeight-20
            
            return (CGPoint(x: arrowMargin, y: arrowViewHeight), CGPoint(x: arrowMargin-arrowViewWidth/2, y: 0), CGPoint(x: arrowMargin+arrowViewWidth/2, y: 0), originalPoint, false)
        } else {
            return (CGPoint(x: arrowMargin, y: arrowViewHeight), CGPoint(x: arrowMargin-arrowViewWidth/2, y: 0), CGPoint(x: arrowMargin+arrowViewWidth/2, y: 0), originalPoint, false)
        }
    }
}

// MARK: - 页面显示、隐藏

public extension SwiftPopMenu {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if touches.first?.view != collecttionView {
            dismiss()
        }
    }
    
    func show() {
        if popData.isEmpty {
            return
        }
        initViews()
        UIApplication.shared.keyWindow?.addSubview(self)
    }
    
    func dismiss() {
        removeFromSuperview()
    }

    internal static func defaultConfig() -> [SwiftPopMenuConfigure] {
        var config: [SwiftPopMenuConfigure]
        config = [
            .PopMenuTextColor(.white),
            .popMenuItemHeight(64),
            .PopMenuTextFont(UIFont.systemFont(ofSize: 13)),
            .popMenuIsIconRight(false),
            .popMenuNoPoint(false),
            .popMenuCornorRadius(10)
        ]
        return config
    }
}

// MARK: - UITableViewDataSource,UITableViewDelegate

extension SwiftPopMenu: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
//    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return 1
//    }
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return popData.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if popData.count > indexPath.row {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SwiftPopMenuCell", for: indexPath) as! SwiftPopMenuCell
            let model = popData[indexPath.row]
            if indexPath.row == popData.count-1 {
                cell.fill(iconName: model.icon, title: model.title, islast: true)
            } else {
                cell.fill(iconName: model.icon, title: model.title)
            }
            return cell
        }
        
        return UICollectionViewCell()
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 60, height: 64)
    }

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if delegate != nil {
            delegate?.swiftPopMenuDidSelectIndex(index: indexPath.row)
        }
        let model = popData[indexPath.row]
        if didSelectMenuBlock != nil {
            didSelectMenuBlock!(indexPath.row, model.title)
        }
        dismiss()
    }
}

/// UITableViewCell
class SwiftPopMenuCell: UICollectionViewCell {
    var iconImage: UIImageView!
    var lblTitle: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clear
        
        iconImage = UIImageView()
        contentView.addSubview(iconImage)
        
        lblTitle = UILabel()
        lblTitle.textColor = .white
        lblTitle.font = UIFont.systemFont(ofSize: 13)
        lblTitle.textAlignment = .center
        contentView.addSubview(lblTitle)
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func fill(iconName: String, title: String, islast: Bool = false) {
        iconImage.image = UIImage.svgInit(iconName)
        lblTitle.text = title
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        iconImage.frame = CGRect(x: 21, y: 13, width: 20, height: 20)
        lblTitle.frame = CGRect(x: 1, y: 35, width: 59, height: 20)
    }
}
