
//
//  KeFuViewController_ChatToolBar.swift
//  TeneasyChatSDKUI_iOS
//
//  Created by Xuefeng
//

import Foundation
import TeneasyChatSDK_iOS

// MARK: - 聊天工具栏代理实现 V2版本
extension KeFuViewController: BWKeFuChatToolBarV2Delegate {
    
    // MARK: - 语音相关
    /// 语音按钮点击事件
    func toolBar(toolBar: BWKeFuChatToolBarV2, didSelectedVoice btn: UIButton) {
        // 待实现
    }
    
    /// 发送语音事件
    func toolBar(toolBar: BWKeFuChatToolBarV2, sendVoice gesture: UILongPressGestureRecognizer) {
        // 待实现
    }
    
    // MARK: - 菜单相关
    /// 菜单按钮点击事件
    func toolBar(toolBar: BWKeFuChatToolBarV2, didSelectedMenu btn: UIButton) {
        // 待实现
    }
    
    // MARK: - 文件处理相关
    /// 文件选择按钮点击事件
    func toolBar(toolBar: BWKeFuChatToolBarV2, didSelectFile btn: UIButton) {
        // 待实现
    }
    
    /// 文件取消选择事件
    func toolBar(toolBar: BWKeFuChatToolBarV2, disSelectedFile btn: UIButton) {
        openDocumentPicker()
    }
    
    // MARK: - 表情相关
    /// 表情按钮点击事件
    func toolBar(toolBar: BWKeFuChatToolBarV2, didSelectedEmoji btn: UIButton) {
        // 待实现
    }
    
    // MARK: - 多媒体处理
    /// 图片选择按钮点击事件
    func toolBar(toolBar: BWKeFuChatToolBarV2, didSelectedPhoto btn: UIButton) {
        // 检查相册权限并处理
        self.authorize { state in
            switch state {
            case .restricted, .denied:
                self.presentNoauth(isPhoto: true)
            default:
                self.presentImagePicker(controller: self.imagePickerController, source: .photoLibrary)
            }
        }
        self.toolBar.resetStatus()
    }

    /// 相机按钮点击事件
    func toolBar(toolBar: BWKeFuChatToolBarV2, didSelectedCamera btn: UIButton) {
        // 检查相机权限并处理
        self.authorizeCamaro { state in
            DispatchQueue.main.async {
                switch state {
                case .restricted, .denied:
                    self.presentNoauth(isPhoto: false)
                default:
                    self.presentImagePicker(controller: self.imagePickerController, source: .camera)
                }
            }
        }
        self.toolBar.resetStatus()
    }

    // MARK: - 消息发送相关
    /// 发送按钮点击事件
    func toolBar(toolBar: BWKeFuChatToolBarV2, didSendMsg btn: UIButton) {
        guard !toolBar.textView.normalText().isEmpty else { return }
        
        sendMsg(textMsg: toolBar.textView.normalText())
        self.toolBar.resetStatus()
    }
    
    /// 菜单表情选择事件
    func toolBar(toolBar: BWKeFuChatToolBarV2, menuView: BWKeFuChatMenuView, 
                collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath, 
                model: BEmotion) {
        print("选择表情: \(model.displayName)")
    }
    
    // MARK: - 文本编辑相关
    /// 开始编辑事件
    func toolBar(toolBar: BWKeFuChatToolBarV2, didBeginEditing textView: UITextView) {
        // 待实现
    }
    
    /// 文本变化事件
    func toolBar(toolBar: BWKeFuChatToolBarV2, didChanged textView: UITextView) {
        // 待实现
    }
    
    /// 结束编辑事件
    func toolBar(toolBar: BWKeFuChatToolBarV2, didEndEditing textView: UITextView) {
        // 待实现
    }
    
    /// 发送文本消息
    func toolBar(toolBar: BWKeFuChatToolBarV2, sendText context: String) {
        sendMsg(textMsg: context)
        self.toolBar.resetStatus()
    }
    
    // MARK: - 文本编辑回调
    /// 删除文本回调
    @objc func toolBar(toolBar: BWKeFuChatToolBarV2, delete text: String, range: NSRange) -> Bool {
        return true
    }
    
    /// 文本变化回调
    @objc func toolBar(toolBar: BWKeFuChatToolBarV2, changed text: String, range: NSRange) -> Bool {
        return true
    }
}
