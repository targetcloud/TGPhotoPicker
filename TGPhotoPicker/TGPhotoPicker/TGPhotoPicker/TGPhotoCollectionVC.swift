//
//  TGPhotoCollectionVC.swift
//  TGPhotoPicker
//
//  Created by targetcloud on 2017/7/22.
//  Copyright © 2017年 targetcloud. All rights reserved.
//

import UIKit
import Photos

private let reuseIdentifier = "TGPhotoCell"

protocol TGPhotoCollectionViewCellDelegate: class {
    func selectNumberChange(number: Int,isRemove: Bool,forceRefresh: Bool)
}

class TGPhotoCell: UICollectionViewCell {
    weak var delegate: TGPhotoCollectionViewCellDelegate?
    weak var vc: UIViewController?
    weak var nav: TGPhotoPickerVC?
    var model : PHAsset?
    var assetId: String?
    var indexPath: IndexPath?
    
    var itemWH:CGFloat{
        return (TGPhotoPickerConfig.ScreenW - (TGPhotoPickerConfig.shared.colCount + (TGPhotoPickerConfig.shared.leftAndRigthNoPadding ? -1 : 1)) * TGPhotoPickerConfig.shared.padding) / TGPhotoPickerConfig.shared.colCount
    }
    
    var photoSelectedIndex: Int = -1{
        didSet{
            if photoSelectedIndex > -1{
                if TGPhotoPickerConfig.shared.isShowNumber{
                    if let cacheImage = getCacheImage(photoSelectedIndex){
                        selectBtn.setImage(cacheImage, for: .selected)
                    }
                }else{
                    selectBtn.setImage(selectedImage, for: .selected)
                }
            }
            selectBtn.isSelected = photoSelectedIndex > -1
        }
    }
    
    var isMaskHidden: Bool = true{
        didSet{
            self.maskV.isHidden = isMaskHidden
        }
    }
    
    var isSelectMaskHidden: Bool = true{
        didSet{
            self.selectMaskV.isHidden = isSelectMaskHidden
        }
    }
    
    var image: UIImage?{
        didSet{
            photoImage.image = image
        }
    }
    
    public func immediateSelect(){
        selectClicked(selectBtn)
    }
    
    private var selectedImage: UIImage?
    
