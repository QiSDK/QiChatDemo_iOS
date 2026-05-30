
//
//  KeFuViewController_ChatToolBar.swift
//  TeneasyChatSDKUI_iOS
//
//  Created by Xuefeng
//

import Foundation
import TeneasyChatSDK_iOS
import MobileCoreServices
import UIKit
#if canImport(UniformTypeIdentifiers)
import UniformTypeIdentifiers
#endif

// MARK: - 聊天工具栏代理实现 V2版本
extension KeFuViewController: BWKeFuChatToolBarV2Delegate {

    // MARK: - 输入区图标

    /// 表情按钮点击
    func toolBar(toolBar: BWKeFuChatToolBarV2, didSelectedEmoji btn: UIButton) {
        // 状态切换在 toolBar 内部完成，这里仅作埋点钩子
    }

    /// 附件按钮面板展开/收起
    func toolBar(toolBar: BWKeFuChatToolBarV2, didToggleAttachPanel isShowing: Bool) {
        // 可在此处通知评价浮按钮隐藏等，与 Flutter 对齐
    }

    // MARK: - 展开面板的四个操作

    /// 图片：弹 ActionSheet 选「拍照 / 相册」
    func toolBar(toolBar: BWKeFuChatToolBarV2, didSelectedImageAction btn: UIButton) {
        presentImageSourceSheet()
    }

    /// 视频：弹 ActionSheet 选「拍照 / 相册」
    func toolBar(toolBar: BWKeFuChatToolBarV2, didSelectedVideoAction btn: UIButton) {
        presentVideoSourceSheet()
    }

    /// 设备信息：push 设备信息页
    func toolBar(toolBar: BWKeFuChatToolBarV2, didSelectedDeviceInfoAction btn: UIButton) {
        self.toolBar.resetStatus()
        let vc = DeviceInfoViewController(theme: theme)
        if let nav = navigationController {
            nav.pushViewController(vc, animated: true)
        } else {
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: true)
        }
    }

    /// 文件：调用文档选择器
    func toolBar(toolBar: BWKeFuChatToolBarV2, didSelectedFileAction btn: UIButton) {
        openDocumentPicker()
    }

    // MARK: - 文本编辑

    func toolBar(toolBar: BWKeFuChatToolBarV2, didBeginEditing textView: UITextView) {}
    func toolBar(toolBar: BWKeFuChatToolBarV2, didChanged textView: UITextView) {}
    func toolBar(toolBar: BWKeFuChatToolBarV2, didEndEditing textView: UITextView) {}

    /// 键盘 send 键发送
    func toolBar(toolBar: BWKeFuChatToolBarV2, sendText context: String) {
        sendMsg(textMsg: context)
        self.toolBar.resetStatus()
    }

    @objc func toolBar(toolBar: BWKeFuChatToolBarV2, delete text: String, range: NSRange) -> Bool {
        return true
    }

    @objc func toolBar(toolBar: BWKeFuChatToolBarV2, changed text: String, range: NSRange) -> Bool {
        return true
    }

    /// 旧表情面板回调（保留兼容）
    func toolBar(toolBar: BWKeFuChatToolBarV2, menuView: BWKeFuChatMenuView,
                 collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath,
                 model: BEmotion) {
        print("选择表情: \(model.displayName)")
    }
}

// MARK: - 图片来源 ActionSheet & 视频选择

extension KeFuViewController {

    fileprivate func presentImageSourceSheet() {
        let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        sheet.addAction(UIAlertAction(title: "拍照", style: .default) { [weak self] _ in
            self?.pickImageFromCamera()
        })
        sheet.addAction(UIAlertAction(title: "相册", style: .default) { [weak self] _ in
            self?.pickImageFromLibrary()
        })
        sheet.addAction(UIAlertAction(title: "取消", style: .cancel))
        present(sheet, animated: true)
    }

    fileprivate func pickImageFromLibrary() {
        self.authorize { state in
            switch state {
            case .restricted, .denied:
                self.presentNoauth(isPhoto: true)
            default:
                let picker = self.imagePickerController
                picker.delegate = self
                picker.sourceType = .photoLibrary
                if #available(iOS 14.0, *) {
                    picker.mediaTypes = [UTType.image.identifier]
                } else {
                    picker.mediaTypes = [kUTTypeImage as String]
                }
                picker.allowsEditing = false
                picker.modalPresentationStyle = .fullScreen
                self.present(picker, animated: true)
            }
        }
        self.toolBar.resetStatus()
    }

    fileprivate func pickImageFromCamera() {
        self.authorizeCamaro { state in
            DispatchQueue.main.async {
                switch state {
                case .restricted, .denied:
                    self.presentNoauth(isPhoto: false)
                default:
                    let picker = self.imagePickerController
                    picker.delegate = self
                    picker.sourceType = .camera
                    if #available(iOS 14.0, *) {
                        picker.mediaTypes = [UTType.image.identifier]
                    } else {
                        picker.mediaTypes = [kUTTypeImage as String]
                    }
                    picker.allowsEditing = false
                    picker.modalPresentationStyle = .fullScreen
                    self.present(picker, animated: true)
                }
            }
        }
        self.toolBar.resetStatus()
    }

    fileprivate func presentVideoSourceSheet() {
        let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        sheet.addAction(UIAlertAction(title: "录像", style: .default) { [weak self] _ in
            self?.pickVideoFromCamera()
        })
        sheet.addAction(UIAlertAction(title: "相册", style: .default) { [weak self] _ in
            self?.pickVideoFromLibrary()
        })
        sheet.addAction(UIAlertAction(title: "取消", style: .cancel))
        present(sheet, animated: true)
    }

    fileprivate func pickVideoFromLibrary() {
        self.authorize { state in
            switch state {
            case .restricted, .denied:
                self.presentNoauth(isPhoto: true)
            default:
                let picker = self.imagePickerController
                picker.delegate = self
                picker.sourceType = .photoLibrary
                if #available(iOS 14.0, *) {
                    picker.mediaTypes = [UTType.movie.identifier]
                } else {
                    picker.mediaTypes = [kUTTypeMovie as String]
                }
                picker.allowsEditing = false
                picker.modalPresentationStyle = .fullScreen
                self.present(picker, animated: true)
            }
        }
        self.toolBar.resetStatus()
    }

    fileprivate func pickVideoFromCamera() {
        self.authorizeCamaro { state in
            DispatchQueue.main.async {
                switch state {
                case .restricted, .denied:
                    self.presentNoauth(isPhoto: false)
                default:
                    let picker = self.imagePickerController
                    picker.delegate = self
                    picker.sourceType = .camera
                    if #available(iOS 14.0, *) {
                        picker.mediaTypes = [UTType.movie.identifier]
                    } else {
                        picker.mediaTypes = [kUTTypeMovie as String]
                    }
                    picker.cameraCaptureMode = .video
                    picker.videoQuality = .typeHigh
                    picker.allowsEditing = false
                    picker.modalPresentationStyle = .fullScreen
                    self.present(picker, animated: true)
                }
            }
        }
        self.toolBar.resetStatus()
    }
}
