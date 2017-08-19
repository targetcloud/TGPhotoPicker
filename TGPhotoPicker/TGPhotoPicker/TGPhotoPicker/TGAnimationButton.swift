//
//  TGAnimationButton.swift
//  TGAnimationButton
//
//  Created by targetcloud on 2017/8/18.
//  Copyright © 2017年 targetcloud. All rights reserved.
//

import UIKit

enum TGAnimationButtonKind {
    case none
    case topToBottom
    case bottomToTop
    case leftToRight
    case rightToLeft
    case scale
}

class TGAnimationButton: UIButton {
    var animationKind: TGAnimationButtonKind = .topToBottom
    
    var borderColor: UIColor = UIColor.clear {
        didSet {
            layer.borderColor = borderColor.cgColor
        }
    }
    
    var borderWidth: CGFloat = 0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    
    var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
        }
    }
    
    var activityIndicatorViewStyle: UIActivityIndicatorViewStyle = .gray{
        didSet{
            indicatorV.activityIndicatorViewStyle = activityIndicatorViewStyle
        }
    }
    
    public override var isEnabled: Bool {
        didSet {
            guard animationKind != .none else { return }
            if oldValue != isEnabled {
                if oldValue {
                    lastDisabledTitle = title(for: .disabled)
                    loading(title: lastDisabledTitle)
                    setTitle("", for: .disabled)
                } else {
                    reset()
                    setTitle(lastDisabledTitle, for: .disabled)
                }
            }
        }
    }
    
    lazy var backV = UIView()
    lazy var messageLbl = UILabel()
    lazy var indicatorV: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.hidesWhenStopped = true
        indicator.sizeToFit()
        indicator.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
        return indicator
    }()
    private var lastTitle: String?
    private var lastDisabledTitle: String?
    private var lastWidth: CGFloat?
    private var lsatHeight: CGFloat?
    
    private var transformY: CGFloat {
        return self.h * (animationKind == .topToBottom ? (-1) : (animationKind == .bottomToTop ? 1 : 0))
    }
    
    private var transformX: CGFloat {
        return self.w * (animationKind == .leftToRight ? (-1) : (animationKind == .rightToLeft ? 1 : 0))
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        layer.masksToBounds = true
        
        messageLbl.textColor = titleLabel?.textColor
        messageLbl.font = titleLabel?.font
        backV.addSubview(messageLbl)
        
        indicatorV.activityIndicatorViewStyle = activityIndicatorViewStyle
        backV.addSubview(indicatorV)
        
        backV.h = self.h
        backV.centerY = self.h * 0.5
        backV.backgroundColor = .clear
        backV.alpha = 0
        
        addSubview(backV)
        
        lastTitle = currentTitle
        lsatHeight = self.h
        lastWidth = self.w
    }
    
    private func loading(title: String?) {
        messageLbl.text = title
        messageLbl.textColor = self.titleColor(for: .disabled)
        messageLbl.shadowColor = self.titleShadowColor(for: .disabled)
        messageLbl.font = self.titleLabel?.font
        messageLbl.sizeToFit()
        
        indicatorV.centerY = backV.centerY
        indicatorV.x = (TGPhotoPickerConfig.shared.padding < 5) ? 5 : TGPhotoPickerConfig.shared.padding
        messageLbl.centerY = indicatorV.centerY
        messageLbl.left = indicatorV.right + ((TGPhotoPickerConfig.shared.padding < 5) ? 5 : TGPhotoPickerConfig.shared.padding)
        backV.right = messageLbl.right
        backV.w = messageLbl.right + ((TGPhotoPickerConfig.shared.padding < 5) ? 5 : TGPhotoPickerConfig.shared.padding)
        
        self.w = self.w < backV.w ? backV.w : self.w
        backV.left = (self.w - backV.w ) * 0.5
        
        indicatorV.startAnimating()
        backV.transform = (title == lastTitle) ? .identity : animationKind == .scale ? CGAffineTransform(scaleX: 0.5, y: 0.5) : CGAffineTransform(translationX: transformX, y: transformY)
        UIView.animate(withDuration: TGPhotoPickerConfig.shared.animateDuration) {
            self.titleLabel!.alpha = 0
            self.backV.alpha = 1
            self.backV.transform = .identity
        }
    }
    
    private func reset() {
        UIView.animate(withDuration: TGPhotoPickerConfig.shared.animateDuration, animations: {
            self.titleLabel!.alpha = 1
            self.backV.alpha = 0
            self.backV.transform = (self.currentTitle == self.lastDisabledTitle) ? .identity : self.animationKind == .scale ? CGAffineTransform(scaleX: 0.5, y: 0.5) : CGAffineTransform(translationX: 0, y: self.transformY)
        }) { (finished) in
            self.backV.transform = .identity
            self.indicatorV.stopAnimating()
            UIView.animate(withDuration: TGPhotoPickerConfig.shared.animateDuration, animations: {
                if self.currentTitle == self.lastDisabledTitle {
                    self.w = self.lastWidth ?? self.w
                }else{
                    self.sizeToFit()
                    self.w = self.w > (self.lastWidth ?? self.w) ? self.w : (self.lastWidth ?? self.w)
                    self.h = self.lsatHeight ?? self.h
                }
            })
        }
    }

}