    @objc private func selectClicked(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if nav == nil {
            nav = vc?.navigationController as? TGPhotoPickerVC
        }
        if !sender.isSelected {
            if vc != nil {
                selectMaskV.isHidden = true
                nav?.assetArr.remove(at: (nav?.assetArr.index(of: self.model!))!)
                self.delegate?.selectNumberChange(number: (nav?.assetArr.count)!,isRemove: true, forceRefresh: false)
            }
        } else {
            if vc != nil {
                if (nav?.assetArr.count)! >= TGPhotoPickerConfig.shared.maxImageCount - (nav?.alreadySelectedImageNum)! {
                    sender.isSelected = false
                    return self.showSelectErrorDialog()
                } else {
                    selectMaskV.isHidden = !TGPhotoPickerConfig.shared.useSelectMask
                    nav?.assetArr.append(self.model!)
                    if TGPhotoPickerConfig.shared.isShowNumber{
                        if let cacheImage = getCacheImage((nav?.assetArr.count)! - 1){
                            selectBtn.setImage(cacheImage, for: .selected)
                        }
                    }else{
                        selectBtn.setImage(selectedImage, for: .selected)
                    }
                    if TGPhotoPickerConfig.shared.checkboxAnimate{
                        selectBtn.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
                        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.3, initialSpringVelocity: 10, options: UIViewAnimationOptions.curveEaseIn, animations: {
                            self.selectBtn.transform = CGAffineTransform.identity
                        }, completion: nil)
                    }
                    self.delegate?.selectNumberChange(number: (nav?.assetArr.count)!,isRemove: false, forceRefresh: false)
                }
            }
        }
    }
    
    private func getCacheImage(_ index: Int) -> UIImage?{
        if TGPhotoPickerConfig.shared.cacheNumerImageArr.count > 0 &&
            index >= 0 &&
            index < TGPhotoPickerConfig.shared.cacheNumerImageArr.count{
            return TGPhotoPickerConfig.shared.cacheNumerImageArr[index]
        }
        return nil
    }
    
    private func showSelectErrorDialog() {
        if self.vc != nil {
            let less = TGPhotoPickerConfig.shared.maxImageCount - (nav?.alreadySelectedImageNum)!
            let range = TGPhotoPickerConfig.shared.errorImageMaxSelect.range(of:"#")
            var error = TGPhotoPickerConfig.shared.errorImageMaxSelect
            error.replaceSubrange(range!, with: String(less))
            let alert = UIAlertController(title: nil, message: ((nav?.alreadySelectedImageNum)! > 0 ? TGPhotoPickerConfig.shared.leftTitle : "") + error, preferredStyle: UIAlertControllerStyle.alert)
            let confirmAction = UIAlertAction(title:TGPhotoPickerConfig.shared.confirmTitle, style: .default, handler: nil)
            alert.addAction(confirmAction)
            self.vc?.present(alert, animated: true, completion: nil)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(self.photoImage)
        contentView.addSubview(self.maskV)
        contentView.addSubview(self.selectMaskV)
        contentView.addSubview(self.selectBtn)
    }
    
    private lazy var maskV: UIView = {
        let mask = UIView(frame: CGRect(x: 0, y: 0, width: self.itemWH, height: self.itemWH))
        mask.backgroundColor = UIColor.white.withAlphaComponent(TGPhotoPickerConfig.shared.maskAlpha)
        mask.isHidden = true
        return mask
    }()
    
    private lazy var selectMaskV: UIView = {
        let mask = UIView(frame: CGRect(x: 0, y: 0, width: self.itemWH, height: self.itemWH))
        mask.backgroundColor = UIColor.black.withAlphaComponent(TGPhotoPickerConfig.shared.maskAlpha)
        mask.isHidden = true
        return mask
    }()
    
    private lazy var photoImage: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.frame = CGRect(x: 0, y: 0, width: self.itemWH, height: self.itemWH)
        iv.clipsToBounds = true
        return iv
    }()
    
    private lazy var selectBtn: UIButton = {
        let btn = UIButton()
        let imageTuples = TGPhotoPickerConfig.shared.getCheckboxImage()
        self.selectedImage = imageTuples.select
        var x:CGFloat = 0
        var y:CGFloat = 0
        switch TGPhotoPickerConfig.shared.checkboxPosition {
        case .topLeft:
            break
        case .topRight:
            x = self.itemWH - imageTuples.size.width
        case .bottomLeft:
            y = self.itemWH - imageTuples.size.height
        case .bottomRight:
            x = self.itemWH - imageTuples.size.width
            y = self.itemWH - imageTuples.size.height
        }
        btn.frame = CGRect(x: x, y: y, width: imageTuples.size.width, height: imageTuples.size.height)
        btn.addTarget(self, action: #selector(selectClicked), for: .touchUpInside)
        btn.setImage(imageTuples.unselect, for: .normal)
        btn.setImage(imageTuples.select, for: .selected)
        return btn
    }()
}

class TGPhotoCollectionVC: UICollectionViewController {

    var fetchResult: PHFetchResult<PHAsset>?
    
    fileprivate lazy var imageManager = PHCachingImageManager()
    
    fileprivate lazy var assetGridThumbnailSize: CGSize = {
        let cellSize = (self.collectionViewLayout as! UICollectionViewFlowLayout).itemSize
        let size = cellSize.width * UIScreen.main.scale
        return CGSize(width: size, height: size)
    }()
    
    fileprivate lazy var nav: TGPhotoPickerVC = self.navigationController as! TGPhotoPickerVC
    
    fileprivate lazy var bottomBar: TGBottomBar = {
        let subtractH: CGFloat = ((TGPhotoPickerConfig.shared.barBGColor.getAlpha()) != 1) ? 0 : 64
        let toolbar = TGBottomBar(frame: CGRect(x:0,y: TGPhotoPickerConfig.ScreenH - TGPhotoPickerConfig.shared.toolBarH - subtractH,width: TGPhotoPickerConfig.ScreenW,height: TGPhotoPickerConfig.shared.toolBarH))
        toolbar.delegate = self
        if self.nav.assetArr.count > 0 {
            toolbar.changeNumber(number: self.nav.assetArr.count, animation: false)
        }
        return toolbar
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        setupUI()
        PHPhotoLibrary.shared().register(self)
        
        if fetchResult == nil {
            fetchResult = PHAsset.fetchAssets(with: TGPhotoFetchOptions()) 
        }
    }
    
    deinit{
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
    
    override var prefersStatusBarHidden: Bool{
        return false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
        
        if #available(iOS 9.0, *) {
            let isVCBased = Bundle.main.infoDictionary?["UIViewControllerBasedStatusBarAppearance"] as? Bool ?? false
            if !isVCBased{
                UIApplication.shared.setStatusBarHidden(false, with: .none)
            }
        }else {
            UIApplication.shared.setStatusBarHidden(false, with: .none)
        }
    
        self.collectionView?.reloadData()
        selectNumberChange(number: self.nav.assetArr.count)
    }
    
