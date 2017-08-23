//
//  TGPhotoPicker.swift
//  TGPhotoPicker
//
//  Created by targetcloud on 2017/7/12.
//  Copyright © 2017年 targetcloud. All rights reserved.
//

import UIKit
import Photos

protocol TGPhotoPickerCellDelegate: class {
    func remove(_ model: TGPhotoM?)
}

private let reuseIdentifier = "TGPhotoPickerCell"

class TGPhotoPicker: UIView {

    lazy var tgphotos = [TGPhotoM]()
    
    fileprivate weak var vc: UIViewController?
    fileprivate weak var collectionView: UICollectionView?
    fileprivate lazy var config: TGPhotoPickerConfig = TGPhotoPickerConfig.shared

/*
 //apple
    fileprivate lazy var ipc:UIImagePickerController = {
        let ipc = UIImagePickerController()
        ipc.allowsEditing = true
        return ipc
    }()
 */
    
    fileprivate var fromIndex: Int = -1
    fileprivate var toIndex: Int = -1
    
    init(_ vc: UIViewController, frame: CGRect,_ configBlock:((_ config:TGPhotoPickerConfig)->())? = nil) {
        super.init(frame: frame)
        self.backgroundColor = .white
        self.vc = vc
        
        configBlock?(self.config)
        
        if self.config.autoSelectWH {
            self.config.selectWH = (frame.size.width - (self.config.colCount + (self.config.leftAndRigthNoPadding ? -1 : 1)) * self.config.padding) / self.config.colCount
            self.config.mainCellWH = (frame.size.width - (self.config.mainColCount + (self.config.leftAndRigthNoPadding ? -1 : 1)) * self.config.padding) / self.config.mainColCount
        }
        
        createCollectionView()
    }
    
    public class func photoPicker(_ vc: UIViewController, frame: CGRect, _ configBlock:((_ config:TGPhotoPickerConfig)->())? = nil) -> TGPhotoPicker{
        return TGPhotoPicker(vc,frame:frame,configBlock)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func createCollectionView(){
        vc?.automaticallyAdjustsScrollViewInsets = false
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(width: config.mainCellWH,height: config.mainCellWH)
        layout.minimumInteritemSpacing = config.padding
        layout.minimumLineSpacing = config.padding
        
        let cv = UICollectionView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: self.frame.size), collectionViewLayout: layout)
        cv.backgroundColor = .white
        cv.register(TGPickerCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        cv.delegate = self
        cv.dataSource = self
        cv.contentInset = UIEdgeInsetsMake(
            config.padding,
            config.leftAndRigthNoPadding ? 0 : config.padding,
            config.padding,
            self.bounds.width - config.mainColCount * config.mainCellWH - (config.mainColCount + (config.leftAndRigthNoPadding ? -1 : 0)) * config.padding
        )
        if #available(iOS 9.0, *) {
            cv.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(longPress)))
        }
        self.addSubview(cv)
        collectionView = cv
    }
    
    func reloadData(){
        self.collectionView?.reloadData()
    }

}

extension TGPhotoPicker : UICollectionViewDataSource{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tgphotos.count == config.maxImageCount ? tgphotos.count :  tgphotos.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! TGPickerCell
        cell.photoM = (indexPath.row == tgphotos.count) ? nil : tgphotos[indexPath.row]
        //cell.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(longPress)))
        cell.delegate = self
        return cell
    }
    
    @available(iOS 9.0, *)
    @objc fileprivate func longPress(sender: UILongPressGestureRecognizer){
        switch sender.state {
        case UIGestureRecognizerState.began:
            let point = sender.location(in: self.collectionView)
            if let indexpath = self.collectionView?.indexPathForItem(at: point),let cell = self.collectionView?.cellForItem(at: indexpath) as? TGPickerCell{
                guard cell.photoM != nil else {
                    return
                }
                cell.transform = CGAffineTransform(scaleX: 1.25, y: 1.25)
                cell.isMaskHidden = false
                self.collectionView?.beginInteractiveMovementForItem(at: indexpath)
                fromIndex = indexpath.item 
            }
        case UIGestureRecognizerState.changed:
            let point = sender.location(in: self.collectionView)
            if let index = self.collectionView?.indexPathForItem(at: point)?.item{
                if index >= 0 && index < self.tgphotos.count{
                    self.collectionView?.updateInteractiveMovementTargetPosition(point)
                    toIndex = index
                }
            }
        case UIGestureRecognizerState.ended:
            self.collectionView?.endInteractiveMovement()
            
            if let cell = self.collectionView?.cellForItem(at: IndexPath(row: toIndex, section: 0)) as? TGPickerCell{
                cell.transform = .identity
                cell.isMaskHidden = true
            }
            
            if fromIndex != toIndex && fromIndex >= 0 && toIndex >= 0{
                let fromM = tgphotos[fromIndex]
                tgphotos.remove(at: fromIndex)
                tgphotos.insert(fromM, at: toIndex)
            }
            fromIndex = -1
            toIndex = -1
        default:
            if let cell = self.collectionView?.cellForItem(at: IndexPath(row: fromIndex, section: 0)) as? TGPickerCell{
                cell.transform = .identity
                cell.isMaskHidden = true
            }
            self.collectionView?.cancelInteractiveMovement()
            fromIndex = -1
            toIndex = -1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return indexPath.item < self.tgphotos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
    }
}

