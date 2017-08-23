//
//  TGBottomBar.swift
//  TGPhotoPicker
//
//  Created by targetcloud on 2017/7/22.
//  Copyright © 2017年 targetcloud. All rights reserved.
//

import UIKit

@objc
protocol TGBottomBarDelegate:class{
    func onDoneButtonClicked()
    
    @objc optional
    func onOriginalButtonClicked(_ sender:TGAnimationButton)
    
    @objc optional
    func onPreviewButtonClicked(_ sender:TGAnimationButton)
    
    @objc optional
    func onReselectButtonClicked(_ sender:TGAnimationButton)
    
    @objc optional
    func onEditButtonClicked(_ sender:TGAnimationButton)
}

let padding = (TGPhotoPickerConfig.shared.padding * 2 > 10) ? 10 : (TGPhotoPickerConfig.shared.padding * 2 < 4 ? 4 : TGPhotoPickerConfig.shared.padding * 2)

class TGBottomBar: UIView {
    var host: String?{
        didSet{
            if host == ("\(type(of: TGPhotoCollectionVC.self))" as NSString).components(separatedBy: ".").first!{
                if TGPhotoPickerConfig.shared.isShowPreviewButton{
                    self.addSubview(previewButton)
                }
                
                if TGPhotoPickerConfig.shared.isShowReselect{
                    self.addSubview(reselectButton)
                }
                
                if TGPhotoPickerConfig.shared.isShowOriginal{
                    self.addSubview(originalButton)
                }
                
                var prevBtn:TGAnimationButton?
                for i in 0..<self.subviews.count{
                    if subviews[i].isKind(of: TGAnimationButton.self){
                        if prevBtn == nil {
                            subviews[i].x = padding
                            prevBtn = subviews[i] as? TGAnimationButton
                        }else{
                            subviews[i].x = (prevBtn?.rightX)! + padding
                            prevBtn = subviews[i] as? TGAnimationButton
                        }
                    }
                }
                if TGPhotoPickerConfig.shared.isShowIndicator {
                    self.addSubview(indicatorLabel)
                    indicatorLabel.isHidden = false
                    indicatorLabel.x = (prevBtn?.rightX ?? 0) + ( (doneButton?.left ?? self.w) - (prevBtn?.rightX ?? 0) - indicatorLabel.w) / 2
                }
            }else if  host == ("\(type(of: TGAlbumPhotoPreviewVC.self))" as NSString).components(separatedBy: ".").first!{
                //加previewCVH
                if TGPhotoPickerConfig.shared.isShowPreviewCV {
                    
                }
                if TGPhotoPickerConfig.shared.isShowEditButton{
                    self.addSubview(editButton)
                }
                if TGPhotoPickerConfig.shared.isShowIndicator && (TGPhotoPickerConfig.shared.indicatorPosition == .inBottomBar){
                    self.addSubview(indicatorLabel)
                    indicatorLabel.isHidden = false
                    indicatorLabel.x = (TGPhotoPickerConfig.shared.isShowEditButton ? editButton.rightX : 0) + ( (doneButton?.left ?? self.w) - (TGPhotoPickerConfig.shared.isShowEditButton ? editButton.rightX : 0) - indicatorLabel.w) / 2
                }
            }
        }
    }
    var showDividerLine: Bool = false
    weak var delegate: TGBottomBarDelegate?
    weak var nav: TGPhotoPickerVC?
    
