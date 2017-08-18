//
//  TGPhotoPickerManager.swift
//  TGPhotoPicker
//
//  Created by targetcloud on 2017/7/25.
//  Copyright © 2017年 targetcloud. All rights reserved.
//

import UIKit
import Photos

class TGPhotoPickerManager: NSObject {
    static let shared = TGPhotoPickerManager()
    var handlePhotosBlock: HandlePhotosBlock?
    var handlePhotoModelsBlock: HandlePhotoModelsBlock?
    
    private override init() {
        super.init()
    }
    
    fileprivate lazy var config: TGPhotoPickerConfig = TGPhotoPickerConfig.shared
    
    func takePhotos(_ showCamera: Bool, _ showAlbum: Bool, _ configBlock:((_ config:TGPhotoPickerConfig)->())? = nil, _ completeHandler: @escaping HandlePhotosBlock){
        configBlock?(self.config)
        self.handlePhotosBlock = completeHandler
        
        if config.useCustomActionSheet{
            let sheet = TGActionSheet(delegate: self, cancelTitle: config.cancelTitle, otherTitles: [config.cameraTitle, config.selectTitle])
            sheet.show()
            return
        }
        
        let ac = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let action1 = UIAlertAction(title: config.cameraTitle, style: .default) { (action) in
            self.actionSheet(actionSheet: nil, didClickedAt: 0)
        }
        
        let action2 = UIAlertAction(title: config.selectTitle, style: .default) { (action) in
            self.actionSheet(actionSheet: nil, didClickedAt: 1)
        }
        showCamera ? ac.addAction(action1) : ()
        showAlbum ? ac.addAction(action2) : ()
        ac.addAction(UIAlertAction(title: config.cancelTitle, style: .cancel, handler: nil))
        UIApplication.shared.keyWindow?.currentVC()?.present(ac, animated: true, completion: nil)
    }
    
    func takePhotoModels(_ showCamera: Bool, _ showAlbum: Bool, _ configBlock:((_ config:TGPhotoPickerConfig)->())? = nil, _ completeHandler: @escaping HandlePhotoModelsBlock){
        configBlock?(self.config)
        self.handlePhotoModelsBlock = completeHandler
        
        if config.useCustomActionSheet{
            let sheet = TGActionSheet(delegate: self, cancelTitle: config.cancelTitle, otherTitles: [config.cameraTitle, config.selectTitle])
            sheet.show()
            return
        }
        
        let ac = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let action1 = UIAlertAction(title: config.cameraTitle, style: .default) { (action) in
            self.actionSheet(actionSheet: nil, didClickedAt: 0)
        }
        
        let action2 = UIAlertAction(title: config.selectTitle, style: .default) { (action) in
            self.actionSheet(actionSheet: nil, didClickedAt: 1)
        }
        showCamera ? ac.addAction(action1) : ()
        showAlbum ? ac.addAction(action2) : ()
        ac.addAction(UIAlertAction(title: config.cancelTitle, style: .cancel, handler: nil))
        UIApplication.shared.keyWindow?.currentVC()?.present(ac, animated: true, completion: nil)
    }
    
    func authorizePhotoLibrary(authorizeClosure:@escaping (PHAuthorizationStatus)->()){
        let status = PHPhotoLibrary.authorizationStatus()
        
        if status == .authorized{
            authorizeClosure(status)
        } else if status == .notDetermined {
            PHPhotoLibrary.requestAuthorization({ (state) in
                DispatchQueue.main.async(execute: {
                    authorizeClosure(state)
                })
            })
        } else {
            let sheet = TGActionSheet(delegate: self, title: config.photoLibraryUsage + "("+config.photoLibraryUsageTip+")",cancelTitle: config.cancelTitle, otherTitles: [config.confirmTitle])
            sheet.name = "photoLibraryAuthorize"
            sheet.show()
            authorizeClosure(status)
        }
    }
    
    func authorizeCamera(authorizeClosure:@escaping (AVAuthorizationStatus)->()){
        let status = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
        
        if status == .authorized{
            authorizeClosure(status)
        } else if status == .notDetermined {
            AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo, completionHandler: { (granted) in
                if granted {
                    authorizeClosure(.authorized)
                }
            })
        } else {
            let sheet = TGActionSheet(delegate: self, title: config.cameraUsage + "("+config.cameraUsageTip+")",cancelTitle: config.cancelTitle, otherTitles: [config.confirmTitle])
            sheet.name = "cameraAuthorize"
            sheet.show()
            authorizeClosure(status)
        }
    }
    
    public static func convertAssetArrToImageArr(assetArr:Array<PHAsset>,scale:CGFloat = TGPhotoPickerConfig.shared.compressionQuality) -> [UIImage] {
        var imageArr = [UIImage]()
        for item in assetArr {
            if item.mediaType == .image {
                getAssetOrigin(asset: item, dealImageSuccess: { (img, info) in
                    guard img != nil else{ return }
                    if let zipImageData = UIImageJPEGRepresentation(img!,scale){
                        let image = UIImage(data: zipImageData)
                        imageArr.append(image!)
                    }
                })
            }
        }
        return imageArr
    }
    
    public static func convertAssetArrToAVPlayerItemArr(assetArr:Array<PHAsset>) -> [AVPlayerItem] {
        var videoArr = [AVPlayerItem]()
        for item in assetArr {
            if item.mediaType == .video {
                let videoRequestOptions = PHVideoRequestOptions()
                videoRequestOptions.deliveryMode = .automatic
                videoRequestOptions.version = .current
                videoRequestOptions.isNetworkAccessAllowed = true
                PHImageManager.default().requestPlayerItem(forVideo: item, options: videoRequestOptions) { (playItem, info) in
                    if playItem != nil {
                        videoArr.append(playItem!)
                    }
                }
            }
        }
        return videoArr
    }
    
    static func getAssetOrigin(asset:PHAsset,dealImageSuccess:@escaping (UIImage?,[AnyHashable:Any]?) -> ()) {
        let option = PHImageRequestOptions()
        option.isSynchronous = true
        PHImageManager.default().requestImage(for: asset, targetSize:PHImageManagerMaximumSize, contentMode: .aspectFit, options: option) { (originImage, info) in
            dealImageSuccess(originImage,info)
        }
    }
    
    deinit {
        //print("TGPhotoPickerManager deinit")
    }
}

