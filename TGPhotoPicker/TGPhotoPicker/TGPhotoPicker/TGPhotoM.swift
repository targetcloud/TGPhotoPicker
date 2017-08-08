//
//  TGPhotoM.swift
//  TGPhotoPicker
//
//  Created by targetcloud on 2017/7/12.
//  Copyright © 2017年 targetcloud. All rights reserved.
//

import UIKit
import Photos

class TGPhotoM: NSObject {
    var smallImage: UIImage?
    var bigImage: UIImage?
    var imageData: Data?
    var asset: PHAsset?
    var order: Int = 0
    
    convenience init(asset: PHAsset) {
        self.init()
        
        let imageManeger = PHImageManager()
        
        let smallOptions = PHImageRequestOptions()
        smallOptions.deliveryMode = .opportunistic
        smallOptions.resizeMode = .fast
        
        let bigOptions = PHImageRequestOptions()
        bigOptions.deliveryMode = .opportunistic
        bigOptions.resizeMode = .exact
        
        self.asset = asset
        
        let bigSize = CGSize(width: asset.pixelWidth, height: asset.pixelHeight)
        imageManeger.requestImage(for: asset, targetSize: bigSize, contentMode: PHImageContentMode(rawValue: 0)!, options: bigOptions, resultHandler: { (image, info) in
            if image != nil{
                self.bigImage = image!
            }
        })
        
        let smallSize = CGSize(width: TGPhotoPickerConfig.shared.selectWH * UIScreen.main.scale, height: TGPhotoPickerConfig.shared.selectWH * UIScreen.main.scale)
        imageManeger.requestImage(for: asset, targetSize: smallSize, contentMode: PHImageContentMode(rawValue: 0)!, options: smallOptions, resultHandler: { (image, info) in
            if image != nil{
                self.smallImage = image!
            }
        })
        
        imageManeger.requestImageData(for: asset, options: bigOptions, resultHandler: { (data, str, imageOrientation, info) in
            if data != nil{
                self.imageData = data!
            }
        })
    }
    
    class func getImagesAndDatas(photos:[PHAsset], imageData:@escaping(_ photoArr: [TGPhotoM])->()){
        let smallOptions = PHImageRequestOptions()
        smallOptions.deliveryMode = .highQualityFormat
        smallOptions.resizeMode = .fast
        
        let bigOptions = PHImageRequestOptions()
        bigOptions.deliveryMode = .highQualityFormat
        bigOptions.resizeMode = .exact
        
        let imageManeger = PHImageManager()
        let smallSize = CGSize(width: TGPhotoPickerConfig.shared.mainCellWH * UIScreen.main.scale, height: TGPhotoPickerConfig.shared.mainCellWH * UIScreen.main.scale)
        
        var modelArr = [TGPhotoM]()
        for i in 0..<photos.count {
            let asset = photos[i]
            let bigSize = CGSize(width: asset.pixelWidth, height: asset.pixelHeight)
            let model = TGPhotoM()
            model.asset = asset
            model.order = i
            imageManeger.requestImage(for: asset, targetSize: bigSize, contentMode: .aspectFit, options: bigOptions, resultHandler: { (image, info) in
                if image != nil{
                    model.bigImage = image!
                    
                    imageManeger.requestImage(for: asset, targetSize: smallSize, contentMode: .aspectFit, options: smallOptions, resultHandler: { (image, info) in
                        if image != nil{
                            model.smallImage = image!
                            
                            imageManeger.requestImageData(for: asset, options: bigOptions, resultHandler: { (data, str, imageOrientation, info) in
                                if data != nil{
                                    model.imageData = data!
                                    modelArr.append(model)
                                    if modelArr.count == photos.count{
                                        DispatchQueue.main.async {
                                            imageData(modelArr.sorted(by: { return $0.order < $1.order }))
                                        }
                                    }
                                }
                            })
                        }
                    })
                }
            })
        }
    }
}
