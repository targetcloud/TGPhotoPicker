//
//  TGPhotoImageManager.swift
//  TGPhotoPicker
//
//  Created by targetcloud on 2017/7/20.
//  Copyright © 2017年 targetcloud. All rights reserved.
//

import UIKit
import Photos

class TGPhotoImageManager: PHCachingImageManager {
    func getPhotoByMaxSize(asset: PHObject, size: CGFloat, completion: @escaping (UIImage?, Data?, [NSObject : Any]?)->()){
        let maxSize = size > TGPhotoPickerConfig.shared.previewImageFetchMaxW ? TGPhotoPickerConfig.shared.previewImageFetchMaxW : size
        if let asset = asset as? PHAsset {
            
            let factor = CGFloat(asset.pixelHeight)/CGFloat(asset.pixelWidth)
            let pixcelWidth = maxSize * UIScreen.main.scale
            let pixcelHeight = CGFloat(pixcelWidth) * factor
            
            self.requestImage(for: asset, targetSize: CGSize(width:pixcelWidth, height: pixcelHeight), contentMode: .aspectFit, options: nil, resultHandler: { image, info in
                if let info = info as? [String:Any] {
                    let canceled = info[PHImageCancelledKey] as? Bool
                    let error = info[PHImageErrorKey] as? NSError
                    if canceled == nil && error == nil && image != nil {
                        var data = UIImageJPEGRepresentation(image!, TGPhotoPickerConfig.shared.compressionQuality) 
                        if data == nil{
                            data = UIImagePNGRepresentation(image!)
                        }
                        completion(image, data, info as [NSObject : Any]?)
                    }
                    
                    let isCloud = info[PHImageResultIsInCloudKey] as? Bool
                    if isCloud != nil && image == nil {
                        let options = PHImageRequestOptions()
                        options.isNetworkAccessAllowed = true
                        self.requestImageData(for: asset, options: options, resultHandler: { data, _, orientation, info in
                            if let data = data {
                                let resultImage = UIImage(data: data, scale: TGPhotoPickerConfig.shared.cloudImageScale)
                                completion(resultImage, data, info as [NSObject : Any]?)
                            }
                        })
                    }
                }
            })
        }
    }
}
