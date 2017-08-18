//
//  TGCameraVCForiOS8.swift
//  TGPhotoPicker
//
//  Created by targetcloud on 2017/8/11.
//  Copyright © 2017年 targetcloud. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

class TGCameraVCForiOS8: UIViewController {

    var callbackPicutureData: ((Data?) -> ())?
    
    fileprivate var device: AVCaptureDevice?
    fileprivate lazy var session : AVCaptureSession = AVCaptureSession()
    fileprivate lazy var previewLayer : AVCaptureVideoPreviewLayer = AVCaptureVideoPreviewLayer(session: self.session)
    fileprivate lazy var imageOutput : AVCaptureStillImageOutput = AVCaptureStillImageOutput()
    fileprivate var input : AVCaptureDeviceInput?
    fileprivate var showImageContainerView: UIView?
    fileprivate var showImageView: UIImageView?
    fileprivate var flashMode: AVCaptureFlashMode = .auto
    fileprivate var picData: Data?
    fileprivate var image: UIImage?
    
    fileprivate lazy var takeButton: UIButton = {
        let takeButton = UIButton(frame: CGRect(x: 0, y: 0, width: TGPhotoPickerConfig.shared.takeWH, height: TGPhotoPickerConfig.shared.takeWH))
        takeButton.center = CGPoint(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height - TGPhotoPickerConfig.shared.buttonEdge.bottom)
        takeButton.setImage(UIImage.size(width: TGPhotoPickerConfig.shared.takeWH, height: TGPhotoPickerConfig.shared.takeWH).border(width: 3).border(color: .white).color(.clear).corner(radius: TGPhotoPickerConfig.shared.takeWH / 2).image +
            UIImage.size(width: TGPhotoPickerConfig.shared.takeWH - 10, height: TGPhotoPickerConfig.shared.takeWH - 10).color(UIColor(white: 0.95, alpha: 1) ).corner(radius: (TGPhotoPickerConfig.shared.takeWH - 10) / 2).image, for: .normal)
        takeButton.setImage(UIImage.size(width: TGPhotoPickerConfig.shared.takeWH, height: TGPhotoPickerConfig.shared.takeWH).border(width: 3).border(color: .white).color(.clear).corner(radius: TGPhotoPickerConfig.shared.takeWH / 2).image +
            UIImage.size(width: TGPhotoPickerConfig.shared.takeWH - 10, height: TGPhotoPickerConfig.shared.takeWH - 10).color(UIColor(white: 0.8, alpha: 1) ).corner(radius: (TGPhotoPickerConfig.shared.takeWH - 10) / 2).image, for: .highlighted)
        takeButton.addTarget(self, action: #selector(takePhotoAction), for: .touchUpInside)
        return takeButton
    }()
    
    fileprivate lazy var cameraChangeButton: UIButton = {
        let cameraChangeButton = UIButton(frame: CGRect(x: 0, y: 0, width: TGPhotoPickerConfig.shared.takeWH * 0.6, height: TGPhotoPickerConfig.shared.takeWH * 0.6))
        cameraChangeButton.setImage(TGPhotoPickerConfig.getImageNo2x3xSuffix("camera"), for: .normal)
        cameraChangeButton.center = CGPoint(x: UIScreen.main.bounds.width - TGPhotoPickerConfig.shared.buttonEdge.right, y: self.takeButton.center.y)
        cameraChangeButton.addTarget(self, action: #selector(changeCameraPositionAction), for: .touchUpInside)
        cameraChangeButton.contentMode = .scaleAspectFit
        return cameraChangeButton
    }()
    
    fileprivate lazy var flashButton: UIButton = {
        let flashChangeButton = UIButton(frame: CGRect(x: 0, y: 0, width: TGPhotoPickerConfig.shared.takeWH * 0.5, height: TGPhotoPickerConfig.shared.takeWH * 0.5))
        flashChangeButton.center = CGPoint(x: self.cameraChangeButton.center.x, y: TGPhotoPickerConfig.shared.buttonEdge.top)
        flashChangeButton.setImage(TGPhotoPickerConfig.getImageNo2x3xSuffix("flashauto"), for: .normal)
        flashChangeButton.addTarget(self, action: #selector(flashChangeAction), for: .touchUpInside)
        flashChangeButton.contentMode = .scaleAspectFit
        return flashChangeButton
    }()
    
    @objc fileprivate func flashChangeAction(){
        guard let device = device  else {
            return
        }
        do {
            try device.lockForConfiguration()
            switch flashMode {
            case .auto:
                if device.isFlashModeSupported(.on) {
                    device.flashMode = .on
                    flashMode = .on
                    flashButton.setImage(TGPhotoPickerConfig.getImageNo2x3xSuffix("flash"), for: .normal)
                }
            case .on:
                if device.isFlashModeSupported(.off) {
                    device.flashMode = .off
                    flashMode = .off
                    flashButton.setImage(TGPhotoPickerConfig.getImageNo2x3xSuffix("flashno"), for: .normal)
                }
            case .off:
                if device.isFlashModeSupported(.auto) {
                    device.flashMode = .auto
                    flashMode = .auto
                    flashButton.setImage(TGPhotoPickerConfig.getImageNo2x3xSuffix("flashauto"), for: .normal)
                }
            }
            device.unlockForConfiguration()
        } catch {
            return
        }
    }
    
    fileprivate func canUseCamera(returnClosure:@escaping (Bool)->()){
        TGPhotoPickerManager.shared.authorizePhotoLibrary { (status) in
            returnClosure(status == .authorized)
        }
        /*
        let authStatus = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
        if authStatus == .denied{
            let alertView = UIAlertView(title: TGPhotoPickerConfig.shared.cameraUsage, message: TGPhotoPickerConfig.shared.cameraUsageTip, delegate: self, cancelButtonTitle: TGPhotoPickerConfig.shared.confirmTitle, otherButtonTitles: TGPhotoPickerConfig.shared.cancelTitle)
            alertView.tag = TGPhotoPickerConfig.shared.alertViewTag
            alertView.show()
            return false
        }else{
            return true
        }
        */
    }
    
    fileprivate func canUseAlbum(returnClosure:@escaping (Bool)->()){
        TGPhotoPickerManager.shared.authorizePhotoLibrary { (status) in
            returnClosure(status == .authorized)
        }
        /*
        if PHPhotoLibrary.authorizationStatus() != PHAuthorizationStatus.authorized {
            let alertView = UIAlertView(title: TGPhotoPickerConfig.shared.PhotoLibraryUsage, message: TGPhotoPickerConfig.shared.PhotoLibraryUsageTip, delegate: self, cancelButtonTitle: TGPhotoPickerConfig.shared.confirmTitle, otherButtonTitles: TGPhotoPickerConfig.shared.cancelTitle)
            alertView.tag = TGPhotoPickerConfig.shared.alertViewTag
            alertView.show()
            return false
        }else{
            return true
        }
        */
    }
    
    fileprivate lazy var focusView: UIView = {
        let focusView =  UIView(frame: CGRect(x: 0, y: 0, width: TGPhotoPickerConfig.shared.focusViewWH, height: TGPhotoPickerConfig.shared.focusViewWH))
        focusView.layer.borderWidth = 1.0
        focusView.layer.borderColor = TGPhotoPickerConfig.shared.tinColor.cgColor
        focusView.backgroundColor = .clear
        focusView.isHidden = true
        return focusView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        canUseCamera { (canUse) in
            if canUse{
                self.setupCamera()
                self.setupUI()
            }
        }
        
        if #available(iOS 9.0, *) {
            let isVCBased = Bundle.main.infoDictionary?["UIViewControllerBasedStatusBarAppearance"] as? Bool ?? false
            if !isVCBased{
                UIApplication.shared.setStatusBarHidden(false, with: .none)
            }
        }else {
            UIApplication.shared.statusBarStyle = .lightContent
            UIApplication.shared.setStatusBarHidden(false, with: .none)
        }
    }
    
    override var prefersStatusBarHidden: Bool{
        return false
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    fileprivate func setupUI(){
        self.view.addSubview(self.takeButton)
        self.view.addSubview(self.focusView)
        self.view.addSubview(self.cameraChangeButton)
        self.view.addSubview(self.flashButton)
        
        let backButton = UIButton(frame: CGRect(x: 0, y: 0, width: TGPhotoPickerConfig.shared.takeWH * 0.4, height: TGPhotoPickerConfig.shared.takeWH * 0.4))
        backButton.center = CGPoint(x: TGPhotoPickerConfig.shared.buttonEdge.left , y: self.flashButton.center.y)
        backButton.setImage(UIImage.size(width: TGPhotoPickerConfig.shared.takeWH * 0.4, height: TGPhotoPickerConfig.shared.takeWH * 0.4)
            .corner(radius: TGPhotoPickerConfig.shared.takeWH * 0.2)
            .color(.clear)
            .border(color: UIColor.white.withAlphaComponent(0.7))
            .border(width: TGPhotoPickerConfig.shared.isShowBorder ? TGPhotoPickerConfig.shared.checkboxLineW : 0)
            .image
            .with({ context in
                context.setLineCap(.round)
                UIColor.white.setStroke()
                context.setLineWidth(TGPhotoPickerConfig.shared.checkboxLineW)
                let WH = TGPhotoPickerConfig.shared.takeWH * 0.4
                context.move(to: CGPoint(x: WH * 0.6, y: WH * 0.2))
                context.addLine(to: CGPoint(x: WH * 0.35, y: WH * 0.5))
                context.move(to: CGPoint(x: WH * 0.35, y: WH * 0.5))
                context.addLine(to: CGPoint(x: WH * 0.6, y: WH * 0.8))
                context.strokePath()
            }), for: .normal)
        backButton.contentMode = .scaleAspectFit
        backButton.addTarget(self, action: #selector(backAction), for: .touchUpInside)
        view.addSubview(backButton)
        
        showImageContainerView = UIView(frame: view.bounds)
        showImageContainerView?.backgroundColor = TGPhotoPickerConfig.shared.previewBGColor
        view.addSubview(showImageContainerView!)
        
        let height = showImageContainerView!.bounds.height - TGPhotoPickerConfig.shared.takeWH - TGPhotoPickerConfig.shared.buttonEdge.bottom - TGPhotoPickerConfig.shared.previewPadding * 2
        showImageView = UIImageView(frame: CGRect(x: TGPhotoPickerConfig.shared.previewPadding, y: TGPhotoPickerConfig.shared.previewPadding * 2, width: showImageContainerView!.bounds.width - 2 * TGPhotoPickerConfig.shared.previewPadding, height: height))
        showImageView?.layer.masksToBounds = true
        showImageView?.contentMode = .scaleAspectFit
        showImageContainerView?.addSubview(showImageView!)
        showImageContainerView?.isHidden = true
        
        let giveupButton = createImageOperatorButton(nil, CGPoint(x: TGPhotoPickerConfig.shared.takeWH * 1.5, y: showImageContainerView!.bounds.height - TGPhotoPickerConfig.shared.takeWH * 1.5), TGPhotoPickerConfig.shared.getCheckboxImage(true, true, .circle, TGPhotoPickerConfig.shared.takeWH * 0.7).unselect)
        giveupButton.addTarget(self, action: #selector(giveupImageAction), for: .touchUpInside)
        showImageContainerView?.addSubview(giveupButton)
        
        let ensureButton = createImageOperatorButton(nil, CGPoint(x: showImageContainerView!.bounds.width - TGPhotoPickerConfig.shared.takeWH * 1.5, y: showImageContainerView!.bounds.height - TGPhotoPickerConfig.shared.takeWH * 1.5), TGPhotoPickerConfig.shared.getCheckboxImage(true, false, .circle, TGPhotoPickerConfig.shared.takeWH * 0.7).select)
        ensureButton.addTarget(self, action: #selector(useImageAction), for: .touchUpInside)
        showImageContainerView?.addSubview(ensureButton)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(focusGesture))
        self.view.addGestureRecognizer(tapGesture)
    }
    
    private func createImageOperatorButton(_ title: String?, _ center: CGPoint, _ img: UIImage?) -> UIButton {
        let btn = UIButton(frame: CGRect(x: 0, y: 0, width: TGPhotoPickerConfig.shared.takeWH * 0.7, height: TGPhotoPickerConfig.shared.takeWH * 0.7))
        btn.center = center
        btn.setTitle(title, for: .normal)
        btn.setImage(img, for: .normal)
        btn.contentMode = .scaleAspectFit
        return btn
    }
    
    @objc private func backAction() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func giveupImageAction() {
        showImageView?.image = UIImage()
        showImageContainerView?.isHidden = true
    }
    
    @objc private func useImageAction() {
        callbackPicutureData?(picData)
        dismiss(animated: true, completion: nil)
    }
    
    @objc fileprivate func focusGesture(gesture: UITapGestureRecognizer){
        let point = gesture.location(in: gesture.view)
        focusAtPoint(point)
    }
    
    fileprivate func focusAtPoint(_ point: CGPoint){
        let size = self.view.bounds.size
        let focusPoint = CGPoint(x: point.y/size.height, y: 1-point.x/size.width)
        do {
            try device?.lockForConfiguration()
        } catch {
            return
        }
        if device?.isFocusModeSupported(AVCaptureFocusMode.autoFocus) ?? false{
            device?.focusPointOfInterest = focusPoint
            device?.focusMode = .autoFocus
        }
        if device?.isExposureModeSupported(AVCaptureExposureMode.autoExpose) ?? false{
            device?.exposurePointOfInterest = focusPoint
            device?.exposureMode = .autoExpose
        }
        device?.unlockForConfiguration()
        focusView.center = point
        focusView.isHidden = false
        UIView.animate(withDuration: 0.3, animations: {
            self.focusView.transform = CGAffineTransform(scaleX: 1.25, y: 1.25)
        }) { (finished) in
            UIView.animate(withDuration: 0.5, animations: {
                self.focusView.transform = .identity
            }, completion: { (finished) in
                self.focusView.isHidden = true
            })
        }
    }
    
    fileprivate func setupCamera(){
        self.view.backgroundColor = .white
        setupVideo()
    }
    
    @objc fileprivate func changeCameraPositionAction() {
        let cameraCount = AVCaptureDevice.devices(withMediaType: AVMediaTypeVideo).count
        guard cameraCount>0 else { return }
        
        let rotaionAnim = CATransition()
        rotaionAnim.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        rotaionAnim.type = TGPhotoPickerConfig.shared.transitionType
        rotaionAnim.duration = 0.5
        
        guard let videoInput = input else { return }
        let position : AVCaptureDevicePosition = videoInput.device.position == .front ? .back : .front
        rotaionAnim.subtype = (position == .front) ? "fromRight" : "fromLeft"
        
        guard let devices = AVCaptureDevice.devices(withMediaType: AVMediaTypeVideo) as? [AVCaptureDevice] else { return }
        guard let newDevice = devices.filter({$0.position == position}).first else { return }
        guard let newVideoInput = try? AVCaptureDeviceInput(device: newDevice) else { return }
        
        previewLayer.add(rotaionAnim, forKey: nil)
        
        session.beginConfiguration()
        session.removeInput(videoInput)
        if session.canAddInput(newVideoInput) {
            session.addInput(newVideoInput)
            self.input = newVideoInput
        } else {
            session.addInput(input)
        }
        session.commitConfiguration()
    }
    
    @objc fileprivate func takePhotoAction(){
        guard let videoConnection = imageOutput.connection(withMediaType: AVMediaTypeVideo) else { return }
        imageOutput.captureStillImageAsynchronously(from: videoConnection) { (imageDataSampleBuffer, error) in
            if error != nil {
                print("error = \(String(describing: error?.localizedDescription))")
            } else {
                guard imageDataSampleBuffer != nil  else {return}
                guard let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageDataSampleBuffer) else {return}
                
                self.picData = imageData
                self.showImageContainerView?.isHidden = false
                self.image = UIImage(data: imageData)
                self.showImageView?.image = self.image
                
                if TGPhotoPickerConfig.shared.saveImageToPhotoAlbum{
                    self.saveImageToPhotoAlbum(self.image!)
                }
                
                print("image size\(String(describing: self.image?.size))")
            }
        }
    }
    
    fileprivate func saveImageToPhotoAlbum(_ savedImage:UIImage){
        canUseAlbum { (canUse) in
            if canUse{
                UIImageWriteToSavedPhotosAlbum(savedImage, self, #selector(self.imageDidFinishSavingWithErrorContextInfo), nil)
            }
        }
    }
    
    @objc fileprivate func imageDidFinishSavingWithErrorContextInfo(image:UIImage,error:NSError?,contextInfo:UnsafeMutableRawPointer?){
        canUseAlbum { (canUse) in
            if canUse{
                let msg = (error != nil) ? (TGPhotoPickerConfig.shared.saveImageFailTip+"("+(error?.localizedDescription)!+")") : TGPhotoPickerConfig.shared.saveImageSuccessTip
                if !TGPhotoPickerConfig.shared.showCameraSaveSuccess && error == nil{
                    return
                }
                let alert =  UIAlertView(title: TGPhotoPickerConfig.shared.saveImageTip, message: msg, delegate: self, cancelButtonTitle: TGPhotoPickerConfig.shared.confirmTitle)
                alert.show()
            }
        }
    }
    
    fileprivate func setupVideo() {
        guard let devices = AVCaptureDevice.devices(withMediaType: AVMediaTypeVideo) as? [AVCaptureDevice] else {return}
        guard let device = devices.filter({$0.position == .back}).first else {return}
        guard let videoInput = try? AVCaptureDeviceInput(device: device) else {return}
        self.input = videoInput
        self.device = device
        
        if session.canSetSessionPreset(TGPhotoPickerConfig.shared.sessionPreset) {
            session.sessionPreset = TGPhotoPickerConfig.shared.sessionPreset
        }
        if session.canAddInput(input) {
            session.addInput(input)
        }else{
            session.addInput(videoInput)
        }
        if session.canAddOutput(imageOutput) {
            session.addOutput(imageOutput)
        }else{
            session.addOutput(imageOutput)
        }
        
        previewLayer.frame = view.bounds
        self.previewLayer.videoGravity = TGPhotoPickerConfig.shared.videoGravity
        view.layer.insertSublayer(previewLayer, at: 0)
        session.startRunning()
        
        do {
            try device.lockForConfiguration()
        } catch {
            return
        }
        if device.isFlashModeSupported(AVCaptureFlashMode.auto){
            device.flashMode = .auto
        }
        
        if device.isWhiteBalanceModeSupported(AVCaptureWhiteBalanceMode.autoWhiteBalance){
            device.whiteBalanceMode = .autoWhiteBalance
        }
        device.unlockForConfiguration()
    }
}
/*
extension TGCameraVCForiOS8: UIAlertViewDelegate{
    func alertView(_ alertView: UIAlertView, clickedButtonAt buttonIndex: Int) {
        if buttonIndex == 0 && alertView.tag == TGPhotoPickerConfig.shared.alertViewTag {
            guard let url = NSURL(string: UIApplicationOpenSettingsURLString) else {
                return
            }
            if UIApplication.shared.canOpenURL(url as URL){
                UIApplication.shared.openURL(url as URL)
            }
        }
    }
}
*/