    private func setupUI(){
        setupNavigationBar()
        let originFrame = self.collectionView!.frame
        self.collectionView!.frame = CGRect(x:originFrame.origin.x, y:originFrame.origin.y, width:originFrame.size.width, height: originFrame.height - ((TGPhotoPickerConfig.shared.barBGColor.getAlpha() != 1) ? 0 : TGPhotoPickerConfig.shared.toolBarH))
        resetCacheAssets()
        self.collectionView?.contentInset = UIEdgeInsetsMake(
            TGPhotoPickerConfig.shared.padding,
            TGPhotoPickerConfig.shared.leftAndRigthNoPadding ? 0 : TGPhotoPickerConfig.shared.padding,
            TGPhotoPickerConfig.shared.padding + ((TGPhotoPickerConfig.shared.barBGColor.getAlpha() != 1) ? TGPhotoPickerConfig.shared.toolBarH : 0),
            TGPhotoPickerConfig.shared.leftAndRigthNoPadding ? 0 : TGPhotoPickerConfig.shared.padding
        )
        self.collectionView?.backgroundColor = .white
        self.collectionView?.register(TGPhotoCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        self.view.addSubview(self.bottomBar)
        bottomBar.host = "\(type(of: self))"
    }
    
    fileprivate func resetCacheAssets() {
        self.imageManager.stopCachingImagesForAllAssets()
    }
    
    private func setupNavigationBar(){
        self.navigationController?.navigationBar.barStyle = .black
        self.navigationController?.navigationBar.tintColor = .white
        
        let WH = TGPhotoPickerConfig.shared.checkboxBarWH * 0.8
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage.size(width: WH, height: WH)
            .corner(radius: WH * 0.5)
            .color(.clear)
            .border(color: UIColor.white.withAlphaComponent(0.7))
            .border(width: TGPhotoPickerConfig.shared.isShowBorder ? TGPhotoPickerConfig.shared.checkboxLineW : 0)
            .image
            .with({ context in
                context.setLineCap(.round)
                UIColor.white.setStroke()
                context.setLineWidth(TGPhotoPickerConfig.shared.checkboxLineW)
                context.move(to: CGPoint(x: WH * (TGPhotoPickerConfig.shared.isShowBorder ? 0.55 : 0.6), y: WH * (TGPhotoPickerConfig.shared.isShowBorder ? 0.25: 0.2)))
                context.addLine(to: CGPoint(x: WH * (TGPhotoPickerConfig.shared.isShowBorder ? 0.4 : 0.35), y: WH * 0.5))
                context.move(to: CGPoint(x: WH * (TGPhotoPickerConfig.shared.isShowBorder ? 0.4 : 0.35), y: WH * 0.5))
                context.addLine(to: CGPoint(x: WH * (TGPhotoPickerConfig.shared.isShowBorder ? 0.55 : 0.6), y: WH * (TGPhotoPickerConfig.shared.isShowBorder ? 0.75 : 0.8)))
//                context.move(to: CGPoint(x: 12, y: 4))
//                context.addLine(to: CGPoint(x: 7, y: 10))
//                context.move(to: CGPoint(x: 7, y: 10))
//                context.addLine(to: CGPoint(x: 12, y: 16))
                context.strokePath()
            }), style: .plain, target: self, action: #selector(back))
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: TGPhotoPickerConfig.shared.cancelTitle, style: UIBarButtonItemStyle.plain, target: self, action: #selector(cancel))
    }
    
    @objc private func back(){
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc private func cancel(){
        self.nav.assetArr.removeAll()
        self.navigationController?.dismiss(animated: true, completion: nil)
    }

    class func configCustomCollectionLayout() -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = TGPhotoPickerConfig.shared.padding
        layout.minimumLineSpacing = TGPhotoPickerConfig.shared.padding
        let itemWH:CGFloat = (TGPhotoPickerConfig.ScreenW - (TGPhotoPickerConfig.shared.colCount + (TGPhotoPickerConfig.shared.leftAndRigthNoPadding ? -1 : 1)) * TGPhotoPickerConfig.shared.padding) / TGPhotoPickerConfig.shared.colCount
        layout.itemSize = CGSize(width:itemWH, height: itemWH)
        return layout
    }

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.fetchResult?.count ?? 0
    }
    
