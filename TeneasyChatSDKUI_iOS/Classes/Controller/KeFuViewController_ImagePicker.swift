import Alamofire
import MobileCoreServices
import Network
import PhotosUI
import TeneasyChatSDK_iOS
// import TeneasyChatSDKUI_iOS
import UIKit

extension KeFuViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func presentNoauth(isPhoto: Bool) {
        let vc = WWNoAuthorizeVC()
        vc.modalPresentationStyle = .fullScreen
        vc.isPhoto = isPhoto
        present(vc, animated: false)
    }

    func presentImagePicker(controller: UIImagePickerController, source: UIImagePickerController.SourceType) {
        controller.delegate = self
        controller.sourceType = source
        if #available(iOS 14.0, *) {
            controller.mediaTypes = [UTType.image.identifier, UTType.movie.identifier]
        } else {
            controller.mediaTypes = [kUTTypeImage as String, kUTTypeMovie as String]
        }
        controller.allowsEditing = false
        controller.modalPresentationStyle = .fullScreen
        //controller.videoQuality = .typeHigh
        // controller.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary) ?? []
        // controller.mediaTypes = ["public.movie"]
        present(controller, animated: true)
    }

    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let mediaType = info[.mediaType] as? String {
            if mediaType == kUTTypeImage as String {
                if let image = info[.originalImage] as? UIImage, let imgUrl = info[.imageURL] as? URL {
                    // 处理选中的图片
                    print("Selected image: \(image) \(imgUrl)")
                    chooseImg = image
                    self.dealPickImage(picker: picker, filePath: imgUrl.absoluteString)
                }
            } else if mediaType == kUTTypeMovie as String {
                if let videoURL = info[.mediaURL] as? URL {
                    // 处理选中的视频
                    print("Selected video URL: \(videoURL)")
                    guard let videoData = try? Data(contentsOf: videoURL) else {
                        print("Unable to get video data")
                        return
                    }
                    let tt = videoData.count
                    
                    fetchPHAsset(forVideoURL: videoURL) { asset in
                            if let asset = asset {
                                // Do something with the PHAsset
                                print("Found PHAsset: \(asset)")
                            } else {
                                print("PHAsset not found for the given URL")
                            }
                        }

                    print("video大小：\(tt)")
                    if tt > 1024 * 1024 * 300  {
                        print("视频/文件限制300M")
                        let alertVC = UIAlertController(title: "提示", message: "视频不能超过300M", preferredStyle: .alert)
                        let cancelAction = UIAlertAction(title: "取消", style: .default, handler: { _ in
                            picker.dismiss(animated: true)
                        })
                        alertVC.addAction(cancelAction)
                        picker.present(alertVC, animated: true, completion: nil)
                        return
                    }
                    
                    self.upload(imgData: videoData, isVideo: true, filePath: videoURL.absoluteString)
                    picker.dismiss(animated: true)
                }
            }
        }
    }

    func dealPickImage(picker: UIImagePickerController, filePath: String) {
        guard let imgData = chooseImg?.jpegData(compressionQuality: 0.5) else { return }
        let tt = imgData.count
        print("图片大小：\(tt)")
        if tt > 20 * 1024 * 1024 {
            print("图片不能超过20M")
            let alertVC = UIAlertController(title: "提示", message: "图片限制20M", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "取消", style: .default, handler: { _ in
                picker.dismiss(animated: true)
            })
            alertVC.addAction(cancelAction)
            picker.present(alertVC, animated: true, completion: nil)
            return
        }
        
        upload(imgData: imgData, isVideo: false, filePath: filePath)
        picker.dismiss(animated: true)
    }
    
    func fetchPHAsset(forVideoURL videoURL: URL, completion: @escaping (PHAsset?) -> Void) {
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.video.rawValue)
        
        let fetchResult = PHAsset.fetchAssets(with: fetchOptions)
        
        // Iterate through assets to find the matching one
        fetchResult.enumerateObjects { asset, index, stop in
            let options = PHVideoRequestOptions()
            options.isNetworkAccessAllowed = true
            
            PHImageManager.default().requestAVAsset(forVideo: asset, options: options) { avAsset, audioMix, info in
                if let urlAsset = avAsset as? AVURLAsset, urlAsset.url == videoURL {
                    completion(asset)
                    stop.pointee = true
                }
            }
        }
    }
    
    func fetchVideoAsset(withLocalIdentifier identifier: String, completion: @escaping (PHAsset?) -> Void) {
        let fetchResult = PHAsset.fetchAssets(withLocalIdentifiers: [identifier], options: nil)
        let asset = fetchResult.firstObject
        completion(asset)
    }

    
    func requestVideoData(for asset: PHAsset, completion: @escaping (URL?) -> Void) {
        let options = PHVideoRequestOptions()
        options.version = .original
        options.isNetworkAccessAllowed = true
        PHImageManager.default().requestAVAsset(forVideo: asset, options: options) { avAsset, audioMix, info in
            if let urlAsset = avAsset as? AVURLAsset {
                completion(urlAsset.url)
            } else {
                completion(nil)
            }
        }
    }

    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true) {}
    }

    // 用户是否开启权限
    func authorize(authorizeClouse: @escaping (PHAuthorizationStatus) -> ()) {
        let status = PHPhotoLibrary.authorizationStatus()
        if status == .authorized {
            authorizeClouse(status)
        } else if status == .notDetermined { // 未授权，请求授权
            PHPhotoLibrary.requestAuthorization { state in
                DispatchQueue.main.async {
                    authorizeClouse(state)
                }
            }
        } else {
            authorizeClouse(status)
        }
    }

    // 用户是否开启相机权限
    func authorizeCamaro(authorizeClouse: @escaping (AVAuthorizationStatus) -> ()) {
        let status = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)

        if status == .authorized {
            authorizeClouse(status)
        } else if status == .notDetermined {
            AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { granted in
                if granted { // 允许
                    authorizeClouse(.authorized)
                }
            })
        } else {
            authorizeClouse(status)
        }
    }

    func getStrFromImage() -> String {
        let imageOrigin = chooseImg
        if let image = imageOrigin {
            let dataTmp = image.jpegData(compressionQuality: 0.1)
            if let data = dataTmp {
                let imageStrTT = data.base64EncodedString()
                return imageStrTT
            }
        }
        return ""
    }
}
