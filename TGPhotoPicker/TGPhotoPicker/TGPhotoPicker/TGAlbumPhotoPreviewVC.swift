//
//  TGAlbumPhotoPreviewVC.swift
//  TGPhotoPicker
//
//  Created by targetcloud on 2017/7/22.
//  Copyright © 2017年 targetcloud. All rights reserved.
//

import UIKit
import Photos

private let cellID = "TGPhotoPreviewCell"

protocol TGPhotoCollectionDelegate:class {
    func onPreviewPageBack()
}

class TGAlbumPhotoPreviewVC: UIViewController {

    var fetchResult: PHFetchResult<PHAsset>?
    var currentPage: Int = 0
    weak var delegate: TGPhotoCollectionDelegate?
    
    fileprivate var isAnimation = false
    fileprivate var topBar: TGTopBar?
    fileprivate var bottomBar: TGBottomBar?
    fileprivate var indicatorLabel: UILabel?
    
    fileprivate lazy var nav: TGPhotoPickerVC = self.navigationController as! TGPhotoPickerVC
    
    fileprivate lazy var cv: UICollectionView = {
        self.automaticallyAdjustsScrollViewInsets = false
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: self.view.frame.width,height: self.view.frame.height)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        
        let collectionView = UICollectionView(frame: self.view.bounds, collectionViewLayout: layout)
        collectionView.backgroundColor = .black
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.isPagingEnabled = true
        collectionView.scrollsToTop = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.contentOffset = CGPoint.zero
        collectionView.contentSize = CGSize(width: self.view.bounds.width * CGFloat(self.fetchResult!.count), height: self.view.bounds.height)
        collectionView.register(TGPhotoPreviewCell.self, forCellWithReuseIdentifier: cellID)
        self.view.addSubview(collectionView)
        
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.cv.reloadData()
        setupBar()
        
        if TGPhotoPickerConfig.shared.isShowIndicator && (TGPhotoPickerConfig.shared.indicatorPosition != .inBottomBar){
            indicatorLabel = (bottomBar?.indicatorLabel)!
            switch TGPhotoPickerConfig.shared.indicatorPosition {
            case .top:
                self.view.addSubview(indicatorLabel!)
                indicatorLabel?.origin = CGPoint(x: (TGPhotoPickerConfig.ScreenW - (bottomBar?.indicatorLabel.w)!)/2, y: (topBar?.frame.maxY)! - (indicatorLabel?.h)! + 5)
            case .bottom:
                self.view.addSubview(indicatorLabel!)
                indicatorLabel?.origin = CGPoint(x: (TGPhotoPickerConfig.ScreenW - (bottomBar?.indicatorLabel.w)!)/2, y: (bottomBar?.y)! - (indicatorLabel?.h)! - 5)
            default:
                self.topBar?.addSubview(indicatorLabel!)
                indicatorLabel?.origin = CGPoint(x: (TGPhotoPickerConfig.ScreenW - (bottomBar?.indicatorLabel.w)!)/2, y: ((topBar?.h)! - (indicatorLabel?.h)!)/2)
            }
            indicatorLabel?.isHidden = false
        }
    }

    override var prefersStatusBarHidden: Bool{
        return true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        
        if #available(iOS 9.0, *) {
            let isVCBased = Bundle.main.infoDictionary?["UIViewControllerBasedStatusBarAppearance"] as? Bool ?? false
            if !isVCBased{
                UIApplication.shared.setStatusBarHidden(true, with: .none)
            }
        }else {
            UIApplication.shared.setStatusBarHidden(true, with: .none)
        }
        
        self.cv.setContentOffset(CGPoint(x: CGFloat(self.currentPage) * self.view.bounds.width, y: 0), animated: false)
        changeCurrentToolbar()
    }

    fileprivate func changeCurrentToolbar(){
        if let order = nav.assetArr.index(of: self.fetchResult![self.currentPage]){
            self.topBar!.setSelect(true,TGPhotoPickerConfig.shared.isShowNumber ? order : -1)
            self.bottomBar?.canEdit(true)
        } else {
            self.topBar!.setSelect(false)
            self.bottomBar?.canEdit(false)
        }
    }
    
    private func setupBar(){
        self.topBar = TGTopBar(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: TGPhotoPickerConfig.shared.toolBarH))
        topBar?.nav = self.nav
        topBar?.selectNum = self.nav.alreadySelectedImageNum
        topBar?.delegate = self
        topBar?.source = self
        
        let positionY = self.view.bounds.height - TGPhotoPickerConfig.shared.toolBarH
        self.bottomBar = TGBottomBar(frame: CGRect(x: 0,y: positionY,width: self.view.bounds.width,height: TGPhotoPickerConfig.shared.toolBarH))
        self.bottomBar?.delegate = self
        self.bottomBar?.changeNumber(number: nav.assetArr.count, animation: false)
        
        self.view.addSubview(topBar!)
        self.view.addSubview(bottomBar!)
        bottomBar?.nav = nav
        bottomBar?.host = "\(type(of: self))"
    }
}

