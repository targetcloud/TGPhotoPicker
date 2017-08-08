//
//  TGPhotoPickerVC.swift
//  TGPhotoPicker
//
//  Created by targetcloud on 2017/7/21.
//  Copyright © 2017年 targetcloud. All rights reserved.
//

import UIKit
import Photos

enum TGPageType{
    case list
    case recentAlbum
    case allAlbum
}

protocol TGPhotoPickerDelegate: class{
    func onImageSelectFinished(images: [PHAsset])
}

typealias HandlePhotosBlock = (_ asset:[PHAsset?], _ smallImage:[UIImage?],_ bigImage:[UIImage?],_ imageData:[Data?]) -> Void
typealias HandlePhotoModelsBlock = (_ photoMs:[TGPhotoM]) -> Void

class TGPhotoPickerVC: UINavigationController {

    var alreadySelectedImageNum = 0
    var assetArr = [PHAsset]()
    weak var imageSelectDelegate: TGPhotoPickerDelegate?
    var callbackPhotos: HandlePhotosBlock?
    var callbackPhotoMs: HandlePhotoModelsBlock?
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    override var prefersStatusBarHidden: Bool{
        return false
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    init(type: TGPageType){
        let rootVC = TGPhotoListVC(style: .plain)
        super.init(rootViewController: rootVC)
        
        self.navigationBar.setBackgroundImage(UIImage.size(width: 1, height: 1).color(TGPhotoPickerConfig.shared.barBGColor).image, for: UIBarMetrics.default)
        
        if #available(iOS 9.0, *) {
            let isVCBased = Bundle.main.infoDictionary?["UIViewControllerBasedStatusBarAppearance"] as? Bool ?? false
            if !isVCBased{
                UIApplication.shared.setStatusBarHidden(false, with: .none)
            }
        }else {
            UIApplication.shared.statusBarStyle = .lightContent
            UIApplication.shared.setStatusBarHidden(false, with: .none)
        }
        
        if type == .recentAlbum || type == .allAlbum {
            let currentType = type == .recentAlbum ? PHAssetCollectionSubtype.smartAlbumRecentlyAdded : PHAssetCollectionSubtype.smartAlbumUserLibrary
            
            let results = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype:currentType, options: nil)
            if results.count > 0 {
                if let model = self.getModel(collection: results[0]) {
                    if model.count > 0 {
                        let layout = TGPhotoCollectionVC.configCustomCollectionLayout()
                        let vc = TGPhotoCollectionVC(collectionViewLayout: layout)
                        vc.fetchResult = model
                        vc.title = TGPhotoPickerConfig.shared.useChineseAlbumName ? TGPhotoPickerConfig.getChineseAlbumName(currentType) : results[0].localizedTitle
                        self.pushViewController(vc, animated: false)
                    }
                }
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func getModel(collection: PHAssetCollection) -> PHFetchResult<PHAsset>?{
        let fetchResult = PHAsset.fetchAssets(in: collection, options: TGPhotoFetchOptions())
        return fetchResult.count > 0 ? fetchResult : nil
    }
    
    func imageSelectFinish(){
        self.dismiss(animated: true, completion: {
            self.imageSelectDelegate?.onImageSelectFinished(images: self.assetArr)
            TGPhotoM.getImagesAndDatas(photos: self.assetArr) { array in
                self.callbackPhotos?(self.assetArr,array.map{$0.smallImage},array.map{$0.bigImage},array.map{$0.imageData})
                self.callbackPhotoMs?(array)
            }
        })
    }
}