extension TGPhotoPickerManager: TGActionSheetDelegate {
    func actionSheet(actionSheet: TGActionSheet?, didClickedAt index: Int) {
        switch actionSheet?.name ?? "" {
        case "photoLibraryAuthorize","cameraAuthorize":
            switch index {
            case 0:
                let url = URL(string: UIApplicationOpenSettingsURLString)
                if let url = url, UIApplication.shared.canOpenURL(url) {
                    if #available(iOS 10, *) {
                        if UIApplication.shared.canOpenURL(url){
                            UIApplication.shared.open(url, options: [:],completionHandler: {(success) in
                                
                            })
                        }
                    } else {
                        if UIApplication.shared.canOpenURL(url){
                            UIApplication.shared.openURL(url)
                        }
                    }
                }
            default:
                break
            }
        default:
            switch index {
            case 0:
                if TGPhotoPickerConfig.shared.useiOS8Camera {
                    let cameraVC = TGCameraVCForiOS8()
                    cameraVC.callbackPicutureData = { imgData in
                        let bigImg = UIImage(data:imgData!)
                        let imgData = UIImageJPEGRepresentation(bigImg!,TGPhotoPickerConfig.shared.compressionQuality)
                        let smallImg = bigImg
                        let model = TGPhotoM()
                        model.bigImage = bigImg
                        model.imageData = imgData
                        model.smallImage = smallImg
                        self.handlePhotoModelsBlock?([model])
                        self.handlePhotosBlock?([nil],[smallImg],[bigImg],[imgData])
                    }
                    UIApplication.shared.keyWindow?.currentVC()?.present(cameraVC, animated: true, completion: nil)
                } else if #available(iOS 10.0, *) {
                    let cameraVC = TGCameraVC()
                    cameraVC.callbackPicutureData = { imgData in
                        let bigImg = UIImage(data:imgData!)
                        let imgData = UIImageJPEGRepresentation(bigImg!,TGPhotoPickerConfig.shared.compressionQuality)
                        let smallImg = bigImg
                        let model = TGPhotoM()
                        model.bigImage = bigImg
                        model.imageData = imgData
                        model.smallImage = smallImg
                        self.handlePhotoModelsBlock?([model])
                        self.handlePhotosBlock?([nil],[smallImg],[bigImg],[imgData])
                    }
                    UIApplication.shared.keyWindow?.currentVC()?.present(cameraVC, animated: true, completion: nil)
                } else {
                    let cameraVC = TGCameraVCForiOS8()
                    cameraVC.callbackPicutureData = { imgData in
                        let bigImg = UIImage(data:imgData!)
                        let imgData = UIImageJPEGRepresentation(bigImg!,TGPhotoPickerConfig.shared.compressionQuality)
                        let smallImg = bigImg
                        let model = TGPhotoM()
                        model.bigImage = bigImg
                        model.imageData = imgData
                        model.smallImage = smallImg
                        self.handlePhotoModelsBlock?([model])
                        self.handlePhotosBlock?([nil],[smallImg],[bigImg],[imgData])
                    }
                    UIApplication.shared.keyWindow?.currentVC()?.present(cameraVC, animated: true, completion: nil)
                }
            case 1:
                authorizePhotoLibrary(authorizeClosure: { (status) in
                    if status == .authorized{                        
                        let pickervc = TGPhotoPickerVC(type: .allAlbum)
                        pickervc.callbackPhotos = self.handlePhotosBlock
                        pickervc.callbackPhotoMs = self.handlePhotoModelsBlock
                        UIApplication.shared.keyWindow?.currentVC()?.present(pickervc, animated: true, completion: nil)
                    }
                })
            default:
                break
            }
        }
        
    }
}

extension UIWindow {
    public func topMostVC()->UIViewController? {
        var topController = rootViewController
        while let presentedController = topController?.presentedViewController {
            topController = presentedController
        }
        return topController
    }

    public func currentVC()->UIViewController? {
        var currentViewController = topMostVC()
        while currentViewController != nil &&
              currentViewController is UINavigationController &&
              (currentViewController as! UINavigationController).topViewController != nil {
            currentViewController = (currentViewController as! UINavigationController).topViewController
        }
        return currentViewController
    }
}
