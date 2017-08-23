//
//  TGTopBar.swift
//  TGPhotoPicker
//
//  Created by targetcloud on 2017/7/22.
//  Copyright © 2017年 targetcloud. All rights reserved.
//

import UIKit

protocol TGTopBarDelegate: class {
    func onBackClicked()
    func onSelectedClicked(select:Bool)
}

class TGTopBar: UIView {

    weak var delegate: TGTopBarDelegate?
    weak var source: TGAlbumPhotoPreviewVC?
    weak var nav: TGPhotoPickerVC?
    var selectNum = 0
    
    private var checkboxSelect: UIImageView?
    private var checkbox: UIButton?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }
    
    func setSelect(_ select:Bool,_ showOrder: Int = -1){
        if showOrder >= 0{
            checkboxSelect?.image = TGPhotoPickerConfig.shared.cacheNumerImageForBarArr[showOrder]
        }
        self.checkboxSelect!.isHidden = !select
        self.checkbox!.isSelected = select
    }
    
    private func setupUI(){
        self.backgroundColor = TGPhotoPickerConfig.shared.barBGColor
        
        let WH = TGPhotoPickerConfig.shared.checkboxBarWH * 0.8
        
        let backBtn = UIButton(frame: CGRect(x: TGPhotoPickerConfig.shared.padding + 3, y: (self.bounds.height - WH) / 2, width: WH, height: WH))
        
        backBtn.setImage(UIImage.size(width: WH, height: WH)
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
                
//                context.move(to: CGPoint(x: 17, y: 7))
//                context.addLine(to: CGPoint(x: 10, y: 15))
//                context.move(to: CGPoint(x: 10, y: 15))
//                context.addLine(to: CGPoint(x: 17, y: 23))
                context.strokePath()
            }), for: UIControlState.normal)//config
        backBtn.addTarget(self, action: #selector(back), for: .touchUpInside)
        self.addSubview(backBtn)
        
        let checkboxX = self.bounds.width - TGPhotoPickerConfig.shared.checkboxBarWH - TGPhotoPickerConfig.shared.padding * 2
        let checkboxY = (self.bounds.height - TGPhotoPickerConfig.shared.checkboxBarWH) / 2
        self.checkbox = UIButton(type: .custom)
        checkbox!.frame = CGRect(x:checkboxX,y: checkboxY,width: TGPhotoPickerConfig.shared.checkboxBarWH,height: TGPhotoPickerConfig.shared.checkboxBarWH)
        checkbox!.addTarget(self, action: #selector(check(sender:)), for: .touchUpInside)
        
        let imageTuples = TGPhotoPickerConfig.shared.getCheckboxImage(false,false,.circle)
        let checkboxUnselect = UIImageView(image: imageTuples.unselect)
        checkboxUnselect.contentMode = .scaleAspectFit
        checkboxUnselect.frame = checkbox!.bounds
        checkbox!.addSubview(checkboxUnselect)
        
        self.checkboxSelect = UIImageView(image: imageTuples.select)
        checkboxSelect!.contentMode = .scaleAspectFit
        checkboxSelect!.frame = checkbox!.bounds
        checkboxSelect!.isHidden = true
        self.checkbox!.addSubview(checkboxSelect!)
        
        self.addSubview(checkbox!)
    }
    
    @objc private func back(){
        delegate?.onBackClicked()
    }
    
    @objc private func check(sender: UIButton){
        if sender.isSelected {
            sender.isSelected = false
            self.checkboxSelect!.isHidden = true
            self.delegate?.onSelectedClicked(select: false)
        } else {
            if let _ = self.source {//预览模式下
                if (nav?.assetArr.count)! >= TGPhotoPickerConfig.shared.maxImageCount - (nav?.alreadySelectedImageNum)! {
                    return self.showSelectErrorDialog()
                }
            }
            sender.isSelected = true
            self.checkboxSelect!.isHidden = false
            if TGPhotoPickerConfig.shared.checkboxAnimate {
                self.checkboxSelect!.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
                UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 8, options: [UIViewAnimationOptions.curveEaseIn], animations: {
                    self.checkboxSelect!.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
                }, completion: { _ in
                    UIView.animate(withDuration: 0.25, animations: {
                        self.checkboxSelect!.transform = CGAffineTransform.identity
                    })
                })
            }
            self.delegate?.onSelectedClicked(select: true)
            if TGPhotoPickerConfig.shared.isShowNumber{
                checkboxSelect?.image = TGPhotoPickerConfig.shared.cacheNumerImageForBarArr[(nav?.assetArr.count)! - 1]
            }
        }
    }
    
    private func showSelectErrorDialog() {
        if self.source != nil {
            let less = TGPhotoPickerConfig.shared.maxImageCount - selectNum
            let range = TGPhotoPickerConfig.shared.errorImageMaxSelect.range(of:"#")
            var error = TGPhotoPickerConfig.shared.errorImageMaxSelect
            error.replaceSubrange(range!, with: String(less))
            let alert = UIAlertController(title: nil, message: (selectNum > 0 ? TGPhotoPickerConfig.shared.leftTitle : "") + error, preferredStyle: UIAlertControllerStyle.alert)
            let confirmAction = UIAlertAction(title: TGPhotoPickerConfig.shared.confirmTitle, style: .default, handler: nil)
            alert.addAction(confirmAction)
            self.source?.present(alert, animated: true, completion: nil)
        }
    }
}
