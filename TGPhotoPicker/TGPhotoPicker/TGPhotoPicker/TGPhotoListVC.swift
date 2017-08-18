//
//  TGPhotoListVC.swift
//  TGPhotoPicker
//
//  Created by targetcloud on 2017/7/21.
//  Copyright © 2017年 targetcloud. All rights reserved.
//

import UIKit
import Photos

private let cellIdentifier = "TGPhotoListCell"

class TGPhotoListCell: UITableViewCell {
    
    class func cellWithTableView(_ tableView: UITableView) -> TGPhotoListCell{
        var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? TGPhotoListCell
        if cell == nil {
            cell = TGPhotoListCell(style: UITableViewCellStyle.default, reuseIdentifier: cellIdentifier)
        }
        return cell!
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func setupUI(){
        self.layoutMargins = UIEdgeInsets.zero
        let bgView = UIView()
        bgView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1)
        self.selectedBackgroundView = bgView
        
        self.selectionStyle = .none
        self.accessoryType = .disclosureIndicator
        
        self.contentView.addSubview(coverImage)
        self.contentView.addSubview(photoTitle)
        self.contentView.addSubview(photoNum)
        
        addConstraint(NSLayoutConstraint(item: photoTitle,attribute: .centerY,relatedBy: .equal,toItem: coverImage,attribute: .centerY,multiplier: 1.0,constant: 0))
        addConstraint(NSLayoutConstraint(item: photoTitle,attribute: .leading,relatedBy: .equal,toItem: coverImage,attribute: .trailing,multiplier: 1.0,constant: TGPhotoPickerConfig.shared.padding))
        
        addConstraint(NSLayoutConstraint(item: photoNum,attribute: .centerY,relatedBy: .equal,toItem: coverImage,attribute: .centerY,multiplier: 1.0,constant: 0))
        addConstraint(NSLayoutConstraint(item: photoNum,attribute: .leading,relatedBy: .equal,toItem: photoTitle,attribute: .trailing,multiplier: 1.0,constant: TGPhotoPickerConfig.shared.padding))
    }
    
    func renderData(_ result:PHFetchResult<AnyObject>, label: String?){
        self.photoTitle.text = label
        self.photoNum.text = "(" + String(result.count) + ")"
        if result.count > 0 {
            if let firstImageAsset = result[0] as? PHAsset {
                let realSize = self.coverImage.frame.width * UIScreen.main.scale
                let size = CGSize(width:realSize, height: realSize)
                let imageOptions = PHImageRequestOptions()
                imageOptions.resizeMode = .exact
                PHImageManager.default().requestImage(for: firstImageAsset, targetSize: size, contentMode: .aspectFill, options: imageOptions, resultHandler: { image, info in
                    self.coverImage.image = image
                })
            }
        }
    }
    
    var asset: PHAsset? {
        willSet {
            if newValue == nil {
                //coverImage.image = UIImage.size(self.coverImage.frame.size).color(gradient: [.lightGray, .white], locations: [0, 1], from: CGPoint(x: 0, y: 0), to: CGPoint(x: 0, y: 1)).image
                
                let containerSize = self.coverImage.frame.size
                let size = CGSize(width: containerSize.width * 0.8, height: containerSize.height * 0.6)
                
                coverImage.image = UIImage.size(containerSize).color(self.backgroundColor!).image +
                    UIImage.size(size).color(UIColor.lightGray.withAlphaComponent(0.2)).corner(radius: 4).image
                        .position(CGPoint(x: self.coverImage.frame.size.width * 0.15, y: self.coverImage.frame.size.height * 0.25)) +
                    UIImage.size(size).border(color: UIColor.lightGray.withAlphaComponent(0.5)).border(width: 1).corner(radius: 4)
                        .color(self.backgroundColor!)
                        .image
                        .position(CGPoint(x: self.coverImage.frame.size.width * 0.07, y: self.coverImage.frame.size.height * 0.17))
                
                return
            }
            let realSize = self.coverImage.frame.width * UIScreen.main.scale
            let size = CGSize(width:realSize, height: realSize)
            PHCachingImageManager.default().requestImage(for: newValue!, targetSize: size, contentMode: .aspectFill, options: nil, resultHandler: { (img, _) in
                self.coverImage.image = img
            })
        }
    }
    
    var albumTitleAndCount: (String?, Int)? {
        willSet {
            if newValue == nil {
                return
            }
            self.photoTitle.text = (newValue!.0 ?? "")
            self.photoNum.text = "(\(String(describing: newValue!.1)))"
        }
    }
    
    private lazy var coverImage: UIImageView = {
        let iv = UIImageView()
        iv.frame = CGRect(x:0,y:0,width:TGPhotoPickerConfig.shared.albumCellH,height:TGPhotoPickerConfig.shared.albumCellH)
        return iv
    }()
    
    private lazy var photoTitle: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .clear
        label.textColor = .darkGray
        label.font = UIFont.systemFont(ofSize: TGPhotoPickerConfig.shared.fontSize)
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var photoNum: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .lightGray
        label.font = UIFont.systemFont(ofSize: TGPhotoPickerConfig.shared.fontSize - 1.0)
        label.numberOfLines = 0
        return label
    }()
}

