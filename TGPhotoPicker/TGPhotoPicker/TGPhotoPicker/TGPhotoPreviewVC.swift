//
//  TGPhotoPreviewVC.swift
//  TGPhotoPicker
//
//  Created by targetcloud on 2017/7/19.
//  Copyright © 2017年 targetcloud. All rights reserved.
//

import UIKit

protocol TGPhotoPreviewDelegate:class {
    func removeElement(element: TGPhotoM?)
}

private let cellIdentifier = "TGPhotoPreviewCell"

class TGPhotoPreviewVC: UIViewController {

    var selectImages = [TGPhotoM]()
    var currentPage: Int = 0
    weak var delegate: TGPhotoPreviewDelegate?
    
    private var cv: UICollectionView?
    
    fileprivate var isStatusBarHidden = false{
        didSet{
            self.setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updatePageTitle()
        self.cv?.setContentOffset(CGPoint(x: CGFloat(self.currentPage) * self.view.bounds.width, y: 0), animated: false)
    }
    
    private func setupUI(){
        setupNavigationBar()
        setupCollectionView()
    }
    
    private func setupNavigationBar(){
        UIApplication.shared.statusBarStyle = .lightContent
        self.navigationController?.navigationBar.barStyle = .black
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage.size(width: 1, height: 1).color(TGPhotoPickerConfig.shared.barBGColor).image, for: UIBarMetrics.default)
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
            }), style: .plain, target: self, action: #selector(dissmiss))
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage.size(width: 20, height: 20)
            .color(.clear)
            .image
            .with({ context in
                context.setLineCap(.round)
                UIColor.white.setStroke()
                context.setLineWidth(TGPhotoPickerConfig.shared.checkboxLineW)
                context.move(to: CGPoint(x: 7, y: 3))
                context.addLine(to: CGPoint(x: 13, y: 3))
                context.move(to: CGPoint(x: 3, y: 4))
                context.addLine(to: CGPoint(x: 17, y: 4))
                context.move(to: CGPoint(x: 4, y: 18))
                context.addLine(to: CGPoint(x: 16, y: 18))
                
                context.move(to: CGPoint(x: 4, y: 5))
                context.addLine(to: CGPoint(x: 4, y: 17))
                
                context.move(to: CGPoint(x: 8, y: 7))
                context.addLine(to: CGPoint(x: 8, y: 14))
                
                context.move(to: CGPoint(x: 12, y: 7))
                context.addLine(to: CGPoint(x: 12, y: 14))
                
                context.move(to: CGPoint(x: 16, y: 5))
                context.addLine(to: CGPoint(x: 16, y: 17))
                context.strokePath()
            }), style: .plain, target: self, action: #selector(remove))
    }
    
    @objc private func dissmiss(){
        let animation = CATransition()
        animation.duration = 0.2
        animation.subtype = kCATransitionFromRight
        UIApplication.shared.keyWindow?.layer.add(animation, forKey: nil)
        dismiss(animated: false, completion: nil)
    }
    
    @objc private func remove(){
        delegate?.removeElement(element: self.selectImages.remove(at: currentPage))
        updatePageTitle()
        self.cv?.deselectItem(at: IndexPath(row: currentPage, section: 0), animated: true)
        
        if self.selectImages.count > 0{
            self.currentPage = self.currentPage > self.selectImages.count - 1 ? (self.selectImages.count - 1) : self.currentPage
            self.cv?.reloadData()
        } else {
            _ = self.navigationController?.popViewController(animated: true)
            dissmiss()
        }
    }
    
    private func setupCollectionView(){
        self.automaticallyAdjustsScrollViewInsets = false
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width:self.view.frame.width,height: self.view.frame.height)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        
        self.cv = UICollectionView(frame: self.view.bounds, collectionViewLayout: layout)
        self.cv!.dataSource = self
        self.cv!.delegate = self
        self.cv!.isPagingEnabled = true
        self.cv!.scrollsToTop = false
        self.cv!.showsHorizontalScrollIndicator = false
        self.cv!.contentOffset = CGPoint.zero
        self.cv!.contentSize = CGSize(width: self.view.bounds.width * CGFloat(self.selectImages.count), height: self.view.bounds.height)
        self.cv!.register(TGPhotoPreviewCell.self, forCellWithReuseIdentifier: cellIdentifier)
        self.view.addSubview(self.cv!)
    }
    
    fileprivate func updatePageTitle(){
        self.title =  String(self.currentPage+1) + "/" + String(self.selectImages.count)
    }

}

extension TGPhotoPreviewVC : UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.selectImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! TGPhotoPreviewCell
        cell.delegate = self
        if let asset = self.selectImages[indexPath.row].asset {
            cell.asset = asset
        }else{
            cell.image = self.selectImages[indexPath.row].bigImage
        }
        return cell
    }
}

extension TGPhotoPreviewVC : UICollectionViewDelegate{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.currentPage = Int(scrollView.contentOffset.x / self.view.bounds.width)
        updatePageTitle()
    }
}

extension TGPhotoPreviewVC : TGPhotoPreviewCellDelegate{
    override var prefersStatusBarHidden: Bool{
        return self.isStatusBarHidden
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .slide
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func onImageSingleTap() {
        if #available(iOS 9.0, *) {
            self.isStatusBarHidden = !self.isStatusBarHidden
            let isVCBased = Bundle.main.infoDictionary?["UIViewControllerBasedStatusBarAppearance"] as? Bool ?? false
            if !isVCBased{
                UIApplication.shared.setStatusBarHidden(self.isStatusBarHidden, with: .slide)
            }
            self.navigationController?.setNavigationBarHidden(self.isStatusBarHidden, animated: true)
        }else {
            let status = !UIApplication.shared.isStatusBarHidden
            UIApplication.shared.setStatusBarHidden(status, with: .slide)
            self.navigationController?.setNavigationBarHidden(status, animated: true)
        }
    }
}
