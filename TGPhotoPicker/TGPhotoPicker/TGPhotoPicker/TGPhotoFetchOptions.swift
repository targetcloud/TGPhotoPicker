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
        self.predicate = NSPredicate(format: "mediaType == %d", PHAssetMediaType.image.rawValue)
        self.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: TGPhotoPickerConfig.shared.ascending)]
    }
}