extension TGPhotoPicker: TGPhotoPickerCellDelegate{
    func remove(_ model: TGPhotoM?) {
        guard let model = model,let index = self.tgphotos.index(of: model) else { return }
        if self.tgphotos.count == TGPhotoPickerConfig.shared.maxImageCount {//删除最大张数时的最后一张或中间一张
            DispatchQueue.main.async {
                (self.collectionView?.cellForItem(at: IndexPath(row: index, section: 0)) as! TGPickerCell).photoM = nil
                if (index != TGPhotoPickerConfig.shared.maxImageCount - 1){//中间
                    self.collectionView?.moveItem(at: IndexPath(row: index, section: 0), to: IndexPath(row: TGPhotoPickerConfig.shared.maxImageCount - 1, section: 0))
                }
            }
            self.tgphotos.remove(at: index)
        }else {
            DispatchQueue.main.async {
                self.collectionView?.deleteItems(at: [IndexPath(row: index, section: 0)])
            }
            self.tgphotos.remove(at: index)
        }
    }
}

extension TGPhotoPicker : UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == tgphotos.count {
            addPhoto(indexPath)
        }else{
            previewPhoto(indexPath.row)
        }
    }
    
    private func addPhoto(_ indexPath: IndexPath){
        if config.useCustomActionSheet{
            let sheet = TGActionSheet(delegate: self, /*title: "请选择",*/cancelTitle: config.cancelTitle, otherTitles: [config.cameraTitle, config.selectTitle])
            sheet.show()
            return
        }
        
        let ac = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let action1 = UIAlertAction(title: config.cameraTitle, style: .default) { (action) in
            /* 
            //apple
            self.ipc.delegate = self
            self.camera()
            */
            self.actionSheet(actionSheet: nil, didClickedAt: 0)
        }
        
        let action2 = UIAlertAction(title: config.selectTitle, style: .default) { (action) in
            self.actionSheet(actionSheet: nil, didClickedAt: 1)//self.addPhotos()
        }
        
        ac.addAction(action1)
        ac.addAction(action2)
        ac.addAction(UIAlertAction(title: config.cancelTitle, style: .cancel, handler: nil))
        
        vc?.present(ac, animated: true, completion: nil)
    }
    
/*
 //apple
    private func camera(){
        self.ipc.sourceType = .camera
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            vc?.present(self.ipc, animated: true, completion:nil)
        }
    }
 */
    
    fileprivate func addPhotos(){
        TGPhotoPickerManager.shared.authorizePhotoLibrary { (status) in
            if status == .authorized{
                let pickervc = TGPhotoPickerVC(type: .allAlbum)
                pickervc.imageSelectDelegate = self
                pickervc.alreadySelectedImageNum = self.tgphotos.count
                self.vc?.present(pickervc, animated: true, completion: nil)
            }
        }
    }
    
    private func previewPhoto(_ index: Int){
        let previewvc = TGPhotoPreviewVC()
        let nav = UINavigationController(rootViewController: previewvc)
        previewvc.selectImages = tgphotos
        previewvc.delegate = self
        previewvc.currentPage = index
        
        let animation = CATransition()
        animation.duration = 0.5
        animation.subtype = kCATransitionFromRight
        UIApplication.shared.keyWindow?.layer.add(animation, forKey: nil)
        
        vc?.present(nav, animated: false, completion: nil)
    }
}

