//
//  TGPhotoPickerManager.swift
//  TGPhotoPicker
//
//  Created by targetcloud on 2017/7/25.
//  Copyright © 2017年 targetcloud. All rights reserved.
//

import UIKit

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
}

extension TGPhotoPickerManager: TGActionSheetDelegate {
    func actionSheet(actionSheet: TGActionSheet?, didClickedAt index: Int) {
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
            let pickervc = TGPhotoPickerVC(type: .allAlbum)
            pickervc.callbackPhotos = handlePhotosBlock
            pickervc.callbackPhotoMs = handlePhotoModelsBlock
            UIApplication.shared.keyWindow?.currentVC()?.present(pickervc, animated: true, completion: nil)
        default:
            break
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
