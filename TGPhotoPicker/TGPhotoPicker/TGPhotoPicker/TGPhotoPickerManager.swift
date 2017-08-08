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
    private override init() {
        super.init()
    }
    
    fileprivate lazy var config: TGPhotoPickerConfig = TGPhotoPickerConfig.shared
    
    func takePhotos(_ showCamera: Bool, _ showAlbum: Bool, _ configBlock:((_ config:TGPhotoPickerConfig)->())? = nil, _ completeHandler: @escaping HandlePhotosBlock){
        configBlock?(self.config)
        
        let ac = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let action1 = UIAlertAction(title: config.cameraTitle, style: .default) { (action) in
            let cameraVC = TGCameraVC()
            cameraVC.callbackPicutureData = { imgData in
                let bigImg = UIImage(data:imgData!)
                let imgData = UIImageJPEGRepresentation(bigImg!,TGPhotoPickerConfig.shared.compressionQuality)
                let smallImg = bigImg
                completeHandler([nil],[smallImg],[bigImg],[imgData])
            }
            UIApplication.shared.keyWindow?.currentVC()?.present(cameraVC, animated: true, completion: nil)
        }
        
        let action2 = UIAlertAction(title: config.selectTitle, style: .default) { (action) in
            let pickervc = TGPhotoPickerVC(type: .allAlbum)
            pickervc.callbackPhotos = completeHandler
            UIApplication.shared.keyWindow?.currentVC()?.present(pickervc, animated: true, completion: nil)
        }
        
        showAlbum ? ac.addAction(action2) : ()
        showCamera ? ac.addAction(action1) : ()
        
        ac.addAction(UIAlertAction(title: config.cancelTitle, style: .cancel, handler: nil))
        
        UIApplication.shared.keyWindow?.currentVC()?.present(ac, animated: true, completion: nil)
    }
    
    func takePhotoModels(_ showCamera: Bool, _ showAlbum: Bool, _ configBlock:((_ config:TGPhotoPickerConfig)->())? = nil, _ completeHandler: @escaping HandlePhotoModelsBlock){
        configBlock?(self.config)
        
        let ac = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let action1 = UIAlertAction(title: config.cameraTitle, style: .default) { (action) in
            let cameraVC = TGCameraVC()
            cameraVC.callbackPicutureData = { imgData in
                let bigImg = UIImage(data:imgData!)
                let imgData = UIImageJPEGRepresentation(bigImg!,TGPhotoPickerConfig.shared.compressionQuality)
                let smallImg = bigImg
                let model = TGPhotoM()
                model.bigImage = bigImg
                model.imageData = imgData
                model.smallImage = smallImg
                completeHandler([model])
            }
            UIApplication.shared.keyWindow?.currentVC()?.present(cameraVC, animated: true, completion: nil)
        }
        
        let action2 = UIAlertAction(title: config.selectTitle, style: .default) { (action) in
            let pickervc = TGPhotoPickerVC(type: .allAlbum)
            pickervc.callbackPhotoMs = completeHandler
            UIApplication.shared.keyWindow?.currentVC()?.present(pickervc, animated: true, completion: nil)
        }
        
        showAlbum ? ac.addAction(action2) : ()
        showCamera ? ac.addAction(action1) : ()
        
        ac.addAction(UIAlertAction(title: config.cancelTitle, style: .cancel, handler: nil))
        
        UIApplication.shared.keyWindow?.currentVC()?.present(ac, animated: true, completion: nil)
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