extension TGPhotoPicker: TGActionSheetDelegate {
    func actionSheet(actionSheet: TGActionSheet?, didClickedAt index: Int) {
        switch index {
        case 0:
            if TGPhotoPickerConfig.shared.useiOS8Camera{
                let cameraVC = TGCameraVCForiOS8()
                cameraVC.callbackPicutureData = { [weak self] imgData in
                    let bigImg = UIImage(data:imgData!)
                    let imgData = UIImageJPEGRepresentation(bigImg!,TGPhotoPickerConfig.shared.compressionQuality)
                    let smallImg = bigImg
                    let model = TGPhotoM()
                    model.bigImage = bigImg
                    model.imageData = imgData
                    model.smallImage = smallImg
                    self?.tgphotos.append(model)
                    DispatchQueue.main.async {
                        self?.collectionView?.reloadData()
                    }
                }
                self.vc?.present(cameraVC, animated: true, completion: nil)
            }else if #available(iOS 10.0, *) {
                let cameraVC = TGCameraVC()
                cameraVC.callbackPicutureData = { [weak self] imgData in
                    let bigImg = UIImage(data:imgData!)
                    let imgData = UIImageJPEGRepresentation(bigImg!,TGPhotoPickerConfig.shared.compressionQuality)
                    let smallImg = bigImg
                    let model = TGPhotoM()
                    model.bigImage = bigImg
                    model.imageData = imgData
                    model.smallImage = smallImg
                    self?.tgphotos.append(model)
                    DispatchQueue.main.async {
                        self?.collectionView?.reloadData()
                    }
                }
                self.vc?.present(cameraVC, animated: true, completion: nil)
            }else{
                let cameraVC = TGCameraVCForiOS8()
                cameraVC.callbackPicutureData = { [weak self] imgData in
                    let bigImg = UIImage(data:imgData!)
                    let imgData = UIImageJPEGRepresentation(bigImg!,TGPhotoPickerConfig.shared.compressionQuality)
                    let smallImg = bigImg
                    let model = TGPhotoM()
                    model.bigImage = bigImg
                    model.imageData = imgData
                    model.smallImage = smallImg
                    self?.tgphotos.append(model)
                    DispatchQueue.main.async {
                        self?.collectionView?.reloadData()
                    }
                }
                self.vc?.present(cameraVC, animated: true, completion: nil)
            }
        case 1:
            self.addPhotos()
        default:
            break
        }
    }
}

extension TGPhotoPicker: TGPhotoPickerDelegate{
    func onImageSelectFinished(images: [PHAsset]) {
        TGPhotoM.getImagesAndDatas(photos: images) { array in
//            for model in array!{
//                self.tgphotos.append(model)
//            }
            self.tgphotos.append(contentsOf: array)
            DispatchQueue.main.async {
                self.collectionView?.reloadData()
            }
        }
    }
}

extension TGPhotoPicker: TGPhotoPreviewDelegate{
    func removeElement(element: TGPhotoM?) {
        if let current = element {
            self.tgphotos = self.tgphotos.filter({$0 != current})
        }
        collectionView?.reloadData()
    }
}

/*
 //apple
extension TGPhotoPicker: UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let type:String = (info[UIImagePickerControllerMediaType] as! String)
        if type == "public.image" {
            let bigImg = info[UIImagePickerControllerOriginalImage] as? UIImage
            let imgData = UIImageJPEGRepresentation(bigImg!, config.compressionQuality)
            let smallImg = info[UIImagePickerControllerEditedImage] as? UIImage
            let model = TGPhotoM()
            model.bigImage = bigImg
            model.imageData = imgData
            model.smallImage = smallImg
            self.tgphotos.append(model)
            
            collectionView?.reloadData()
            
            picker.dismiss(animated: true, completion: {
                self.ipc.delegate = nil
            })
        }
    }
    
    func imagePickerControllerDidCancel(_ picker:UIImagePickerController){
        picker.dismiss(animated:true, completion:{
            self.ipc.delegate = nil
        })
    }
    
}
 */

class TGPickerCell: UICollectionViewCell {
    weak var delegate: TGPhotoPickerCellDelegate?
    
