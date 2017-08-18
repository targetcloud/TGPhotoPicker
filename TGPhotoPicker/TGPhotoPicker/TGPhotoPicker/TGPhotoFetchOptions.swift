//
//  TGPhotoFetchOptions.swift
//  TGPhotoPicker
//
//  Created by targetcloud on 2017/7/21.
//  Copyright © 2017年 targetcloud. All rights reserved.
//

import UIKit
import Photos

class TGPhotoFetchOptions: PHFetchOptions {

    override init() {
        super.init()
        if TGPhotoPickerConfig.shared.selectKind == .onlyVideo{
            self.predicate = NSPredicate(format: "mediaType == %d", PHAssetMediaType.video.rawValue)
        }else if (TGPhotoPickerConfig.shared.selectKind == .onlyPhoto){
            self.predicate = NSPredicate(format: "mediaType == %d", PHAssetMediaType.image.rawValue)
        }else if TGPhotoPickerConfig.shared.selectKind == .onlyLive{
            if #available(iOS 9.1, *) {
                self.predicate = NSPredicate(format: "mediaSubtype == %d", PHAssetMediaSubtype.photoLive.rawValue)
            } 
        }
        
        self.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: TGPhotoPickerConfig.shared.ascending)]
    }
}