    fileprivate var doneNumberAnimationLayer: UIView?
    fileprivate var numLabel: UILabel?
    fileprivate var doneNumberContainer: UIView?
    fileprivate var doneButton: UIButton?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }
    
    func canEdit(_ can: Bool){
        editButton.isEnabled = can
    }
    
    private func setupUI(){
        self.backgroundColor = TGPhotoPickerConfig.shared.barBGColor
        
        let toolbarH = bounds.height
        let width = self.bounds.width
        
        self.doneButton = UIButton(type: .custom)
        doneButton!.frame = CGRect(x: width - TGPhotoPickerConfig.shared.doneButtonW - padding, y: (toolbarH - TGPhotoPickerConfig.shared.doneButtonH) / 2, width: TGPhotoPickerConfig.shared.doneButtonW, height: TGPhotoPickerConfig.shared.doneButtonH)
        doneButton!.layer.cornerRadius = TGPhotoPickerConfig.shared.doneButtonH * 0.1
        doneButton!.setTitle(TGPhotoPickerConfig.shared.doneTitle, for: .normal)
        doneButton!.titleLabel?.font = UIFont.systemFont(ofSize: TGPhotoPickerConfig.shared.fontSize)
        doneButton!.backgroundColor = TGPhotoPickerConfig.shared.tinColor
        doneButton!.setTitleColor(UIColor.white, for: .normal)
        doneButton!.setTitleColor(TGPhotoPickerConfig.shared.disabledColor, for: .disabled)
        doneButton!.addTarget(self, action: #selector(doneClicked), for: .touchUpInside)
        doneButton!.isEnabled = true
        self.addSubview(self.doneButton!)
        
        let labelWH:CGFloat = TGPhotoPickerConfig.shared.checkboxCellWH
        let labelX = doneButton!.frame.minX - labelWH - TGPhotoPickerConfig.shared.padding
        let labelY = (toolbarH - labelWH) / 2
        
        self.doneNumberContainer = UIView(frame: CGRect(x:labelX, y:labelY, width: labelWH, height:labelWH))
        
        let labelRect = CGRect(x:0, y:0, width: labelWH, height: labelWH)
        self.doneNumberAnimationLayer = UIView(frame: labelRect)
        self.doneNumberAnimationLayer!.backgroundColor = TGPhotoPickerConfig.shared.tinColor
        self.doneNumberAnimationLayer!.layer.cornerRadius = labelWH / 2
        doneNumberContainer!.addSubview(self.doneNumberAnimationLayer!)
        
        self.numLabel = UILabel(frame: labelRect)
        self.numLabel!.textAlignment = .center
        self.numLabel!.font = UIFont.systemFont(ofSize: TGPhotoPickerConfig.shared.fontSize - 1.0)
        self.numLabel!.backgroundColor = UIColor.clear
        self.numLabel!.textColor = UIColor.white
        doneNumberContainer!.addSubview(self.numLabel!)
        
        doneNumberContainer?.isHidden = true
        
        self.addSubview(self.doneNumberContainer!)
        
        let divider = UIView(frame: CGRect(x:0, y:0, width:width, height:1))
        divider.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.15)
        showDividerLine ? self.addSubview(divider) : ()
    }
    
    @objc private func doneClicked(){
        self.delegate?.onDoneButtonClicked()
    }
    
    func changeNumber(number:Int,animation:Bool){
        self.previewButton.isEnabled = number > 0
        self.reselectButton.isEnabled = number > 0
        self.doneButton?.isEnabled = number > 0
        self.doneNumberContainer?.isHidden = true
        
        /*
        switch TGPhotoPickerConfig.shared.type {
        case .normal:
            self.numLabel?.text = String(number)
            self.doneNumberContainer?.isHidden = !(number > 0)
            if number > 0 && animation{
                self.doneNumberAnimationLayer!.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.3, initialSpringVelocity: 10, options: UIViewAnimationOptions.curveEaseIn, animations: {
                    self.doneNumberAnimationLayer!.transform = CGAffineTransform.identity
                }, completion: nil)
            }
        case .wechat,.weibo:
            self.doneNumberContainer?.isHidden = true
        }
        */

        if TGPhotoPickerConfig.shared.isShowIndicator{
            let attributeString = NSMutableAttributedString(string:"\(number) / \(TGPhotoPickerConfig.shared.maxImageCount)")
            attributeString.addAttribute(NSFontAttributeName,
                                         value: UIFont.boldSystemFont(ofSize: TGPhotoPickerConfig.shared.fontSize+3),
                                         range: NSMakeRange(0,"\(number) ".characters.count))
            
            attributeString.addAttribute(NSFontAttributeName,
                                         value: UIFont.boldSystemFont(ofSize: TGPhotoPickerConfig.shared.fontSize),
                                         range: NSMakeRange("\(number) ".characters.count,1))
            
            attributeString.addAttribute(NSFontAttributeName,
                                         value: UIFont.systemFont(ofSize: TGPhotoPickerConfig.shared.fontSize-3),
                                         range: NSMakeRange("\(number) / ".characters.count,"\(TGPhotoPickerConfig.shared.maxImageCount)".characters.count))
            indicatorLabel.attributedText = attributeString
        }else{
            let addStr = number > 0 ? "("+String(number)+")" : ""
            self.doneButton!.setTitle(TGPhotoPickerConfig.shared.doneTitle + addStr, for: .normal)
        }
    }
    
    //没有加private,因为可能并不显示在工具条里
    lazy var indicatorLabel: UILabel = {
        let indicatorLbl = UILabel(frame: CGRect(x: 0, y: (self.height - TGPhotoPickerConfig.shared.toolBarH * 0.8) / 2, width: 0, height: TGPhotoPickerConfig.shared.toolBarH * 0.8))
        indicatorLbl.isHidden = true
        indicatorLbl.text = "0 / \(TGPhotoPickerConfig.shared.maxImageCount)"
        indicatorLbl.font = UIFont.systemFont(ofSize: TGPhotoPickerConfig.shared.fontSize+1)
        indicatorLbl.layer.cornerRadius = TGPhotoPickerConfig.shared.doneButtonH * 0.15
        indicatorLbl.clipsToBounds = true
        indicatorLbl.textColor = .white
        indicatorLbl.textAlignment = .center
        indicatorLbl.backgroundColor = TGPhotoPickerConfig.shared.indicatorColor
        //if TGPhotoPickerConfig.shared.isShowBorder {
            indicatorLbl.layer.borderWidth = TGPhotoPickerConfig.shared.checkboxLineW
            indicatorLbl.layer.borderColor = UIColor.clear.cgColor
        //}
        indicatorLbl.sizeToFit()
        indicatorLbl.h = TGPhotoPickerConfig.shared.toolBarH * 0.8
        indicatorLbl.w = indicatorLbl.w < TGPhotoPickerConfig.shared.doneButtonW * 0.8 ? TGPhotoPickerConfig.shared.doneButtonW * 0.8 : indicatorLbl.w
        return indicatorLbl
    }()
    
    private lazy var previewButton: TGAnimationButton = {
        let previewBtn = TGAnimationButton(frame: CGRect(x: 0, y: (self.height - TGPhotoPickerConfig.shared.doneButtonH * 0.9) / 2, width: 0, height: TGPhotoPickerConfig.shared.doneButtonH * 0.9))
        previewBtn.animationKind = .none
        previewBtn.setTitle(TGPhotoPickerConfig.shared.previewBottonTitle, for: .normal)
        previewBtn.titleLabel?.font = UIFont.systemFont(ofSize: TGPhotoPickerConfig.shared.fontSize-1)
        previewBtn.cornerRadius = TGPhotoPickerConfig.shared.doneButtonH * 0.1
        previewBtn.backgroundColor = .clear
        previewBtn.setTitleColor(UIColor.white, for: .normal)
        previewBtn.setTitleColor(TGPhotoPickerConfig.shared.disabledColor, for: .disabled)
        if TGPhotoPickerConfig.shared.isShowBorder {
            previewBtn.borderWidth = TGPhotoPickerConfig.shared.checkboxLineW
            previewBtn.borderColor = TGPhotoPickerConfig.shared.tinColor
        }
        previewBtn.sizeToFit()
        previewBtn.h = TGPhotoPickerConfig.shared.doneButtonH * 0.9
        previewBtn.w = previewBtn.w < TGPhotoPickerConfig.shared.doneButtonW * 0.8 ? TGPhotoPickerConfig.shared.doneButtonW * 0.8 : previewBtn.w
        previewBtn.addTarget(self, action: #selector(previewClicked), for: .touchUpInside)
        
        return previewBtn
    }()
    
    private lazy var reselectButton: TGAnimationButton = {
        let reselectBtn = TGAnimationButton(frame: CGRect(x: 0, y: (self.height - TGPhotoPickerConfig.shared.doneButtonH * 0.9) / 2, width: 0, height: TGPhotoPickerConfig.shared.doneButtonH * 0.9))
        reselectBtn.animationKind = .none
        reselectBtn.setTitle(TGPhotoPickerConfig.shared.reselectTitle, for: .normal)
        reselectBtn.titleLabel?.font = UIFont.systemFont(ofSize: TGPhotoPickerConfig.shared.fontSize-1)
        reselectBtn.cornerRadius = TGPhotoPickerConfig.shared.doneButtonH * 0.1
        reselectBtn.backgroundColor = .clear
        reselectBtn.setTitleColor(UIColor.white, for: .normal)
        reselectBtn.setTitleColor(TGPhotoPickerConfig.shared.disabledColor, for: .disabled)
        if TGPhotoPickerConfig.shared.isShowBorder {
            reselectBtn.borderWidth = TGPhotoPickerConfig.shared.checkboxLineW
            reselectBtn.borderColor = TGPhotoPickerConfig.shared.tinColor
        }
        reselectBtn.sizeToFit()
        reselectBtn.h = TGPhotoPickerConfig.shared.doneButtonH * 0.9
        reselectBtn.w = reselectBtn.w < TGPhotoPickerConfig.shared.doneButtonW * 0.8 ? TGPhotoPickerConfig.shared.doneButtonW * 0.8 : reselectBtn.w
        reselectBtn.addTarget(self, action: #selector(reselectClicked), for: .touchUpInside)
        
        return reselectBtn
    }()
    
    private lazy var originalButton: TGAnimationButton = {
        let originalBtn = TGAnimationButton(frame: CGRect(x: 0, y: (self.height - TGPhotoPickerConfig.shared.doneButtonH * 0.9) / 2, width: 0, height: TGPhotoPickerConfig.shared.doneButtonH * 0.9))
        originalBtn.setTitle(TGPhotoPickerConfig.shared.originalTitle, for: .normal)
        originalBtn.setTitle(TGPhotoPickerConfig.shared.originalTitle, for: .disabled)
        originalBtn.titleLabel?.font = UIFont.systemFont(ofSize: TGPhotoPickerConfig.shared.fontSize-1)
        originalBtn.cornerRadius = TGPhotoPickerConfig.shared.doneButtonH * 0.1
        originalBtn.backgroundColor = .clear
        originalBtn.setTitleColor(UIColor.white, for: .normal)
        originalBtn.setTitleColor(TGPhotoPickerConfig.shared.disabledColor, for: .disabled)
        if TGPhotoPickerConfig.shared.isShowBorder {
            originalBtn.borderWidth = TGPhotoPickerConfig.shared.checkboxLineW
            originalBtn.borderColor = TGPhotoPickerConfig.shared.tinColor
        }
        
        originalBtn.animationKind = .scale
        
        originalBtn.setImage(UIImage.size(CGSize(width: TGPhotoPickerConfig.shared.doneButtonH * 0.3, height: TGPhotoPickerConfig.shared.doneButtonH * 0.3))
            .border(color: TGPhotoPickerConfig.shared.tinColor)
            .border(width: TGPhotoPickerConfig.shared.checkboxLineW)
            .corner(radius: TGPhotoPickerConfig.shared.doneButtonH * 0.15)
            .color(.clear).image, for: .normal)
        originalBtn.setImage(UIImage.size(CGSize(width: TGPhotoPickerConfig.shared.doneButtonH * 0.3, height: TGPhotoPickerConfig.shared.doneButtonH * 0.3))
            .corner(radius: TGPhotoPickerConfig.shared.doneButtonH * 0.15)
            .color(TGPhotoPickerConfig.shared.tinColor).image, for: .selected)
        originalBtn.setImage(UIImage.size(CGSize(width: TGPhotoPickerConfig.shared.doneButtonH * 0.3, height: TGPhotoPickerConfig.shared.doneButtonH * 0.3))
            .corner(radius: TGPhotoPickerConfig.shared.doneButtonH * 0.15)
            .color(TGPhotoPickerConfig.shared.tinColor).image, for: .highlighted)
        
        originalBtn.sizeToFit()
        originalBtn.h = TGPhotoPickerConfig.shared.doneButtonH * 0.9
        originalBtn.w = originalBtn.w < TGPhotoPickerConfig.shared.doneButtonW * 0.8 ? TGPhotoPickerConfig.shared.doneButtonW * 0.8 : originalBtn.w
        originalBtn.addTarget(self, action: #selector(originalClicked), for: .touchUpInside)
        
        return originalBtn
    }()
    
    private lazy var editButton: TGAnimationButton = {
        let editBtn = TGAnimationButton(frame: CGRect(x: padding, y: (self.height - TGPhotoPickerConfig.shared.doneButtonH * 0.9) / 2, width: 0, height: TGPhotoPickerConfig.shared.doneButtonH * 0.9))
        editBtn.animationKind = .none
        editBtn.setTitle(TGPhotoPickerConfig.shared.editButtonTitle, for: .normal)
        editBtn.titleLabel?.font = UIFont.systemFont(ofSize: TGPhotoPickerConfig.shared.fontSize-1)
        editBtn.cornerRadius = TGPhotoPickerConfig.shared.doneButtonH * 0.1
        editBtn.backgroundColor = .clear
        editBtn.setTitleColor(UIColor.white, for: .normal)
        editBtn.setTitleColor(TGPhotoPickerConfig.shared.disabledColor, for: .disabled)
        if TGPhotoPickerConfig.shared.isShowBorder {
            editBtn.borderWidth = TGPhotoPickerConfig.shared.checkboxLineW
            editBtn.borderColor = TGPhotoPickerConfig.shared.tinColor
        }
        editBtn.sizeToFit()
        editBtn.h = TGPhotoPickerConfig.shared.doneButtonH * 0.9
        editBtn.w = editBtn.w < TGPhotoPickerConfig.shared.doneButtonW * 0.8 ? TGPhotoPickerConfig.shared.doneButtonW * 0.8 : editBtn.w
        editBtn.addTarget(self, action: #selector(editClicked), for: .touchUpInside)
        
        return editBtn
    }()
    
    @objc private func editClicked(_ sender:TGAnimationButton){
        self.delegate?.onEditButtonClicked?(sender)
    }
    
    @objc private func originalClicked(_ sender:TGAnimationButton){
        self.delegate?.onOriginalButtonClicked?(sender)
    }
    
    @objc private func previewClicked(_ sender:TGAnimationButton){
        self.delegate?.onPreviewButtonClicked?(sender)
    }
    
    @objc private func reselectClicked(_ sender:TGAnimationButton){
        self.delegate?.onReselectButtonClicked?(sender)
    }
}