    fileprivate func setupCell(_ cell: TGPhotoCell,_ asset: PHAsset){
        cell.photoSelectedIndex = self.nav.assetArr.index(of: asset) ?? -1
        cell.isMaskHidden = (cell.photoSelectedIndex > -1) ? true : (TGPhotoPickerConfig.shared.useSelectMask ? true : !(nav.assetArr.count >= TGPhotoPickerConfig.shared.maxImageCount))
        cell.isSelectMaskHidden = TGPhotoPickerConfig.shared.useSelectMask ? !(cell.photoSelectedIndex > -1) : true
        cell.model = asset
        cell.delegate = self
        cell.vc = self
        cell.nav = self.nav
        cell.assetId = asset.localIdentifier
        
        self.imageManager.requestImage(for: asset, targetSize: self.assetGridThumbnailSize, contentMode: .aspectFill, options: nil) { image, info in
            if cell.assetId == asset.localIdentifier {
                DispatchQueue.main.async {
                    cell.image = image
                }
            }
        }
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! TGPhotoCell
        cell.indexPath = indexPath
        setupCell(cell,self.fetchResult![indexPath.row])
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if TGPhotoPickerConfig.shared.immediateTapSelect{
            if let cell = collectionView.cellForItem(at: indexPath) as? TGPhotoCell{
                cell.immediateSelect()
            }
            return
        }
        let previewvc = TGAlbumPhotoPreviewVC()
        previewvc.fetchResult = self.fetchResult
        previewvc.currentPage = indexPath.row
        previewvc.delegate = self
        self.navigationController?.show(previewvc, sender: nil)
    }

}

extension TGPhotoCollectionVC: TGBottomBarDelegate{
    func onDoneButtonClicked(){
        self.nav.imageSelectFinish()
    }
    
    func onOriginalButtonClicked(_ sender:TGAnimationButton){
        sender.isSelected = !sender.isSelected
    }
    
    func onPreviewButtonClicked(_ sender:TGAnimationButton){
        let previewvc = TGAlbumPhotoPreviewVC()
        previewvc.fetchResult = self.fetchResult
        previewvc.currentPage = (self.fetchResult?.index(of: nav.assetArr[0]))!
        previewvc.delegate = self
        self.navigationController?.show(previewvc, sender: nil)
    }
    
    func onReselectButtonClicked(_ sender:TGAnimationButton){
        nav.assetArr.removeAll()
        selectNumberChange(number: (nav.assetArr.count),forceRefresh: true)
    }
}

extension TGPhotoCollectionVC: TGPhotoCollectionDelegate{
    func onPreviewPageBack() {
        self.collectionView?.reloadData()
        self.selectNumberChange(number: self.nav.assetArr.count)
    }
}

extension TGPhotoCollectionVC: PHPhotoLibraryChangeObserver{
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        if let collectionChanges = changeInstance.changeDetails(for: fetchResult!) {
            DispatchQueue.main.async {
                self.fetchResult = collectionChanges.fetchResultAfterChanges
                if (collectionChanges.hasIncrementalChanges || collectionChanges.hasMoves) {
                    self.collectionView?.reloadData()
                }
                self.resetCacheAssets()
            }
        }
    }
}

extension TGPhotoCollectionVC: TGPhotoCollectionViewCellDelegate{
    func selectNumberChange(number: Int,isRemove: Bool = false,forceRefresh: Bool = false) {
        if forceRefresh ||
            (isRemove && TGPhotoPickerConfig.shared.isShowNumber) ||//是删除并显示数字的情况
            (!TGPhotoPickerConfig.shared.useSelectMask &&//反向显示遮罩的情况下并且
                                                          (number == TGPhotoPickerConfig.shared.maxImageCount ||//选择已经达到最多张数
                                                           (isRemove && (self.nav.assetArr.count == TGPhotoPickerConfig.shared.maxImageCount - 1))//最多张减1需要去掉反向显示的所有遮罩
                                                          )
            ){
            UIView.performWithoutAnimation {
                self.collectionView?.performBatchUpdates({ 
                    //self.collectionView?.reloadData()//performBatchUpdates不会重新调用reloadData，所以替换成手工调用
                    for i in 0 ..< (self.collectionView?.visibleCells.count ?? 0){
                        let cell = self.collectionView?.visibleCells[i] as! TGPhotoCell
                        self.setupCell(cell, self.fetchResult![(cell.indexPath?.row)!])
                    }
                }, completion: nil)
            }
        }
        self.bottomBar.changeNumber(number: number, animation: TGPhotoPickerConfig.shared.checkboxAnimate)
    }
}
