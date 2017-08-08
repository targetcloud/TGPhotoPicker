//
//  TGFetchM.swift
//  TGPhotoPicker
//
//  Created by targetcloud on 2017/7/13.
//  Copyright © 2017年 targetcloud. All rights reserved.
//

import UIKit
import Photos

class TGFetchM {
    var fetchResult: PHFetchResult<PHObject>!
    var assetType: PHAssetCollectionSubtype!
    var name: String!
    
    init(result: PHFetchResult<PHObject>,name: String?, assetType: PHAssetCollectionSubtype){
        self.fetchResult = result
        self.name = name
        self.assetType = assetType
    }
}