    var photoM: TGPhotoM? {
        didSet {
            DispatchQueue.main.async {//[Generic] Creating an image format with an unknown type is an error
                if self.photoM == nil {
                    self.photoImage.image = self.addImage
                    self.removeBtn.isHidden = true
                }else{
                    self.photoImage.image = self.photoM?.smallImage
                    self.removeBtn.isHidden = TGPhotoPickerConfig.shared.isRemoveButtonHidden
                    let imageTuples = TGPhotoPickerConfig.shared.getCheckboxImage(true,true)
                    var x:CGFloat = 0
                    var y:CGFloat = 0
                    switch TGPhotoPickerConfig.shared.removePosition {
                    case .topLeft:
                        break
                    case .topRight:
                        x = self.frame.size.width - imageTuples.size.width
                    case .bottomLeft:
                        y = self.frame.size.width - imageTuples.size.height
                    case .bottomRight:
                        x = self.frame.size.width - imageTuples.size.width
                        y = self.frame.size.width - imageTuples.size.height
                    }
                    self.removeBtn.frame = CGRect(x: x, y: y, width: imageTuples.size.width, height: imageTuples.size.height)
                    self.removeBtn.setImage(imageTuples.unselect, for: .normal)
                    self.removeBtn.setImage(imageTuples.select, for: .highlighted)
                }
            }
        }
    }
    
    var isMaskHidden: Bool = true{
        didSet{
            self.maskV.isHidden = isMaskHidden
        }
    }
    
    private lazy var addImage: UIImage = {
        let M = TGPhotoPickerConfig.shared.mainCellWH
        return UIImage.size(width: M, height: M)
            .color(.clear)
            .border(color: .clear)
            .border(width: TGPhotoPickerConfig.shared.checkboxPadding)
            .image
            .with({ context in
                context.setLineCap(.round)
                UIColor.lightGray.setStroke()
                context.setLineWidth(TGPhotoPickerConfig.shared.checkboxLineW)
                context.move(to: CGPoint(x: M * 0.25, y: M * 0.5))
                context.addLine(to: CGPoint(x: M * 0.75, y: M * 0.5))
                context.move(to: CGPoint(x: M * 0.5, y: M * 0.25))
                context.addLine(to: CGPoint(x: M * 0.5, y: M * 0.75))
                context.strokePath()
                
                UIColor.lightGray.withAlphaComponent(0.9).setStroke()
                context.setLineDash(phase: 0,lengths: [10,5])
                context.setLineWidth(TGPhotoPickerConfig.shared.checkboxLineW)
                context.move(to: CGPoint(x:1, y: 1))
                context.addLine(to: CGPoint(x: M-1, y: 1))
                context.move(to: CGPoint(x: M-1, y: 1))
                context.addLine(to: CGPoint(x: M-1, y: M-1))
                context.move(to: CGPoint(x: M-1, y: M-1))
                context.addLine(to: CGPoint(x: 1, y: M-1))
                context.move(to: CGPoint(x: 1, y: M-1))
                context.addLine(to: CGPoint(x: 1, y: 1))
                context.strokePath()
            })
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.clipsToBounds = true
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        self.contentView.addSubview(self.photoImage)
        self.contentView.addSubview(self.removeBtn)
        self.contentView.addSubview(self.maskV)
    }
    
    private lazy var maskV: UIView = {
        let mask = UIView(frame: CGRect(x: 0, y: 0, width: TGPhotoPickerConfig.shared.selectWH, height: TGPhotoPickerConfig.shared.selectWH))
        let color = TGPhotoPickerConfig.shared.useSelectMask ? UIColor.black : UIColor.white
        mask.backgroundColor = color.withAlphaComponent(TGPhotoPickerConfig.shared.maskAlpha)
        mask.isHidden = true
        return mask
    }()
    
    private lazy var photoImage: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.frame = CGRect(x: 0, y: 0, width: TGPhotoPickerConfig.shared.mainCellWH, height: TGPhotoPickerConfig.shared.mainCellWH)
        return iv
    }()
    
    private lazy var removeBtn: UIButton = {
        let btn = UIButton()
        btn.addTarget(self, action: #selector(removeClicked), for: .touchUpInside)
        return btn
    }()
    
    @objc private func removeClicked(){
        delegate?.remove(self.photoM)
    }
}