class TGPhotoListVC: UITableViewController {

    var albums = [TGFetchM]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if !TGPhotoPickerConfig.shared.customSmartCollections.contains(.smartAlbumUserLibrary){//如果没有包含这项,则需要默认包含这项
            TGPhotoPickerConfig.shared.customSmartCollections.append(.smartAlbumUserLibrary)
        }
        
//        if #available(iOS 9.0, *) {
//            if !TGPhotoPickerConfig.shared.customSmartCollections.contains(.smartAlbumScreenshots){
//                TGPhotoPickerConfig.shared.customSmartCollections.append(.smartAlbumScreenshots)
//            }
//        }
        
        PHPhotoLibrary.shared().register(self)
        setupTableView()
        setupNavigationBar()
        loadAlbums(true)
    }
    
    private func setupNavigationBar(){
        self.navigationController?.navigationBar.barStyle = .black
        self.navigationController?.navigationBar.tintColor = .white
        self.navigationItem.title = TGPhotoPickerConfig.shared.albumTitle
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: TGPhotoPickerConfig.shared.cancelTitle, style: .plain, target: self, action: #selector(navDismiss))
    }
    
    @objc private func navDismiss(){
        let nav = self.navigationController as! TGPhotoPickerVC
        nav.assetArr.removeAll()
        self.navigationController?.dismiss(animated: true, completion: nil)
    }

    private func setupTableView(){
        self.tableView.rowHeight = TGPhotoPickerConfig.shared.albumCellH
        self.tableView.separatorColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.15)
        self.tableView.separatorInset = UIEdgeInsets.zero
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        self.tableView.register(TGPhotoListCell.self, forCellReuseIdentifier: cellIdentifier)
    }
    
    deinit{
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }

    fileprivate func loadAlbums(_ replace: Bool){
        if replace {
            self.albums.removeAll()
        }
        
        let smartAlbums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .albumRegular, options: nil)
        print("smartAlbums.count:\(smartAlbums.count)")
        for i in 0 ..< smartAlbums.count  {//14 (contains `Recently Deleted`)
            if TGPhotoPickerConfig.shared.useCustomSmartCollectionsMask{
                if TGPhotoPickerConfig.shared.customSmartCollections.contains(smartAlbums[i].assetCollectionSubtype){
                    self.filterFetchResult(collection: smartAlbums[i])
                }
            }else{
                self.filterFetchResult(collection: smartAlbums[i])
            }
        }
        
        let topUserLibraryList = PHCollectionList.fetchTopLevelUserCollections(with: nil)
        for i in 0 ..< topUserLibraryList.count {
            if let topUserAlbumItem = topUserLibraryList[i] as? PHAssetCollection {
                self.filterFetchResult(collection: topUserAlbumItem)
            }
        }
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    private func filterFetchResult(collection: PHAssetCollection){
        let fetchResult = PHAsset.fetchAssets(in: collection, options: TGPhotoFetchOptions())
        print("\(String(describing: collection.localizedTitle)):\(fetchResult.count)")
        if TGPhotoPickerConfig.shared.isShowEmptyAlbum{
            self.albums.append(TGFetchM(result: fetchResult as! PHFetchResult<PHObject> , name: collection.localizedTitle, assetType: collection.assetCollectionSubtype))
        }else if fetchResult.count > 0 {
            self.albums.append(TGFetchM(result: fetchResult as! PHFetchResult<PHObject> , name: collection.localizedTitle, assetType: collection.assetCollectionSubtype))
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.albums.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //let cell =  TGPhotoListCell.cellWithTableView(tableView)
        //cell.renderData(self.albums[indexPath.row].fetchResult as! PHFetchResult<AnyObject>, label: self.albums[indexPath.row].name)
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! TGPhotoListCell
        cell.asset = self.albums[indexPath.row].fetchResult.firstObject as? PHAsset
        cell.albumTitleAndCount = (TGPhotoPickerConfig.shared.useChineseAlbumName ?
                TGPhotoPickerConfig.getChineseAlbumName(self.albums[indexPath.row].assetType,self.albums[indexPath.row].name) :
                self.albums[indexPath.row].name,
                                       self.albums[indexPath.row].fetchResult.count)
        return cell
    }
 
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let layout = TGPhotoCollectionVC.configCustomCollectionLayout()
        let vc = TGPhotoCollectionVC(collectionViewLayout: layout)
        vc.navigationItem.title = TGPhotoPickerConfig.shared.useChineseAlbumName ? TGPhotoPickerConfig.getChineseAlbumName(self.albums[indexPath.row].assetType,self.albums[indexPath.row].name) : self.albums[indexPath.row].name
        vc.fetchResult = albums[indexPath.row].fetchResult as? PHFetchResult<PHAsset>
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension TGPhotoListVC : PHPhotoLibraryChangeObserver{
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        loadAlbums(true)
    }
}
