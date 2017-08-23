//
//  ViewController.swift
//  TGPhotoPicker
//
//  Created by targetcloud on 2017/7/12.
//  Copyright © 2017年 targetcloud. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    //创建方式1
    //lazy var picker: TGPhotoPicker = TGPhotoPicker(self, frame: CGRect(x: 0, y: 50, width: UIScreen.main.bounds.width, height: 160))
    
    //创建方式2 带配置
//    lazy var picker: TGPhotoPicker = TGPhotoPicker(self, frame: CGRect(x: 0, y: 50, width: UIScreen.main.bounds.width, height: 160)) { (config) in
//        config.type = .weibo
//    }

    //创建方式3 带配置(链式)
//    lazy var picker: TGPhotoPicker = TGPhotoPicker(self, frame: CGRect(x: 0, y: 50, width: UIScreen.main.bounds.width, height: 160)) { (config) in
//        config.tg_type(.wechat)
//              .tg_checkboxLineW(1)
//    }

    //创建方式4 带配置（单例配置对象）
    lazy var picker: TGPhotoPicker = TGPhotoPicker(self, frame: CGRect(x: 0, y: 50, width: UIScreen.main.bounds.width, height: 160)) { _ in
        TGPhotoPickerConfig.shared.tg_type(.wechat)
            .tg_checkboxLineW(1)
            .tg_colCount(4)
            .tg_toolBarH(50)
            .tg_useChineseAlbumName(true)
    }
    
    //以下所有代码请读者忽略（以下代码为演示各参数效果而写）
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(red: 28/255, green: 23/255, blue: 42/255, alpha: 1) 
        self.view.addSubview(picker)
        
        var cols = 8
        var rows = 1
        var cellWidth = Int(self.view.frame.width / CGFloat(cols))
        var cellHeight = Int(30 / CGFloat(rows))
        
        (TGCheckboxType.onlyCheckbox.rawValue ... TGCheckboxType.star.rawValue).forEach {
            let x = $0 % cols * cellWidth
            let y = $0 / cols * cellHeight
            let frame = CGRect(x: x, y: y+20, width: cellWidth, height: cellHeight)
            let button: UIButton = UIButton(frame: frame)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
            button.tag = 1000+$0
            TGPhotoPickerConfig.shared.checkboxType = TGCheckboxType(rawValue: $0)!
            let imageTuples = TGPhotoPickerConfig.shared.getCheckboxImage()
            button.setImage(imageTuples.unselect, for: .normal)
            button.setImage(imageTuples.select, for: .selected)
            //button.setTitle(String($0), for: .normal)
            button.addTarget(self,action: #selector(tap(_:)),for: UIControlEvents.touchUpInside)
            self.view.addSubview(button)
        }
        
        cols = 4
        rows = 1
        cellWidth = Int((self.view.frame.width - 50) / CGFloat(cols))
        cellHeight = 20
        let positionLabel = UILabel(frame: CGRect(x: 10, y: 230, width: 100, height: 20))
        positionLabel.text = "position"
        positionLabel.textColor = .white
        positionLabel.font = UIFont.systemFont(ofSize: 12)
        self.view.addSubview(positionLabel)
        (TGCheckboxPosition.topLeft.rawValue ... TGCheckboxPosition.bottomRight.rawValue).forEach {
            let x = $0 % cols * cellWidth
            let y = $0 / cols * cellHeight
            let frame = CGRect(x: x+50, y: y+230, width: cellWidth, height: cellHeight)
            let button: UIButton = UIButton(frame: frame)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
            button.tag = 2000+$0
            button.setTitle(" \(TGCheckboxPosition(rawValue: $0)!)", for: .normal)
            button.setTitleColor(TGPhotoPickerConfig.shared.tinColor, for: .selected)
            button.addTarget(self,action: #selector(position(_:)),for: UIControlEvents.touchUpInside)
            self.view.addSubview(button)
        }
        
        let selectKindLabel = UILabel(frame: CGRect(x: 10, y: 210, width: 100, height: 20))
        selectKindLabel.text = "kind"
        selectKindLabel.textColor = .white
        selectKindLabel.font = UIFont.systemFont(ofSize: 12)
        self.view.addSubview(selectKindLabel)
        (TGSelectKind.onlyPhoto.rawValue ... TGSelectKind.all.rawValue).forEach {
            let x = $0 % cols * cellWidth
            let y = $0 / cols * cellHeight
            let frame = CGRect(x: x+50, y: y+210, width: cellWidth, height: cellHeight)
            let button: UIButton = UIButton(frame: frame)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
            button.tag = 3000+$0
            button.setTitle(" \(TGSelectKind(rawValue: $0)!)", for: .normal)
            button.setTitleColor(TGPhotoPickerConfig.shared.tinColor, for: .selected)
            button.addTarget(self,action: #selector(selectKind(_:)),for: UIControlEvents.touchUpInside)
            self.view.addSubview(button)
        }
        
        let indicatorLabel = UILabel(frame: CGRect(x: 10, y: 250, width: 100, height: 20))
        indicatorLabel.text = "indicator"
        indicatorLabel.textColor = .white
        indicatorLabel.font = UIFont.systemFont(ofSize: 12)
        self.view.addSubview(indicatorLabel)
        (TGIndicatorPosition.top.rawValue ... TGIndicatorPosition.inTopBar.rawValue).forEach {
            let x = $0 % cols * cellWidth
            let y = $0 / cols * cellHeight
            let frame = CGRect(x: x+50, y: y+250, width: cellWidth, height: cellHeight)
            let button: UIButton = UIButton(frame: frame)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
            button.tag = 4000+$0
            button.setTitle(" \(TGIndicatorPosition(rawValue: $0)!)", for: .normal)
            button.setTitleColor(TGPhotoPickerConfig.shared.tinColor, for: .selected)
            button.addTarget(self,action: #selector(indicatorPosition(_:)),for: UIControlEvents.touchUpInside)
            self.view.addSubview(button)
        }
        
        let currentCheckboxType = TGPhotoPickerConfig.shared.type.rawValue>0 ? TGCheckboxType.circle : TGCheckboxType(rawValue: 4)!
        (self.view.viewWithTag(1000+currentCheckboxType.rawValue) as! UIButton).isSelected = true
        (self.view.viewWithTag(2000+1) as! UIButton).isSelected = true
        (self.view.viewWithTag(3000+3) as! UIButton).isSelected = true
        (self.view.viewWithTag(4000+1) as! UIButton).isSelected = true
        TGPhotoPickerConfig.shared.checkboxType = currentCheckboxType
        //TGPhotoPickerConfig.shared.checkboxPosition = TGCheckboxPosition(rawValue: 1)!
        
        self.view.addSubview(cornerLabel)
        let cornerSlider = UISlider(frame: CGRect(x: 110, y: 270, width: TGPhotoPickerConfig.ScreenW - 130, height: 20))
        cornerSlider.transform =  CGAffineTransform(scaleX: 1.0, y: 0.5)
        cornerSlider.tintColor = .white
        cornerSlider.setThumbImage(UIImage.size(width: 12, height: 18).color(.white).image, for: .normal)
        cornerSlider.setThumbImage(UIImage.size(width: 12, height: 18).color(.darkGray).image, for: .highlighted)
        cornerSlider.maximumTrackTintColor = .gray
        cornerSlider.minimumValue = 0
        cornerSlider.maximumValue = Float(TGPhotoPickerConfig.shared.checkboxCellWH)
        cornerSlider.value = Float(TGPhotoPickerConfig.shared.checkboxCorner)
        cornerSlider.addTarget(self,action: #selector(cornerChangedAction),for: UIControlEvents.valueChanged)
        self.view.addSubview(cornerSlider)
        
        self.view.addSubview(paddingLabel)
        let paddingSlider = UISlider(frame: CGRect(x: 110, y: 290, width: TGPhotoPickerConfig.ScreenW - 130, height: 20))
        paddingSlider.transform =  CGAffineTransform(scaleX: 1.0, y: 0.5)
        paddingSlider.tintColor = .white
        paddingSlider.setThumbImage(UIImage.size(width: 12, height: 18).color(.white).image, for: .normal)
        paddingSlider.setThumbImage(UIImage.size(width: 12, height: 18).color(.darkGray).image, for: .highlighted)
        paddingSlider.maximumTrackTintColor = .gray
        paddingSlider.minimumValue = 0
        paddingSlider.maximumValue = 6
        paddingSlider.value = Float(TGPhotoPickerConfig.shared.checkboxPadding)
        paddingSlider.addTarget(self,action: #selector(paddingChangedAction),for: UIControlEvents.valueChanged)
        self.view.addSubview(paddingSlider)
        
        self.view.addSubview(lineWidthLabel)
        let lineWidthSlider = UISlider(frame: CGRect(x: 110, y: 310, width: TGPhotoPickerConfig.ScreenW - 130, height: 20))
        lineWidthSlider.transform =  CGAffineTransform(scaleX: 1.0, y: 0.5)
        lineWidthSlider.tintColor = .white
        lineWidthSlider.setThumbImage(UIImage.size(width: 12, height: 18).color(.white).image, for: .normal)
        lineWidthSlider.setThumbImage(UIImage.size(width: 12, height: 18).color(.darkGray).image, for: .highlighted)
        lineWidthSlider.maximumTrackTintColor = .gray
        lineWidthSlider.minimumValue = 1
        lineWidthSlider.maximumValue = 2
        lineWidthSlider.value = Float(TGPhotoPickerConfig.shared.checkboxLineW)
        lineWidthSlider.addTarget(self,action: #selector(lineWidthChangedAction),for: UIControlEvents.valueChanged)
        self.view.addSubview(lineWidthSlider)
        
        self.view.addSubview(endAlphaLabel)
        let endAlphaSlider = UISlider(frame: CGRect(x: 110, y: 330, width: TGPhotoPickerConfig.ScreenW - 130, height: 20))
        endAlphaSlider.transform =  CGAffineTransform(scaleX: 1.0, y: 0.5)
        endAlphaSlider.tintColor = .white
        endAlphaSlider.setThumbImage(UIImage.size(width: 12, height: 18).color(.white).image, for: .normal)
        endAlphaSlider.setThumbImage(UIImage.size(width: 12, height: 18).color(.darkGray).image, for: .highlighted)
        endAlphaSlider.maximumTrackTintColor = .gray
        endAlphaSlider.minimumValue = 0.2
        endAlphaSlider.maximumValue = 1
        endAlphaSlider.value = Float(TGPhotoPickerConfig.shared.checkboxEndingAlpha)
        endAlphaSlider.addTarget(self,action: #selector(endAlphaChangedAction),for: UIControlEvents.valueChanged)
        self.view.addSubview(endAlphaSlider)
        
        self.view.addSubview(maskAlphaLabel)
        let maskAlphaSlider = UISlider(frame: CGRect(x: 110, y: 350, width: TGPhotoPickerConfig.ScreenW - 130, height: 20))
        maskAlphaSlider.transform =  CGAffineTransform(scaleX: 1.0, y: 0.5)
        maskAlphaSlider.tintColor = .white
        maskAlphaSlider.setThumbImage(UIImage.size(width: 12, height: 18).color(.white).image, for: .normal)
        maskAlphaSlider.setThumbImage(UIImage.size(width: 12, height: 18).color(.darkGray).image, for: .highlighted)
        maskAlphaSlider.maximumTrackTintColor = .gray
        maskAlphaSlider.minimumValue = 0.3
        maskAlphaSlider.maximumValue = 0.8
        maskAlphaSlider.value = Float(TGPhotoPickerConfig.shared.maskAlpha)
        maskAlphaSlider.addTarget(self,action: #selector(maskAlphaChangedAction),for: UIControlEvents.valueChanged)
        self.view.addSubview(maskAlphaSlider)
        
        self.view.addSubview(maxImageCountLabel)
        let maxImageCountSlider = UISlider(frame: CGRect(x: 110, y: 370, width: TGPhotoPickerConfig.ScreenW - 130, height: 20))
        maxImageCountSlider.transform =  CGAffineTransform(scaleX: 1.0, y: 0.5)
        maxImageCountSlider.tintColor = .white
        maxImageCountSlider.setThumbImage(UIImage.size(width: 12, height: 18).color(.white).image, for: .normal)
        maxImageCountSlider.setThumbImage(UIImage.size(width: 12, height: 18).color(.darkGray).image, for: .highlighted)
        maxImageCountSlider.maximumTrackTintColor = .gray
        maxImageCountSlider.minimumValue = 1
        maxImageCountSlider.maximumValue = 99
        maxImageCountSlider.value = Float(TGPhotoPickerConfig.shared.maxImageCount)
        maxImageCountSlider.addTarget(self,action: #selector(maxImageCountChangedAction),for: UIControlEvents.valueChanged)
        self.view.addSubview(maxImageCountSlider)
        
        self.view.addSubview(checkboxCellSizeLabel)
        let checkboxCellSizeSlider = UISlider(frame: CGRect(x: 110, y: 390, width: TGPhotoPickerConfig.ScreenW - 130, height: 20))
        checkboxCellSizeSlider.transform =  CGAffineTransform(scaleX: 1.0, y: 0.5)
        checkboxCellSizeSlider.tintColor = .white
        checkboxCellSizeSlider.setThumbImage(UIImage.size(width: 12, height: 18).color(.white).image, for: .normal)
        checkboxCellSizeSlider.setThumbImage(UIImage.size(width: 12, height: 18).color(.darkGray).image, for: .highlighted)
        checkboxCellSizeSlider.maximumTrackTintColor = .gray
        checkboxCellSizeSlider.minimumValue = 20
        checkboxCellSizeSlider.maximumValue = 25
        checkboxCellSizeSlider.value = Float(TGPhotoPickerConfig.shared.checkboxCellWH)
        checkboxCellSizeSlider.addTarget(self,action: #selector(checkboxCellSizeAction),for: UIControlEvents.valueChanged)
        self.view.addSubview(checkboxCellSizeSlider)
        
        self.view.addSubview(shadowWHLabel)
        let shadowWHSlider = UISlider(frame: CGRect(x: 110, y: 410, width: TGPhotoPickerConfig.ScreenW - 130, height: 20))
        shadowWHSlider.transform =  CGAffineTransform(scaleX: 1.0, y: 0.5)
        shadowWHSlider.tintColor = .white
        shadowWHSlider.setThumbImage(UIImage.size(width: 12, height: 18).color(.white).image, for: .normal)
        shadowWHSlider.setThumbImage(UIImage.size(width: 12, height: 18).color(.darkGray).image, for: .highlighted)
        shadowWHSlider.maximumTrackTintColor = .gray
        shadowWHSlider.minimumValue = 0
        shadowWHSlider.maximumValue = 4
        shadowWHSlider.value = Float(TGPhotoPickerConfig.shared.shadowW)
        shadowWHSlider.addTarget(self,action: #selector(shadowWHAction),for: UIControlEvents.valueChanged)
        self.view.addSubview(shadowWHSlider)
        
        let randomButton: UIButton = UIButton(frame: CGRect(x: 0, y: TGPhotoPickerConfig.ScreenH-20, width: TGPhotoPickerConfig.ScreenW, height: 20))
        randomButton.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        randomButton.setTitle("tinColor", for: .normal)
        randomButton.setTitleColor(.white, for: .normal)
        randomButton.backgroundColor = TGPhotoPickerConfig.shared.tinColor
        randomButton.addTarget(self,action: #selector(randomColor(_:)),for: UIControlEvents.touchUpInside)
        self.view.addSubview(randomButton)
        
        let useSelectMaskButton: UIButton = UIButton(frame: CGRect(x: 0, y: TGPhotoPickerConfig.ScreenH-40, width: TGPhotoPickerConfig.ScreenW/3, height: 20))
        useSelectMaskButton.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        useSelectMaskButton.setTitle("useSelectMask", for: .normal)
        useSelectMaskButton.setTitleColor(.white, for: .normal)
        useSelectMaskButton.setTitleColor(TGPhotoPickerConfig.shared.tinColor, for: .selected)
        useSelectMaskButton.backgroundColor = self.view.backgroundColor
        useSelectMaskButton.isSelected = TGPhotoPickerConfig.shared.useSelectMask
        useSelectMaskButton.addTarget(self,action: #selector(useSelectMaskAction(_:)),for: UIControlEvents.touchUpInside)
        self.view.addSubview(useSelectMaskButton)
        
        let immediateTapSelectButton: UIButton = UIButton(frame: CGRect(x: useSelectMaskButton.frame.maxX, y: TGPhotoPickerConfig.ScreenH-40, width: TGPhotoPickerConfig.ScreenW/3, height: 20))
        immediateTapSelectButton.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        immediateTapSelectButton.setTitle("immediateSelect", for: .normal)
        immediateTapSelectButton.setTitleColor(.white, for: .normal)
        immediateTapSelectButton.setTitleColor(TGPhotoPickerConfig.shared.tinColor, for: .selected)
        immediateTapSelectButton.backgroundColor = self.view.backgroundColor
        immediateTapSelectButton.isSelected = TGPhotoPickerConfig.shared.immediateTapSelect
        immediateTapSelectButton.addTarget(self,action: #selector(immediateTapSelectAction(_:)),for: UIControlEvents.touchUpInside)
        self.view.addSubview(immediateTapSelectButton)
        
        let showSelectNumberButton: UIButton = UIButton(frame: CGRect(x: immediateTapSelectButton.frame.maxX, y: TGPhotoPickerConfig.ScreenH-40, width: TGPhotoPickerConfig.ScreenW/3, height: 20))
        showSelectNumberButton.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        showSelectNumberButton.setTitle("showNumber", for: .normal)
        showSelectNumberButton.setTitleColor(.white, for: .normal)
        showSelectNumberButton.setTitleColor(TGPhotoPickerConfig.shared.tinColor, for: .selected)
        showSelectNumberButton.backgroundColor = self.view.backgroundColor
        showSelectNumberButton.isSelected = TGPhotoPickerConfig.shared.isShowNumber
        showSelectNumberButton.addTarget(self,action: #selector(showSelectNumberAction(_:)),for: UIControlEvents.touchUpInside)
        self.view.addSubview(showSelectNumberButton)
        
        let checkboxAnimateButton: UIButton = UIButton(frame: CGRect(x: 0, y: TGPhotoPickerConfig.ScreenH-60, width: TGPhotoPickerConfig.ScreenW/3, height: 20))
        checkboxAnimateButton.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        checkboxAnimateButton.setTitle("checkboxAnimate", for: .normal)
        checkboxAnimateButton.setTitleColor(.white, for: .normal)
        checkboxAnimateButton.setTitleColor(TGPhotoPickerConfig.shared.tinColor, for: .selected)
        checkboxAnimateButton.backgroundColor = self.view.backgroundColor
        checkboxAnimateButton.isSelected = TGPhotoPickerConfig.shared.checkboxAnimate
        checkboxAnimateButton.addTarget(self,action: #selector(checkboxAnimateAction(_:)),for: UIControlEvents.touchUpInside)
        self.view.addSubview(checkboxAnimateButton)

        let useCustomSmartCollectionsMaskButton: UIButton = UIButton(frame: CGRect(x: checkboxAnimateButton.frame.maxX, y: TGPhotoPickerConfig.ScreenH-60, width: TGPhotoPickerConfig.ScreenW/3, height: 20))
        useCustomSmartCollectionsMaskButton.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        useCustomSmartCollectionsMaskButton.setTitle("useCustomMask", for: .normal)
        useCustomSmartCollectionsMaskButton.setTitleColor(.white, for: .normal)
        useCustomSmartCollectionsMaskButton.setTitleColor(TGPhotoPickerConfig.shared.tinColor, for: .selected)
        useCustomSmartCollectionsMaskButton.backgroundColor = self.view.backgroundColor
        useCustomSmartCollectionsMaskButton.isSelected = TGPhotoPickerConfig.shared.useCustomSmartCollectionsMask
        useCustomSmartCollectionsMaskButton.addTarget(self,action: #selector(useCustomSmartCollectionsMaskAction(_:)),for: UIControlEvents.touchUpInside)
        self.view.addSubview(useCustomSmartCollectionsMaskButton)
        
        let useChineseAlbumNameButton: UIButton = UIButton(frame: CGRect(x: useCustomSmartCollectionsMaskButton.frame.maxX, y: TGPhotoPickerConfig.ScreenH-60, width: TGPhotoPickerConfig.ScreenW/3, height: 20))
        useChineseAlbumNameButton.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        useChineseAlbumNameButton.setTitle("chineseAlbum", for: .normal)
        useChineseAlbumNameButton.setTitleColor(.white, for: .normal)
        useChineseAlbumNameButton.setTitleColor(TGPhotoPickerConfig.shared.tinColor, for: .selected)
        useChineseAlbumNameButton.backgroundColor = self.view.backgroundColor
        useChineseAlbumNameButton.isSelected = TGPhotoPickerConfig.shared.useChineseAlbumName
        useChineseAlbumNameButton.addTarget(self,action: #selector(useChineseAlbumNameAction(_:)),for: UIControlEvents.touchUpInside)
        self.view.addSubview(useChineseAlbumNameButton)
        
        let showEmptyAlbumButton: UIButton = UIButton(frame: CGRect(x: 0, y: TGPhotoPickerConfig.ScreenH-80, width: TGPhotoPickerConfig.ScreenW/3, height: 20))
        showEmptyAlbumButton.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        showEmptyAlbumButton.setTitle("showEmptyAlbum", for: .normal)
        showEmptyAlbumButton.setTitleColor(.white, for: .normal)
        showEmptyAlbumButton.setTitleColor(TGPhotoPickerConfig.shared.tinColor, for: .selected)
        showEmptyAlbumButton.backgroundColor = self.view.backgroundColor
        showEmptyAlbumButton.isSelected = TGPhotoPickerConfig.shared.isShowEmptyAlbum
        showEmptyAlbumButton.addTarget(self,action: #selector(showEmptyAlbumAction(_:)),for: UIControlEvents.touchUpInside)
        self.view.addSubview(showEmptyAlbumButton)
        
        let ascendingButton: UIButton = UIButton(frame: CGRect(x: showEmptyAlbumButton.frame.maxX, y: TGPhotoPickerConfig.ScreenH-80, width: TGPhotoPickerConfig.ScreenW/3, height: 20))
        ascendingButton.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        ascendingButton.setTitle("ascending", for: .normal)
        ascendingButton.setTitleColor(.white, for: .normal)
        ascendingButton.setTitleColor(TGPhotoPickerConfig.shared.tinColor, for: .selected)
        ascendingButton.backgroundColor = self.view.backgroundColor
        ascendingButton.isSelected = TGPhotoPickerConfig.shared.ascending
        ascendingButton.addTarget(self,action: #selector(ascendingAction(_:)),for: UIControlEvents.touchUpInside)
        self.view.addSubview(ascendingButton)
        
        let showBorderButton: UIButton = UIButton(frame: CGRect(x: ascendingButton.frame.maxX, y: TGPhotoPickerConfig.ScreenH-80, width: TGPhotoPickerConfig.ScreenW/3, height: 20))
        showBorderButton.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        showBorderButton.setTitle("showBorder", for: .normal)
        showBorderButton.setTitleColor(.white, for: .normal)
        showBorderButton.setTitleColor(TGPhotoPickerConfig.shared.tinColor, for: .selected)
        showBorderButton.backgroundColor = self.view.backgroundColor
        showBorderButton.isSelected = TGPhotoPickerConfig.shared.isShowBorder
        showBorderButton.addTarget(self,action: #selector(showBorderAction(_:)),for: UIControlEvents.touchUpInside)
        self.view.addSubview(showBorderButton)
        
        let removeButtonHiddenButton: UIButton = UIButton(frame: CGRect(x: 0, y: TGPhotoPickerConfig.ScreenH-100, width: TGPhotoPickerConfig.ScreenW/3, height: 20))
        removeButtonHiddenButton.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        removeButtonHiddenButton.setTitle("removeHidden", for: .normal)
        removeButtonHiddenButton.setTitleColor(.white, for: .normal)
        removeButtonHiddenButton.setTitleColor(TGPhotoPickerConfig.shared.tinColor, for: .selected)
        removeButtonHiddenButton.backgroundColor = self.view.backgroundColor
        removeButtonHiddenButton.isSelected = TGPhotoPickerConfig.shared.isRemoveButtonHidden
        removeButtonHiddenButton.addTarget(self,action: #selector(isRemoveButtonHiddenAction(_:)),for: UIControlEvents.touchUpInside)
        self.view.addSubview(removeButtonHiddenButton)
        
        let leftAndRigthNoPaddingButton: UIButton = UIButton(frame: CGRect(x: removeButtonHiddenButton.frame.maxX, y: TGPhotoPickerConfig.ScreenH-100, width: TGPhotoPickerConfig.ScreenW/3, height: 20))
        leftAndRigthNoPaddingButton.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        leftAndRigthNoPaddingButton.setTitle("noLeftRigth", for: .normal)
        leftAndRigthNoPaddingButton.setTitleColor(.white, for: .normal)
        leftAndRigthNoPaddingButton.setTitleColor(TGPhotoPickerConfig.shared.tinColor, for: .selected)
        leftAndRigthNoPaddingButton.backgroundColor = self.view.backgroundColor
        leftAndRigthNoPaddingButton.isSelected = TGPhotoPickerConfig.shared.leftAndRigthNoPadding
        leftAndRigthNoPaddingButton.addTarget(self,action: #selector(leftAndRigthNoPaddingAction(_:)),for: UIControlEvents.touchUpInside)
        self.view.addSubview(leftAndRigthNoPaddingButton)
        
        let useiOS8CameraButton: UIButton = UIButton(frame: CGRect(x: leftAndRigthNoPaddingButton.frame.maxX, y: TGPhotoPickerConfig.ScreenH-100, width: TGPhotoPickerConfig.ScreenW/3, height: 20))
        useiOS8CameraButton.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        useiOS8CameraButton.setTitle("useiOS8Camera", for: .normal)
        useiOS8CameraButton.setTitleColor(.white, for: .normal)
        useiOS8CameraButton.setTitleColor(TGPhotoPickerConfig.shared.tinColor, for: .selected)
        useiOS8CameraButton.backgroundColor = self.view.backgroundColor
        useiOS8CameraButton.isSelected = TGPhotoPickerConfig.shared.useiOS8Camera
        useiOS8CameraButton.addTarget(self,action: #selector(useiOS8CameraAction(_:)),for: UIControlEvents.touchUpInside)
        self.view.addSubview(useiOS8CameraButton)
        
        let saveImageButton: UIButton = UIButton(frame: CGRect(x: 0, y: TGPhotoPickerConfig.ScreenH-120, width: TGPhotoPickerConfig.ScreenW/3, height: 20))
        saveImageButton.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        saveImageButton.setTitle("saveImage", for: .normal)
        saveImageButton.setTitleColor(.white, for: .normal)
        saveImageButton.setTitleColor(TGPhotoPickerConfig.shared.tinColor, for: .selected)
        saveImageButton.backgroundColor = self.view.backgroundColor
        saveImageButton.isSelected = TGPhotoPickerConfig.shared.saveImageToPhotoAlbum
        saveImageButton.addTarget(self,action: #selector(saveImageAction(_:)),for: UIControlEvents.touchUpInside)
        self.view.addSubview(saveImageButton)
        
        let customSheetButton: UIButton = UIButton(frame: CGRect(x: saveImageButton.frame.maxX, y: TGPhotoPickerConfig.ScreenH-120, width: TGPhotoPickerConfig.ScreenW/3, height: 20))
        customSheetButton.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        customSheetButton.setTitle("customSheet", for: .normal)
        customSheetButton.setTitleColor(.white, for: .normal)
        customSheetButton.setTitleColor(TGPhotoPickerConfig.shared.tinColor, for: .selected)
        customSheetButton.backgroundColor = self.view.backgroundColor
        customSheetButton.isSelected = TGPhotoPickerConfig.shared.useCustomActionSheet
        customSheetButton.addTarget(self,action: #selector(useCustomActionSheetAction(_:)),for: UIControlEvents.touchUpInside)
        self.view.addSubview(customSheetButton)
        
        let editButton: UIButton = UIButton(frame: CGRect(x: customSheetButton.frame.maxX, y: TGPhotoPickerConfig.ScreenH-120, width: TGPhotoPickerConfig.ScreenW/3, height: 20))
        editButton.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        editButton.setTitle("showEdit", for: .normal)
        editButton.setTitleColor(.white, for: .normal)
        editButton.setTitleColor(TGPhotoPickerConfig.shared.tinColor, for: .selected)
        editButton.backgroundColor = self.view.backgroundColor
        editButton.isSelected = TGPhotoPickerConfig.shared.isShowEditButton
        editButton.addTarget(self,action: #selector(showEditAction(_:)),for: UIControlEvents.touchUpInside)
        self.view.addSubview(editButton)
        
        let previewButton: UIButton = UIButton(frame: CGRect(x: 0, y: TGPhotoPickerConfig.ScreenH-140, width: TGPhotoPickerConfig.ScreenW/3, height: 20))
        previewButton.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        previewButton.setTitle("showPreview", for: .normal)
        previewButton.setTitleColor(.white, for: .normal)
        previewButton.setTitleColor(TGPhotoPickerConfig.shared.tinColor, for: .selected)
        previewButton.backgroundColor = self.view.backgroundColor
        previewButton.isSelected = TGPhotoPickerConfig.shared.isShowPreviewButton
        previewButton.addTarget(self,action: #selector(showPreviewAction(_:)),for: UIControlEvents.touchUpInside)
        self.view.addSubview(previewButton)
        
        let reselectButton: UIButton = UIButton(frame: CGRect(x: previewButton.frame.maxX, y: TGPhotoPickerConfig.ScreenH-140, width: TGPhotoPickerConfig.ScreenW/3, height: 20))
        reselectButton.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        reselectButton.setTitle("showReselect", for: .normal)
        reselectButton.setTitleColor(.white, for: .normal)
        reselectButton.setTitleColor(TGPhotoPickerConfig.shared.tinColor, for: .selected)
        reselectButton.backgroundColor = self.view.backgroundColor
        reselectButton.isSelected = TGPhotoPickerConfig.shared.isShowReselect
        reselectButton.addTarget(self,action: #selector(showReselectAction(_:)),for: UIControlEvents.touchUpInside)
        self.view.addSubview(reselectButton)
        
        let originalButton: UIButton = UIButton(frame: CGRect(x: reselectButton.frame.maxX, y: TGPhotoPickerConfig.ScreenH-140, width: TGPhotoPickerConfig.ScreenW/3, height: 20))
        originalButton.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        originalButton.setTitle("showOriginal", for: .normal)
        originalButton.setTitleColor(.white, for: .normal)
        originalButton.setTitleColor(TGPhotoPickerConfig.shared.tinColor, for: .selected)
        originalButton.backgroundColor = self.view.backgroundColor
        originalButton.isSelected = TGPhotoPickerConfig.shared.isShowOriginal
        originalButton.addTarget(self,action: #selector(showOriginalAction(_:)),for: UIControlEvents.touchUpInside)
        self.view.addSubview(originalButton)
        
        let indicatorButton: UIButton = UIButton(frame: CGRect(x: 0, y: TGPhotoPickerConfig.ScreenH-160, width: TGPhotoPickerConfig.ScreenW/3, height: 20))
        indicatorButton.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        indicatorButton.setTitle("showIndicator", for: .normal)
        indicatorButton.setTitleColor(.white, for: .normal)
        indicatorButton.setTitleColor(TGPhotoPickerConfig.shared.tinColor, for: .selected)
        indicatorButton.backgroundColor = self.view.backgroundColor
        indicatorButton.isSelected = TGPhotoPickerConfig.shared.isShowIndicator
        indicatorButton.addTarget(self,action: #selector(showIndicatorAction(_:)),for: UIControlEvents.touchUpInside)
        self.view.addSubview(indicatorButton)
    }
    
    func showIndicatorAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        TGPhotoPickerConfig.shared.isShowIndicator = sender.isSelected
    }
    
    func showPreviewAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        TGPhotoPickerConfig.shared.isShowPreviewButton = sender.isSelected
    }
    
    func showReselectAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        TGPhotoPickerConfig.shared.isShowReselect = sender.isSelected
    }
    
    func showOriginalAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        TGPhotoPickerConfig.shared.isShowOriginal = sender.isSelected
    }
    
    func showEditAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        TGPhotoPickerConfig.shared.isShowEditButton = sender.isSelected
    }
    
    func useCustomActionSheetAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        TGPhotoPickerConfig.shared.useCustomActionSheet = sender.isSelected
    }
    
    func saveImageAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        TGPhotoPickerConfig.shared.saveImageToPhotoAlbum = sender.isSelected
    }
    
    func useiOS8CameraAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        TGPhotoPickerConfig.shared.useiOS8Camera = sender.isSelected
    }
    
    func isRemoveButtonHiddenAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        TGPhotoPickerConfig.shared.isRemoveButtonHidden = sender.isSelected
    }
    
    func leftAndRigthNoPaddingAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        TGPhotoPickerConfig.shared.leftAndRigthNoPadding = sender.isSelected
    }
    
    func showBorderAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        TGPhotoPickerConfig.shared.isShowBorder = sender.isSelected
    }
    
    func useCustomSmartCollectionsMaskAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        TGPhotoPickerConfig.shared.useCustomSmartCollectionsMask = sender.isSelected
    }
    
    func useChineseAlbumNameAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        TGPhotoPickerConfig.shared.useChineseAlbumName = sender.isSelected
    }
    
    func showEmptyAlbumAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        TGPhotoPickerConfig.shared.isShowEmptyAlbum = sender.isSelected
    }
    
    func ascendingAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        TGPhotoPickerConfig.shared.ascending = sender.isSelected
    }
    
    func checkboxAnimateAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        TGPhotoPickerConfig.shared.checkboxAnimate = sender.isSelected
    }
    
    func showSelectNumberAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        TGPhotoPickerConfig.shared.isShowNumber = sender.isSelected
    }
    
    func immediateTapSelectAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        TGPhotoPickerConfig.shared.immediateTapSelect = sender.isSelected
    }
    
    func useSelectMaskAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        TGPhotoPickerConfig.shared.useSelectMask = sender.isSelected
    }
    
    func maxImageCountChangedAction(_ sender: UISlider) {
        maxImageCountLabel.text = "maxImage(\(Int(sender.value)))"
        TGPhotoPickerConfig.shared.maxImageCount = Int(sender.value)
    }
    
    func randomColor(_ sender: UIButton) {
        let r = CGFloat(arc4random() % 256) / 255.0
        let g = CGFloat(arc4random() % 256) / 255.0
        let b = CGFloat(arc4random() % 256) / 255.0
        let color = UIColor(red: r, green: g, blue: b, alpha: 1)
        sender.backgroundColor = color
        TGPhotoPickerConfig.shared.tinColor = color
    }
    
    func checkboxCellSizeAction(_ sender: UISlider) {
        checkboxCellSizeLabel.text = "checkWH(\(String(format: "%.2f",sender.value)))"
        TGPhotoPickerConfig.shared.checkboxCellWH = CGFloat(sender.value)
    }
    
    func shadowWHAction(_ sender: UISlider) {
        shadowWHLabel.text = "shadowWH(\(String(format: "%.2f",sender.value)))"
        TGPhotoPickerConfig.shared.shadowW = CGFloat(sender.value)
        TGPhotoPickerConfig.shared.shadowH = CGFloat(sender.value)
    }
    
    func maskAlphaChangedAction(_ sender: UISlider) {
        maskAlphaLabel.text = "maskAlpha(\(String(format: "%.2f",sender.value)))"
        TGPhotoPickerConfig.shared.maskAlpha = CGFloat(sender.value)
    }
    
    func endAlphaChangedAction(_ sender: UISlider) {
        endAlphaLabel.text = "endAlpha(\(String(format: "%.2f",sender.value)))"
        TGPhotoPickerConfig.shared.checkboxEndingAlpha = CGFloat(sender.value)
    }
    
    func lineWidthChangedAction(_ sender: UISlider) {
        lineWidthLabel.text = "lineWidth(\(String(format: "%.2f",sender.value)))"
        TGPhotoPickerConfig.shared.checkboxLineW = CGFloat(sender.value)
    }
    
    func paddingChangedAction(_ sender: UISlider) {
        paddingLabel.text = "padding(\(String(format: "%.2f",sender.value)))"
        TGPhotoPickerConfig.shared.checkboxPadding = CGFloat(sender.value)
    }
    
    func cornerChangedAction(_ sender: UISlider) {
        cornerLabel.text = "corner(\(String(format: "%.2f",sender.value)))"
        TGPhotoPickerConfig.shared.checkboxCorner = CGFloat(sender.value)
    }
    
    func tap(_ sender: UIButton) {
        TGPhotoPickerConfig.shared.checkboxType = TGCheckboxType(rawValue: sender.tag-1000)!
        TGPhotoPickerConfig.shared.removeType = TGCheckboxType(rawValue: sender.tag-1000)!
        for i in 0...TGCheckboxType.star.rawValue{
            (self.view.viewWithTag(1000+i) as! UIButton).isSelected = false
        }
        sender.isSelected = true
    }
    
    func indicatorPosition(_ sender: UIButton) {
        TGPhotoPickerConfig.shared.indicatorPosition = TGIndicatorPosition(rawValue: sender.tag-4000)!
        for i in 0...TGIndicatorPosition.inTopBar.rawValue{
            (self.view.viewWithTag(4000+i) as! UIButton).isSelected = false
        }
        sender.isSelected = true
    }
    
    func selectKind(_ sender: UIButton) {
        TGPhotoPickerConfig.shared.selectKind = TGSelectKind(rawValue: sender.tag-3000)!
        for i in 0...TGSelectKind.all.rawValue{
            (self.view.viewWithTag(3000+i) as! UIButton).isSelected = false
        }
        sender.isSelected = true
    }

    func position(_ sender: UIButton) {
        TGPhotoPickerConfig.shared.checkboxPosition = TGCheckboxPosition(rawValue: sender.tag-2000)!
        TGPhotoPickerConfig.shared.removePosition = TGCheckboxPosition(rawValue: sender.tag-2000)!
        for i in 0...TGCheckboxPosition.bottomRight.rawValue{
            (self.view.viewWithTag(2000+i) as! UIButton).isSelected = false
        }
        sender.isSelected = true
    }
    
    func upLoadData(){
        var dataArray = [Data]()
        for model in picker.tgphotos {
            dataArray.append(model.imageData!)
        }
        //上传Data数组
    }

    private lazy var maxImageCountLabel: UILabel = {
        let maxImageCountLabel = UILabel(frame: CGRect(x: 10, y: 370, width: 100, height: 20))
        maxImageCountLabel.text = "maxImage(\(TGPhotoPickerConfig.shared.maxImageCount))"
        maxImageCountLabel.textColor = .white
        maxImageCountLabel.font = UIFont.systemFont(ofSize: 12)
        return maxImageCountLabel
    }()
    
    private lazy var checkboxCellSizeLabel: UILabel = {
        let checkboxCellSizeLabel = UILabel(frame: CGRect(x: 10, y: 390, width: 100, height: 20))
        checkboxCellSizeLabel.text = "checkWH(\(TGPhotoPickerConfig.shared.checkboxCellWH))"
        checkboxCellSizeLabel.textColor = .white
        checkboxCellSizeLabel.font = UIFont.systemFont(ofSize: 12)
        return checkboxCellSizeLabel
    }()
    
    private lazy var shadowWHLabel: UILabel = {
        let shadowWHLabel = UILabel(frame: CGRect(x: 10, y: 410, width: 100, height: 20))
        shadowWHLabel.text = "shadowWH(\(TGPhotoPickerConfig.shared.shadowW))"
        shadowWHLabel.textColor = .white
        shadowWHLabel.font = UIFont.systemFont(ofSize: 12)
        return shadowWHLabel
    }()
    
    private lazy var cornerLabel: UILabel = {
        let cornerLabel = UILabel(frame: CGRect(x: 10, y: 270, width: 100, height: 20))
        cornerLabel.text = "corner(\(TGPhotoPickerConfig.shared.checkboxCorner))"
        cornerLabel.textColor = .white
        cornerLabel.font = UIFont.systemFont(ofSize: 12)
        return cornerLabel
    }()
    
    private lazy var paddingLabel: UILabel = {
        let paddingLabel = UILabel(frame: CGRect(x: 10, y: 290, width: 100, height: 20))
        paddingLabel.text = "padding(\(TGPhotoPickerConfig.shared.checkboxPadding))"
        paddingLabel.textColor = .white
        paddingLabel.font = UIFont.systemFont(ofSize: 12)
        return paddingLabel
    }()
    
    private lazy var lineWidthLabel: UILabel = {
        let lineWidthLabel = UILabel(frame: CGRect(x: 10, y: 310, width: 100, height: 20))
        lineWidthLabel.text = "lineWidth(\(TGPhotoPickerConfig.shared.checkboxLineW))"
        lineWidthLabel.textColor = .white
        lineWidthLabel.font = UIFont.systemFont(ofSize: 12)
        return lineWidthLabel
    }()
    
    private lazy var endAlphaLabel: UILabel = {
        let endAlphaLabel = UILabel(frame: CGRect(x: 10, y: 330, width: 100, height: 20))
        endAlphaLabel.text = "endAlpha(\(TGPhotoPickerConfig.shared.checkboxEndingAlpha))"
        endAlphaLabel.textColor = .white
        endAlphaLabel.font = UIFont.systemFont(ofSize: 12)
        return endAlphaLabel
    }()
    
    private lazy var maskAlphaLabel: UILabel = {
        let maskAlphaLabel = UILabel(frame: CGRect(x: 10, y: 350, width: 100, height: 20))
        maskAlphaLabel.text = "maskAlpha(\(TGPhotoPickerConfig.shared.maskAlpha))"
        maskAlphaLabel.textColor = .white
        maskAlphaLabel.font = UIFont.systemFont(ofSize: 12)
        return maskAlphaLabel
    }()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        /** 其他使用方式 模型数组*/
        /*
        TGPhotoPickerManager.shared.takePhotoModels(true, true) { (array) in
            self.picker.tgphotos.removeAll()
            self.picker.tgphotos.append(contentsOf: array)
            DispatchQueue.main.async {
                self.picker.reloadData()
            }
        }
        */
        
        /** 其他使用方式 4个分开的数组*/
        /*
        TGPhotoPickerManager.shared.takePhotos(true, true, { (config) in
            //链式配置
            config.tg_type(TGPhotoPickerType.weibo)
                .tg_confirmTitle("我知道了")
                .tg_maxImageCount(12)
        }) { (asset, smallImg, bigImg, data) in
            self.picker.tgphotos.removeAll()
            for i in 0..<smallImg.count {
                let model = TGPhotoM()
                model.asset = asset[i]
                model.smallImage = smallImg[i]
                model.bigImage = bigImg[i]
                model.imageData = data[i]
                self.picker.tgphotos.append(model)
            }
            DispatchQueue.main.async {
                self.picker.reloadData()
            }
        }
        */
    }
}

