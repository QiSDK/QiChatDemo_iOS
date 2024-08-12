//
//  BWQuestionView.swift
//  TeneasyChatSDKUI_iOS
//
//  Created by Xiao Fu on 2024/5/8.
//

import Foundation

typealias BWQuestionViewHeightCallback = (Double) -> ()
typealias BWQuestionViewCellClickCallback = (QA) -> ()

class BWQAView: UIView {
    var heightCallback: BWQuestionViewHeightCallback?
    var qaCellClick: BWQuestionViewCellClickCallback?
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        if #available(iOS 13.0, *) {
            label.textColor = UIColor.label
        } else {
            // Fallback on earlier versions
        }
        return label
    }()

    lazy var tableView: UITableView = {
        let view = UITableView(frame: CGRect.zero, style: UITableView.Style.grouped)
        view.delegate = self
        view.dataSource = self
        view.separatorStyle = .none
        view.register(BWQuestionSectionHeader.self, forHeaderFooterViewReuseIdentifier: "BWQuestionSectionHeader")
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupUI()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupUI() {
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(12)
            make.right.equalToSuperview().offset(-5)
            make.height.equalTo(25).priority(.low)
            make.top.equalToSuperview().offset(10)
        }

        addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(self.titleLabel.snp.bottom)
            make.bottom.equalToSuperview().offset(8)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
        }
        tableView.reloadData()
        if #available(iOS 13.0, *) {
            tableView.backgroundColor = UIColor.systemBackground
            self.backgroundColor = UIColor.systemBackground
        } else {
            // Fallback on earlier versions
        }

        isHidden = true
    }

    var sectionList: [QA] = []

    func setup(model: QuestionModel) {
        sectionList = model.autoReplyItem?.qa ?? []
        titleLabel.text = model.autoReplyItem?.title
        updateTableViewHeight()
    }
}

extension BWQAView: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        sectionList.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        sectionList[section].myExpanded == true ? (sectionList[section].related?.count ?? 0) : 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = BWAutoQuestionCell.cell(tableView: tableView)
        let model: QA? = sectionList[indexPath.section].related?[indexPath.row]
        //cell.titleLab.text = "\(indexPath.row + 1)、\(model?.question?.content?.data ?? "")"
        cell.titleLab.text = "\(model?.question?.content?.data ?? "")"
        if #available(iOS 13.0, *) {
            cell.titleLab.textColor = model?.clicked == true ? UIColor.tertiaryLabel : UIColor.secondaryLabel
        } else {
            // Fallback on earlier versions
        }
        cell.titleLab.font = UIFont.systemFont(ofSize: 14)
        //cell.imgArrowRight.isHidden = true
        cell.iconView.isHidden = true
        cell.iconView.snp.updateConstraints { make in
            make.width.equalTo(0)
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model: QA? = sectionList[indexPath.section].related?[indexPath.row]
        if (model?.clicked == true) {
            return
        }
        model?.clicked = true
        self.tableView.reloadRows(at: [indexPath], with: UITableView.RowAnimation.none)
        if model != nil {
            qaCellClick!(model!)
        }
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "BWQuestionSectionHeader") as! BWQuestionSectionHeader

        print(sectionList[section].question?.content?.data ?? "")
        // 设置组头视图的内容
        //headerView.titleLabel.text = sectionList[section].question?.content?.data ?? ""
        
        headerView.titleLabel.text = "\(section + 1)、\(sectionList[section].question?.content?.data ?? "")"
        
        //headerView.titleLabel.text = "你和我打的的是谁的谁谁谁谁谁谁谁谁谁呃呃等待"
        if #available(iOS 13.0, *) {
            headerView.titleLabel.textColor = UIColor.label
            //headerView.backgroundColor = UIColor.red
        } else {
            // Fallback on earlier versions
        }
        headerView.titleLabel.font = UIFont.systemFont(ofSize: 14)
        if sectionList[section].myExpanded == true {
            headerView.imgView.image = UIImage.svgInit("arrowup")
        } else {
            headerView.imgView.image = UIImage.svgInit("arrowdown")
        }
        
        if sectionList[section].related == nil || sectionList[section].related!.isEmpty {
            headerView.imgView.isHidden = true
        }
        //headerView.imgView.isHidden = true
        /*
         var tvTitle = holder?.get<TextView>(R.id.tv_Title)
                 tvTitle?.text = (position + 1).toString() + ", " + bean.question.content.data
         */
        headerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(headerViewTapped(sender:))))
        headerView.tag = section
        return headerView
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0.1))
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        32
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        32
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        0.1
    }

    @objc func headerViewTapped(sender: UITapGestureRecognizer) {
        guard let section = sender.view?.tag else { return }
        // 在这里处理点击事件，使用 section 参数
        if sectionList[section].related == nil || sectionList[section].related!.isEmpty {
            if sectionList[section].clicked{
                return
            }
            var headerView = sender.view as! BWQuestionSectionHeader
            if #available(iOS 13.0, *) {
                headerView.titleLabel.textColor = UIColor.tertiaryLabel
                headerView.enableMode = .disabled
            } else {
                // Fallback on earlier versions
            }
            sectionList[section].clicked = true
            qaCellClick!(sectionList[section])
        } else {
            sectionList[section].myExpanded = !sectionList[section].myExpanded
            updateTableViewHeight()
        }
    }

    func updateTableViewHeight() {
        if sectionList.count == 0 {
            heightCallback!(0)
        } else {
            let sectionHeight = Double(sectionList.count) * 44.0
            var expandRowHeight: Double = 0.0
            sectionList.forEach { (qa: QA) in
                if qa.myExpanded == true {
                    expandRowHeight = expandRowHeight + Double(qa.related?.count ?? 0) * 44.0
                }
            }

            print("QA Cell Height:\(25.0 + sectionHeight + expandRowHeight)")
            heightCallback!(25.0 + sectionHeight + expandRowHeight)
            isHidden = false
        }
        tableView.reloadData()
    }
}
