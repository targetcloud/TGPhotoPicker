//
//  TGActionSheet.swift
//  TGPhotoPicker
//
//  Created by targetcloud on 2017/8/13.
//  Copyright © 2017年 targetcloud. All rights reserved.
//

import UIKit

fileprivate let TGActionSheetCancelTag = 1999
fileprivate let TGActionSheetBaseTag = 1000
fileprivate let TGActionSheetAnimationDuration: TimeInterval = 0.25

protocol TGActionSheetDelegate: NSObjectProtocol {
    func actionSheet(actionSheet: TGActionSheet?, didClickedAt index: Int)
}

class TGActionSheet: UIView {
    weak var delegate: TGActionSheetDelegate?
    
    var name:String?
    
    fileprivate lazy var btnArr: [UIButton] = [UIButton]()
    
    fileprivate lazy var dividerArr: [UIView] = [UIView]()
    
    fileprivate lazy var coverView: UIView = { [unowned self] in
        let coverView = UIView()
        coverView.backgroundColor = UIColor(white: 0, alpha: 0.3)
        coverView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(coverViewDidClick)))
        return coverView
    }()
    
    fileprivate lazy var actionSheet: UIView = {
        let actionSheet = UIView()
        actionSheet.backgroundColor = UIColor.white.withAlphaComponent(0.9)
        return actionSheet
    }()
    
    fileprivate lazy var cancelBtn: UIButton = {
        let cancelBtn = UIButton(type: .custom)
        cancelBtn.tag = TGActionSheetCancelTag
        cancelBtn.backgroundColor = UIColor(white: 1, alpha: 1)
        cancelBtn.titleLabel?.textAlignment = .center
        cancelBtn.titleLabel?.font = UIFont.systemFont(ofSize: TGPhotoPickerConfig.shared.fontSize)
        cancelBtn.setTitleColor(.darkGray, for: .normal)
        cancelBtn.addTarget(self, action: #selector(actionSheetClicked(_:)), for: .touchUpInside)
        return cancelBtn
    }()
    
    class func showActionSheet(with delegate: TGActionSheetDelegate?, title: String? = nil, cancelTitle: String, otherTitles: [String]) -> TGActionSheet {
        return TGActionSheet(delegate: delegate, title: title,cancelTitle: cancelTitle, otherTitles: otherTitles)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    init(delegate: TGActionSheetDelegate?, title: String? = nil,cancelTitle: String, otherTitles: [String]) {
        super.init(frame: CGRect.zero)
        btnArr.removeAll()
        dividerArr.removeAll()
        self.backgroundColor = .clear
        self.delegate = delegate
        self.addSubview(coverView)
        self.coverView.addSubview(actionSheet)
        if (title?.characters.count ?? 0) > 0{
            self.createBtn(with: title!, bgColor: UIColor(white: 1, alpha: 1), titleColor: .lightGray, tagIndex: 0)
        }
        for i in 0..<otherTitles.count {
            self.createBtn(with: otherTitles[i], bgColor: UIColor(white: 1, alpha: 1), titleColor: .darkGray, tagIndex: i + TGActionSheetBaseTag)
        }
        cancelBtn.setTitle(cancelTitle, for: .normal)
        self.actionSheet.addSubview(cancelBtn)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    fileprivate func createBtn(with title: String?, bgColor: UIColor?, titleColor: UIColor?, tagIndex: Int) {
        let actionBtn = UIButton(type: .custom)
        actionBtn.tag = tagIndex
        actionBtn.titleLabel?.font = UIFont.systemFont(ofSize: TGPhotoPickerConfig.shared.fontSize + (tagIndex == 0 ? -3 : 0))
        actionBtn.backgroundColor = bgColor
        actionBtn.titleLabel?.textAlignment = .center
        actionBtn.setTitle(title, for: .normal)
        actionBtn.setTitleColor(titleColor, for: .normal)
        actionBtn.addTarget(self, action: #selector(actionSheetClicked(_:)), for: .touchUpInside)
        self.actionSheet.addSubview(actionBtn)
        self.btnArr.append(actionBtn)
        
        let divider = UIView()
        divider.backgroundColor = UIColor.hexInt(0xebebeb)
        actionBtn.addSubview(divider)
        dividerArr.append(divider)
    }

    @objc fileprivate func coverViewDidClick() {
        self.dismiss()
    }
    
    @objc fileprivate func actionSheetClicked(_ btn: UIButton) {
        if btn.tag != TGActionSheetCancelTag && btn.tag >= TGActionSheetBaseTag{
            self.delegate?.actionSheet(actionSheet: self, didClickedAt: btn.tag - TGActionSheetBaseTag)
            self.dismiss()
        } else {
            self.dismiss()
        }
    }
    
    func show() {
        if self.superview != nil { return }
        
        let keyWindow = UIApplication.shared.keyWindow
        self.frame = (keyWindow?.bounds)!
        keyWindow?.addSubview(self)
        
        coverView.frame = CGRect(x: 0, y: 0, width: TGPhotoPickerConfig.ScreenW, height: TGPhotoPickerConfig.ScreenH)
        
        let actionH = CGFloat(self.btnArr.count + 1) * TGPhotoPickerConfig.shared.toolBarH + 5.0
        actionSheet.frame = CGRect(x: 0, y: self.frame.height, width: TGPhotoPickerConfig.ScreenW, height: actionH)
        
        cancelBtn.frame = CGRect(x: 0, y: actionH - TGPhotoPickerConfig.shared.toolBarH, width: self.frame.width, height: TGPhotoPickerConfig.shared.toolBarH)
        
        let btnW: CGFloat = self.frame.width
        let btnH: CGFloat = TGPhotoPickerConfig.shared.toolBarH
        let btnX: CGFloat = 0
        var btnY: CGFloat = 0
        for i in 0..<btnArr.count {
            let btn = btnArr[i]
            let divider = dividerArr[i]
            btnY = TGPhotoPickerConfig.shared.toolBarH * CGFloat(i)
            btn.frame = CGRect(x: btnX, y: btnY, width: btnW, height: btnH)
            divider.frame = CGRect(x: btnX, y: btnH - 1, width: btnW, height: 1)
        }
        
        UIView.animate(withDuration: TGActionSheetAnimationDuration) {
            self.actionSheet.frame.origin.y = self.frame.height - self.actionSheet.frame.height
        }
    }
    
    fileprivate func dismiss() {
        UIView.animate(withDuration: TGActionSheetAnimationDuration, animations: {
            self.actionSheet.frame.origin.y = self.frame.height
        }) { (_) in
            if self.superview != nil {
                self.removeFromSuperview()
            }
        }
    }
}