extension TGAlbumPhotoPreviewVC: TGBottomBarDelegate{
    func onDoneButtonClicked() {
        self.nav.imageSelectFinish()
    }
    
    func onEditButtonClicked(_ sender:TGAnimationButton){
        
    }
}

extension TGAlbumPhotoPreviewVC: TGTopBarDelegate{
    func onBackClicked() {
        self.navigationController?.popViewController(animated: true)
        self.delegate?.onPreviewPageBack()
    }
    
    func onSelectedClicked(select: Bool) {
        if select {
            self.nav.assetArr.append(self.fetchResult![self.currentPage] )
        } else {
            if let index = self.nav.assetArr.index(of: self.fetchResult![self.currentPage] ){
                self.nav.assetArr.remove(at: index)
            }
        }
        self.bottomBar?.canEdit(select)
        self.bottomBar?.changeNumber(number: self.nav.assetArr.count, animation: TGPhotoPickerConfig.shared.checkboxAnimate)
    }
}

extension TGAlbumPhotoPreviewVC: UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.fetchResult?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! TGPhotoPreviewCell
        cell.delegate = self
        cell.asset = self.fetchResult![indexPath.row]
        return cell
    }
}

extension TGAlbumPhotoPreviewVC: TGPhotoPreviewCellDelegate{
    func onImageSingleTap() {
        if self.isAnimation {
            return
        }
        self.isAnimation = true
        if self.topBar!.frame.origin.y < 0 {
            UIView.animate(withDuration: 0.3, delay: 0, options: [UIViewAnimationOptions.curveEaseOut], animations: {
                self.topBar!.frame.origin = CGPoint.zero
                var originPoint = self.bottomBar!.frame.origin
                originPoint.y = originPoint.y - self.bottomBar!.frame.height
                self.bottomBar!.frame.origin = originPoint
                if TGPhotoPickerConfig.shared.indicatorPosition == .top{
                    self.indicatorLabel?.y = (self.topBar?.frame.maxY)! + 5
                }
                if TGPhotoPickerConfig.shared.indicatorPosition == .bottom{
                    self.indicatorLabel?.bottom = (self.bottomBar?.y)! - 5
                }
            }, completion: { isFinished in
                if isFinished {
                    self.isAnimation = false
                }
            })
        } else {
            UIView.animate(withDuration: 0.3, delay: 0, options: [UIViewAnimationOptions.curveEaseOut], animations: {
                self.topBar!.frame.origin = CGPoint(x:0, y: -self.topBar!.frame.height)
                var originPoint = self.bottomBar!.frame.origin
                originPoint.y = originPoint.y + self.bottomBar!.frame.height
                self.bottomBar!.frame.origin = originPoint
                if TGPhotoPickerConfig.shared.indicatorPosition == .top{
                    self.indicatorLabel?.y = (self.topBar?.frame.maxY)! + 5
                }
                if TGPhotoPickerConfig.shared.indicatorPosition == .bottom{
                    self.indicatorLabel?.bottom = (self.bottomBar?.y)! - 5
                }
            }, completion: { isFinished in
                if isFinished {
                    self.isAnimation = false
                }
            })
        }
    }
}

extension TGAlbumPhotoPreviewVC: UICollectionViewDelegate{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.currentPage = Int(scrollView.contentOffset.x / self.view.bounds.width)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        changeCurrentToolbar()
    }
}
