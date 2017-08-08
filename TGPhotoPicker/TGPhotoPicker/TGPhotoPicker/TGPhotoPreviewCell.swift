//
//  TGPhotoPreviewCell.swift
//  TGPhotoPicker
//
//  Created by targetcloud on 2017/7/19.
//  Copyright © 2017年 targetcloud. All rights reserved.
//

import UIKit
import Photos

protocol TGPhotoPreviewCellDelegate: class{
    func onImageSingleTap()
}

class TGPhotoPreviewCell: UICollectionViewCell {
    var asset: PHAsset?{
        didSet{
            let photoImageManager = TGPhotoImageManager()
            photoImageManager.getPhotoByMaxSize(asset: asset!, size: self.bounds.width) { (image, data, info) -> Void in
                self.imageView.image = image
                self.resizeImageView()
            }
        }
    }
    
    var image: UIImage?{
        didSet{
            self.imageView.image = image
            self.resizeImageView()
        }
    }
    
    weak var delegate: TGPhotoPreviewCellDelegate?
    
    fileprivate var imageContainerView = UIView()
    private var imageView = UIImageView()
    private var scrollView: UIScrollView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }
    
    private func setupUI() {
        self.scrollView = UIScrollView(frame: self.bounds)
        //self.scrollView!.bouncesZoom = true// default is YES. if set, user can go past min/max zoom while gesturing and the zoom will animate to the min/max value at gesture end
        self.scrollView!.maximumZoomScale = 2.5
        self.scrollView!.isMultipleTouchEnabled = true
        self.scrollView!.delegate = self
        self.scrollView!.scrollsToTop = false
        self.scrollView!.showsHorizontalScrollIndicator = false
        self.scrollView!.showsVerticalScrollIndicator = false
        self.scrollView!.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.scrollView!.delaysContentTouches = false// default is YES. if NO, we immediately call -touchesShouldBegin:withEvent:inContentView:. this has no effect on presses
        //self.scrollView!.canCancelContentTouches = true// default is YES. if NO, then once we start tracking, we don't try to drag if the touch moves. this has no effect on presses
        //self.scrollView!.alwaysBounceVertical = false// default NO. if YES and bounces is YES, even if content is smaller than bounds, allow drag vertically
        self.addSubview(self.scrollView!)
        
        self.imageContainerView.clipsToBounds = true
        self.scrollView!.addSubview(self.imageContainerView)
        
        self.imageView.backgroundColor = UIColor(white: 1.0, alpha: 0.5)
        self.imageView.clipsToBounds = true
        self.imageContainerView.addSubview(self.imageView)
        
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(self.singleTap(tap:)))
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(self.doubleTap(tap:)))
        
        doubleTap.numberOfTapsRequired = 2
        singleTap.require(toFail: doubleTap)
        
        self.addGestureRecognizer(singleTap)
        self.addGestureRecognizer(doubleTap)
    }
    
    private func resizeImageView() {
        self.imageContainerView.frame = CGRect(x:0, y:0, width: self.frame.width, height: self.imageContainerView.bounds.height)
        let image = self.imageView.image!
        
        if image.size.height / image.size.width > self.bounds.height / self.bounds.width {
            var originFrame = self.imageContainerView.frame
            originFrame.size.height = floor((image.size.height / image.size.width) * self.bounds.width)
            self.imageContainerView.frame = originFrame
        } else {
            var height = (image.size.height / image.size.width) * self.frame.width
            if height < 1 || height.isNaN {
                height = self.frame.height
            }
            var originFrame = self.imageContainerView.frame
            originFrame.size.height = floor(height)
            self.imageContainerView.frame = originFrame
            self.imageContainerView.center = CGPoint(x:self.imageContainerView.center.x, y:self.bounds.height / 2)
        }
        
        if self.imageContainerView.frame.height > self.frame.height && self.imageContainerView.frame.height - self.frame.height <= 1 {
            var originFrame = self.imageContainerView.frame
            originFrame.size.height = self.frame.height
            self.imageContainerView.frame = originFrame
        }
        
        self.scrollView?.contentSize = CGSize(width: self.frame.width, height: max(self.imageContainerView.frame.height, self.frame.height))
        self.scrollView?.scrollRectToVisible(self.bounds, animated: false)
        self.scrollView?.alwaysBounceVertical = self.imageContainerView.frame.height > self.frame.height
        self.imageView.frame = self.imageContainerView.bounds
    }
    
    @objc private func singleTap(tap:UITapGestureRecognizer) {
        delegate?.onImageSingleTap()
    }
    
    @objc private func doubleTap(tap:UITapGestureRecognizer) {
        if (self.scrollView!.zoomScale > 1.0) {
            self.scrollView?.setZoomScale(1.0, animated: true)
        } else {
            let touchPoint = tap.location(in: self.imageView)
            let zoomScale = self.scrollView?.maximumZoomScale
            let w = self.frame.size.width / zoomScale!
            let h = self.frame.size.height / zoomScale!
            self.scrollView?.zoom(to: CGRect(x: touchPoint.x - w/2, y: touchPoint.y - h/2, width: w, height: h), animated: true)
        }
    }
}

extension TGPhotoPreviewCell: UIScrollViewDelegate{
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageContainerView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        let offsetX = (scrollView.frame.width > scrollView.contentSize.width) ? (scrollView.frame.width - scrollView.contentSize.width) * 0.5 : 0.0
        let offsetY = (scrollView.frame.height > scrollView.contentSize.height) ? (scrollView.frame.height - scrollView.contentSize.height) * 0.5 : 0.0
        self.imageContainerView.center = CGPoint(x: scrollView.contentSize.width * 0.5 + offsetX, y: scrollView.contentSize.height * 0.5 + offsetY)
    }
}
