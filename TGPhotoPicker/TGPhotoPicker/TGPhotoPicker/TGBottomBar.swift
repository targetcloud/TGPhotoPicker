//
//  TGBottomBar.swift
//  TGPhotoPicker
//
//  Created by targetcloud on 2017/7/22.
//  Copyright © 2017年 targetcloud. All rights reserved.
//

import UIKit

protocol TGBottomBarDelegate:class{
    func onDoneButtonClicked()
}

class TGBottomBar: UIView {

    var showDividerLine: Bool = false
    weak var delegate: TGBottomBarDelegate?
    
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
    
    private func setupUI(){
        self.backgroundColor = TGPhotoPickerConfig.shared.barBGColor
        
        let toolbarH = bounds.height
        let width = self.bounds.width
        
        self.doneButton = UIButton(type: .custom)
        doneButton!.frame = CGRect(x: width - TGPhotoPickerConfig.shared.doneButtonW - TGPhotoPickerConfig.shared.padding * 2, y: (toolbarH - TGPhotoPickerConfig.shared.doneButtonH) / 2, width: TGPhotoPickerConfig.shared.doneButtonW, height: TGPhotoPickerConfig.shared.doneButtonH)
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
        
        let addStr = number > 0 ? "("+String(number)+")" : ""
        self.doneButton!.setTitle(TGPhotoPickerConfig.shared.doneTitle + addStr, for: .normal)
    }
}
