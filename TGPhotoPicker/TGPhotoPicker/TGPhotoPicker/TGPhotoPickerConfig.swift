//
//  TGPhotoPickerConfig.swift
//  TGPhotoPicker
//
//  Created by targetcloud on 2017/7/13.
//  Copyright © 2017年 targetcloud. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

enum TGPhotoPickerType : Int {
    case normal
    case wechat
    case weibo
}

enum TGCheckboxPosition : Int{
    case topLeft
    case topRight
    case bottomLeft
    case bottomRight
}

enum TGCheckboxType : Int{
    case onlyCheckbox
    case circle
    case square
    case belt
    case diagonalBelt
    case triangle
    case heart
    case star
}

@available(iOS 10.0, *)
class TGPhotoPickerConfig {
    static let ScreenW = UIScreen.main.bounds.width
    static let ScreenH = UIScreen.main.bounds.height
    static let factor: CGFloat = 0.111111
    
    static let shared : TGPhotoPickerConfig = TGPhotoPickerConfig()
    private init(){}
    
    /** 与useCustomSmartCollectionsMask结合使用,当useCustomSmartCollectionsMask为true时过滤需要显示smartAlbum的Album类型*/
    var customSmartCollections = [
        PHAssetCollectionSubtype.smartAlbumUserLibrary,//Camera Roll
        PHAssetCollectionSubtype.smartAlbumRecentlyAdded
    ]
    
    /** 使用自定义的PHAssetCollectionSubtype集合来过滤显示自己想要的相册夹,如想显示慢动作和自拍,那么上面的useCustomSmartCollectionsMask数组中设置为（或添加）[PHAssetCollectionSubtype.smartAlbumSlomoVideos,PHAssetCollectionSubtype.smartAlbumSelfPortraits]*/
    var useCustomSmartCollectionsMask: Bool = true
    
    /** 是否使用中文名称显示smartAlbum的Album名*/
    var useChineseAlbumName: Bool = false
    
    /** 空内容的相册夹是否显示 */
    var isShowEmptyAlbum: Bool = false
    
    /** 升序排列照片*/
    var ascending: Bool = false
    
    /** 预置的成组配置, 微博 微信*/
    var type: TGPhotoPickerType = .normal{
        didSet{
            switch type {
            case .normal: break
                
            case .wechat:
                let alpha = self.barBGColor.getAlpha()
                self.barBGColor = self.barBGColor.withAlphaComponent(alpha != 1 ? alpha : 0.9)
                self.checkboxType = .circle
                self.autoSelectWH = false
                self.mainColCount = 4
                self.isShowNumber = true
                self.immediateTapSelect = false
                self.removeType = .circle
            case .weibo:
                self.tinColor = .orange
                self.checkboxType = .circle
                self.autoSelectWH = true
                self.mainColCount = 3
                self.isShowNumber = false
                self.useSelectMask = true
                self.removeType = .square
                self.checkboxCorner = 5
            }
        }
    }
    
    /** 在选择类型为方 带时用到的Corner*/
    var checkboxCorner: CGFloat = 0{
        didSet{
            checkboxCorner = checkboxCorner>checkboxCellWH ? checkboxCellWH :(checkboxCorner<0 ? 0 :checkboxCorner)
            cacheNumberImage()
        }
    }
    
    /** 选择框显示的位置*/
    var checkboxPosition: TGCheckboxPosition = .topRight{
        didSet{
            cacheNumberImage()
        }
    }
    
    /** 移除按钮显示的位置*/
    var removePosition: TGCheckboxPosition = .topRight
    
    /** 移除类型,同选择类型*/
    var removeType: TGCheckboxType = .diagonalBelt{
        didSet{
            switch removeType {
            case .heart,.star:
                removeType = .circle
            default: break
            }
        }
    }
    
    /** 是否显示选择顺序*/
    var isShowNumber: Bool = true{
        didSet{
            cacheNumberImage()
        }
    }
    
    /** 纯数字模式下显示选择顺序时的数字阴影宽,不需要阴影设置为0*/
    var shadowW:CGFloat = 1.0{
        didSet{
            shadowW = shadowW>4 ? 4 :(shadowW<0 ? 0 :shadowW)
            cacheNumberImage()
        }
    }
    
    /** 纯数字模式下显示选择顺序时的数字阴影高,不需要阴影设置为0*/
    var shadowH:CGFloat = 1.0{
        didSet{
            shadowH = shadowH>4 ? 4 :(shadowH<0 ? 0 :shadowH)
            cacheNumberImage()
        }
    }
    
    /** 选择框类型（样式） 8种 */
    var checkboxType: TGCheckboxType = .diagonalBelt{
        didSet{
            switch checkboxType {
            case .diagonalBelt,.triangle:
                selectShape[7] = 4
            default:
                selectShape[7] = 3
            }
            
            cacheNumberImage()
        }
    }
    
    /** 显示在工具栏上的选择框的大小*/
    var checkboxBarWH: CGFloat = 30{
        didSet{
            checkboxBarWH = checkboxBarWH > (toolBarH - 10) ? (toolBarH - 10) :(checkboxBarWH<(toolBarH - 20) ? (toolBarH - 20) :checkboxBarWH)
        }
    }
    
    /** 显示在照片Cell上的选择框的大小*/
    var checkboxCellWH: CGFloat = 20{
        didSet{
            checkboxCellWH = checkboxCellWH>25 ? 25 :(checkboxCellWH<20 ? 20 :checkboxCellWH)
            cacheNumberImage()
        }
    }
    
    /** 选择框起始透明度*/
    var checkboxBeginngAlpha: CGFloat = 1{
        didSet{
            checkboxBeginngAlpha = checkboxBeginngAlpha>1 ? 1 :(checkboxBeginngAlpha<0.2 ? 0.2 :checkboxBeginngAlpha)
        }
    }
    
    /** 选择框的结束透明度, 两者用于选择框渐变效果*/
    var checkboxEndingAlpha: CGFloat = 1{
        didSet{
            checkboxEndingAlpha = checkboxEndingAlpha>1 ? 1 :(checkboxEndingAlpha<0.2 ? 0.2 :checkboxEndingAlpha)
        }
    }
    
    /** 选择框的画线宽度, 工具栏上返回、删除按钮的画线宽度*/
    var checkboxLineW: CGFloat = 1.5{
        didSet{
            checkboxLineW = checkboxLineW>2 ? 2 : (checkboxLineW<1 ? 1 : checkboxLineW)
            cacheNumberImage()
        }
    }
    
    /** 选择框的Padding*/
    var checkboxPadding: CGFloat = 1{
        didSet{
            checkboxPadding = checkboxPadding>6 ? 6 : (checkboxPadding<0 ? 0 : checkboxPadding)
            cacheNumberImage()
        }
    }
    
    /** 选择时是否动画效果*/
    var checkboxAnimate: Bool = true
    
    /** 选择时或选择到最大照片数量时，当前或其他Cell的遮罩的透明度*/
    var maskAlpha: CGFloat = 0.6{
        didSet{
            maskAlpha = maskAlpha>0.8 ? 0.8 : (maskAlpha<0.3 ? 0.3 :maskAlpha)
        }
    }
    
    /** 使用选择遮罩: false,当选择照片数量达到最大值时,其余照片显示遮罩; true,其余照片不显示遮罩,而是已经选择的照片显示遮罩 */
    var useSelectMask: Bool = false
    
    /** 工具条的高度*/
    var toolBarH: CGFloat = 44.0{
        didSet{
            toolBarH = toolBarH < 40 ? 40 : (toolBarH > 114 ? 114 : toolBarH)
        }
    }
    
    /** 相册类型列表Cell的高度*/
    var albumCellH: CGFloat = 60.0{
        didSet{
            albumCellH = albumCellH < 50 ? 50 : (albumCellH > 90 ? 90 : albumCellH)
        }
    }
    
    /** 照片Cell的高宽,即选择时的呈现的宽高*/
    var selectWH: CGFloat = 80{
        didSet{
            let maxCellW = (TGPhotoPickerConfig.ScreenW - (colCount+1) * padding)/colCount
            selectWH = selectWH>maxCellW ? maxCellW :(selectWH<60 ? 60 :selectWH)
        }
    }
    
    /** 控件本身的Cell的宽高,即选择后的呈现的宽高*/
    var mainCellWH: CGFloat = 80{
        didSet{
            let maxCellW = (TGPhotoPickerConfig.ScreenW - (colCount+1) * padding)/colCount
            mainCellWH = mainCellWH>maxCellW ? maxCellW :(mainCellWH<60 ? 60 :mainCellWH)
        }
    }
    
    /** 自动宽高,用于控件本身Cell的宽高自动计算*/
    var autoSelectWH: Bool = false
    
    /** true,在选择照片界面,点击照片（非checkbox区域）时,不跳转到大图预览界面,而是直接选择或取消选择当前照片; false, 点击照片checkbox区域选择或取消选择当前照片,点击非checkbox区域跳转到大图预览界面*/
    var immediateTapSelect: Bool = false
    
    /** 控件或Cell之间布局时的padding*/
    var padding: CGFloat = 1{
        didSet{
            padding = padding>10 ? 10 :(padding<1 ? 1 :padding)
        }
    }
    
    /** 左右没有空白,即选择时呈现的UICollectionView没有contentInset中的左右Inset*/
    var leftAndRigthNoPadding: Bool = true
    
    /** 选择时呈现的UICollectionView的每行列数*/
    var colCount: CGFloat = 4{
        didSet{
            colCount = colCount < 3 ? 3 : (colCount > 4 ? 4 : colCount)
        }
    }
    
    /** 选择后控件本身呈现的UICollectionView的每行列数*/
    var mainColCount: CGFloat = 4{
        didSet{
            mainColCount = mainColCount > 5 ? 5 : (mainColCount < 2 ? 2 : mainColCount)
        }
    }
    
    /** 完成按钮标题*/
    var doneTitle = "完成"
    
    /** 完成按钮的宽*/
    var doneButtonW: CGFloat = 70
    
    /** 完成按钮的高*/
    var doneButtonH: CGFloat = 30.8
    
    /** 导航工具栏返回按钮图标显示圆边 及 星（star）样式显示圆边*/
    var isShowBorder: Bool = false
    
    /** 分多次选择照片时,剩余照片达到上限时的提示文字*/
    var leftTitle = "剩余"
    
    /** 相册类型界面的标题*/
    var albumTitle = "照片"
    
    /** 确定按钮的标题*/
    var confirmTitle  = "确定"
    
    /** 选择数量达到上限时的提示文字, #为占位符*/
    var errorImageMaxSelect = "图片选择最多不能超过#张"
    
    /** 拍摄标题*/
    var cameraTitle = "拍摄"
    
    /** 选择标题*/
    var selectTitle = "从手机相册选择"
    
    /** 取消标题*/
    var cancelTitle = "取消"
    
    /** 选择时显示的数字的字体大小等*/
    var fontSize: CGFloat = 15.0
    
    /** 预览照片的最大宽度*/
    var previewImageFetchMaxW:CGFloat = 600
    
    /** 工具栏的背景色,有透明部分则全屏穿透效果*/
    var barBGColor = UIColor(red: 40/255, green: 40/255, blue: 40/255, alpha: 0.9)
    
    /** 选择框 、按钮的颜色*/
    var tinColor = UIColor(red: 7/255, green: 179/255, blue: 20/255, alpha: 1){
        didSet{
            cacheNumberImage()
        }
    }
    
    /** 删除按钮的颜色*/
    var removeHighlightedColor: UIColor = .red
    
    /** 删除按钮是否隐藏*/
    var isRemoveButtonHidden: Bool = false
    
    /** 按钮无效时的文字颜色*/
    var disabledColor: UIColor = .gray
    
    /** 最大照片选择数量上限*/
    var maxImageCount: Int = 9{
        didSet {
            maxImageCount = maxImageCount < 1 ? 1 : (maxImageCount > 99 ? 99 : maxImageCount)
            cacheNumberImage()
        }
    }
    
    /** 压缩比,0(most)..1(least) 越小图片就越小*/
    var compressionQuality: CGFloat = 0.5{
        didSet {
            compressionQuality = compressionQuality < 0.1 ? 0.1 : compressionQuality
        }
    }
    
    /** 从云端获取照片的缩放比*/
    var cloudImageScale: CGFloat = 0.5{
        didSet {
            cloudImageScale = cloudImageScale < 0.1 ? 0.1 : cloudImageScale
        }
    }
    
    /** 缓存的选择顺序图像,自动生成*/
    var cacheNumerImageArr = [UIImage]()
    
    /** 以下为照相配置 8个 */
    /** 按钮分布时边界*/
    var buttonEdge: UIEdgeInsets = UIEdgeInsets(top: 40, left: 20, bottom: 60, right: 50)
    
    /** 拍摄按钮的大小*/
    var takeWH: CGFloat = 60{
        didSet{
            takeWH = takeWH < 50 ? 50 : (takeWH > 80 ? 80 : takeWH)
        }
    }
    
    /** 拍摄预览时的背景色*/
    var previewBGColor: UIColor = UIColor(white: 1, alpha: 0.7)
    
    /** 前置后置摄像头切换时的动画类型,可以设置下面值
     kCATransitionFade
     kCATransitionMoveIn
     kCATransitionPush
     kCATransitionReveal
     "pageCurl"
     "pageUnCurl"
     "rippleEffect"
     "suckEffect"
     "cube"
     "oglFlip"
     */
    var transitionType: String = "oglFlip"
    
    /** 图像质量 */
    var sessionPreset: String = AVCaptureSessionPreset1280x720
    
    /** 拍摄视图的伸缩模式*/
    var videoGravity: String = AVLayerVideoGravityResizeAspectFill
    
    /** 广角*/
    var captureDeviceType: AVCaptureDeviceType = .builtInWideAngleCamera
    
    /** 预览Padding*/
    var previewPadding: CGFloat = 15
    
    /** 选择和移除路径 */
    private var selectShape: Array<CGFloat> = [3,5,4,6,4,6,6,3]
    private var removeShape: Array<CGFloat> = [3.5,3.5,5.5,5.5,5.5,3.5,3.5,5.5]
    
    /** 下面为链式配置 */
    @discardableResult
    public func tg_autoSelectWH(_ auto: Bool) -> TGPhotoPickerConfig {
        self.autoSelectWH = auto
        return self
    }
    
    @discardableResult
    public func tg_cameraTitle(_ str: String) -> TGPhotoPickerConfig {
        self.cameraTitle = str
        return self
    }
    
    @discardableResult
    public func tg_selectWH(_ selectWH: CGFloat) -> TGPhotoPickerConfig {
        self.selectWH = selectWH
        return self
    }
    
    @discardableResult
    public func tg_tinColor(_ color: UIColor) -> TGPhotoPickerConfig {
        self.tinColor = color
        return self
    }
    
    @discardableResult
    public func tg_customSmartCollections(_ custom: [PHAssetCollectionSubtype]) -> TGPhotoPickerConfig {
        self.customSmartCollections = custom
        return self
    }
    
    @discardableResult
    public func tg_useCustomSmartCollectionsMask(_ use: Bool) -> TGPhotoPickerConfig {
        self.useCustomSmartCollectionsMask = use
        return self
    }
    
    @discardableResult
    public func tg_useChineseAlbumName(_ use: Bool) -> TGPhotoPickerConfig {
        self.useChineseAlbumName = use
        return self
    }
    
    @discardableResult
    public func tg_isShowEmptyAlbum(_ show: Bool) -> TGPhotoPickerConfig {
        self.isShowEmptyAlbum = show
        return self
    }
    
    @discardableResult
    public func tg_ascending(_ ascending: Bool) -> TGPhotoPickerConfig {
        self.ascending = ascending
        return self
    }
    
    @discardableResult
    public func tg_type(_ type: TGPhotoPickerType) -> TGPhotoPickerConfig {
        self.type = type
        return self
    }
    
    @discardableResult
    public func tg_checkboxCorner(_ corner: CGFloat) -> TGPhotoPickerConfig {
        self.checkboxCorner = corner
        return self
    }
    
    @discardableResult
    public func tg_checkboxPosition(_ position: TGCheckboxPosition) -> TGPhotoPickerConfig {
        self.checkboxPosition = position
        return self
    }
    
    @discardableResult
    public func tg_removePosition(_ position: TGCheckboxPosition) -> TGPhotoPickerConfig {
        self.removePosition = position
        return self
    }
    
    @discardableResult
    public func tg_removeType(_ type: TGCheckboxType) -> TGPhotoPickerConfig {
        self.removeType = type
        return self
    }
    
    @discardableResult
    public func tg_isShowNumber(_ show: Bool) -> TGPhotoPickerConfig {
        self.isShowNumber = show
        return self
    }
    
    @discardableResult
    public func tg_checkboxType(_ type: TGCheckboxType)-> TGPhotoPickerConfig {
        self.checkboxType = type
        return self
    }
    
    @discardableResult
    public func tg_checkboxBarWH(_ wh: CGFloat) -> TGPhotoPickerConfig {
        self.checkboxBarWH = wh
        return self
    }
    
    @discardableResult
    public func tg_checkboxCellWH(_ wh: CGFloat) -> TGPhotoPickerConfig {
        self.checkboxCellWH = wh
        return self
    }
    
    @discardableResult
    public func tg_checkboxBeginngAlpha(_ alpha: CGFloat) -> TGPhotoPickerConfig {
        self.checkboxBeginngAlpha = alpha
        return self
    }
    
    @discardableResult
    public func tg_checkboxEndingAlpha(_ alpha: CGFloat) -> TGPhotoPickerConfig {
        self.checkboxEndingAlpha = alpha
        return self
    }
    
    @discardableResult
    public func tg_checkboxLineW(_ w: CGFloat) -> TGPhotoPickerConfig {
        self.checkboxLineW = w
        return self
    }
    
    @discardableResult
    public func tg_checkboxPadding(_ padding: CGFloat) -> TGPhotoPickerConfig {
        self.checkboxPadding = padding
        return self
    }
    
    @discardableResult
    public func tg_checkboxAnimate(_ animate: Bool) -> TGPhotoPickerConfig {
        self.checkboxAnimate = animate
        return self
    }
    
    @discardableResult
    public func tg_maskAlpha(_ alpha: CGFloat) -> TGPhotoPickerConfig {
        self.maskAlpha = alpha
        return self
    }
    
    @discardableResult
    public func tg_useSelectMask(_ mask: Bool) -> TGPhotoPickerConfig {
        self.useSelectMask = mask
        return self
    }
    
    @discardableResult
    public func tg_toolBarH(_ h: CGFloat) -> TGPhotoPickerConfig {
        self.toolBarH = h
        return self
    }
    
    @discardableResult
    public func tg_albumCellH(_ h: CGFloat) -> TGPhotoPickerConfig {
        self.albumCellH = h
        return self
    }
    
    @discardableResult
    public func tg_mainCellWH(_ wh: CGFloat) -> TGPhotoPickerConfig {
        self.mainCellWH = wh
        return self
    }
    
    @discardableResult
    public func tg_immediateTapSelect(_ immediate: Bool) -> TGPhotoPickerConfig {
        self.immediateTapSelect = immediate
        return self
    }
    
    @discardableResult
    public func tg_padding(_ padding: CGFloat) -> TGPhotoPickerConfig {
        self.padding = padding
        return self
    }
    
    @discardableResult
    public func tg_leftAndRigthNoPadding(_ noPadding: Bool) -> TGPhotoPickerConfig {
        self.leftAndRigthNoPadding = noPadding
        return self
    }
    
    @discardableResult
    public func tg_colCount(_ count: CGFloat) -> TGPhotoPickerConfig {
        self.colCount = count
        return self
    }
    
    @discardableResult
    public func tg_mainColCount(_ count: CGFloat) -> TGPhotoPickerConfig {
        self.mainColCount = count
        return self
    }
    @discardableResult
    public func tg_doneTitle(_ str: String) -> TGPhotoPickerConfig {
        self.doneTitle = str
        return self
    }
    
    @discardableResult
    public func tg_doneButtonW(_ w: CGFloat) -> TGPhotoPickerConfig {
        self.doneButtonW = w
        return self
    }
    
    @discardableResult
    public func tg_doneButtonH(_ h: CGFloat) -> TGPhotoPickerConfig {
        self.doneButtonH = h
        return self
    }
    
    @discardableResult
    public func tg_isShowBorder(_ show: Bool) -> TGPhotoPickerConfig {
        self.isShowBorder = show
        return self
    }
    
    @discardableResult
    public func tg_leftTitle(_ str: String) -> TGPhotoPickerConfig {
        self.leftTitle = str
        return self
    }
    
    @discardableResult
    public func tg_albumTitle(_ str: String) -> TGPhotoPickerConfig {
        self.albumTitle = str
        return self
    }
    
    @discardableResult
    public func tg_confirmTitle(_ str: String) -> TGPhotoPickerConfig {
        self.confirmTitle = str
        return self
    }
    
    @discardableResult
    public func tg_errorImageMaxSelect(_ str: String) -> TGPhotoPickerConfig {
        self.errorImageMaxSelect = str
        return self
    }
    
    @discardableResult
    public func tg_selectTitle(_ str: String) -> TGPhotoPickerConfig {
        self.selectTitle = str
        return self
    }
    
    @discardableResult
    public func tg_cancelTitle(_ str: String) -> TGPhotoPickerConfig {
        self.cancelTitle = str
        return self
    }
    
    @discardableResult
    public func tg_fontSize(_ size: CGFloat) -> TGPhotoPickerConfig {
        self.fontSize = size
        return self
    }
    
    @discardableResult
    public func tg_previewImageFetchMaxW(_ w: CGFloat) -> TGPhotoPickerConfig {
        self.previewImageFetchMaxW = w
        return self
    }
    
    @discardableResult
    public func tg_barBGColor(_ color: UIColor) -> TGPhotoPickerConfig {
        self.barBGColor = color
        return self
    }
    
    @discardableResult
    public func tg_removeHighlightedColor(_ color: UIColor) -> TGPhotoPickerConfig {
        self.removeHighlightedColor = color
        return self
    }
    
    @discardableResult
    public func tg_isRemoveButtonHidden(_ hidden: Bool) -> TGPhotoPickerConfig {
        self.isRemoveButtonHidden = hidden
        return self
    }
    
    @discardableResult
    public func tg_disabledColor(_ color: UIColor) -> TGPhotoPickerConfig {
        self.disabledColor = color
        return self
    }
    
    @discardableResult
    public func tg_maxImageCount(_ max: Int) -> TGPhotoPickerConfig {
        self.maxImageCount = max
        return self
    }
    
    @discardableResult
    public func tg_compressionQuality(_ quality: CGFloat) -> TGPhotoPickerConfig {
        self.compressionQuality = quality
        return self
    }
    
    @discardableResult
    public func tg_cloudImageScale(_ scale: CGFloat) -> TGPhotoPickerConfig {
        self.cloudImageScale = scale
        return self
    }
    
    @discardableResult
    public func tg_shadowW(_ w: CGFloat) -> TGPhotoPickerConfig {
        self.shadowW = w
        return self
    }
    
    @discardableResult
    public func tg_shadowH(_ h: CGFloat) -> TGPhotoPickerConfig {
        self.shadowH = h
        return self
    }
    
    @discardableResult
    public func tg_buttonEdge(_ edge: UIEdgeInsets) -> TGPhotoPickerConfig {
        self.buttonEdge = edge
        return self
    }
    
    @discardableResult
    public func tg_takeWH(_ wh: CGFloat) -> TGPhotoPickerConfig {
        self.takeWH = wh
        return self
    }
    
    @discardableResult
    public func tg_previewBGColor(_ color: UIColor) -> TGPhotoPickerConfig {
        self.previewBGColor = color
        return self
    }
    
    @discardableResult
    public func tg_transitionType(_ str: String) -> TGPhotoPickerConfig {
        self.transitionType = str
        return self
    }
    
    @discardableResult
    public func tg_sessionPreset(_ str: String) -> TGPhotoPickerConfig {
        self.sessionPreset = str
        return self
    }
    
    @discardableResult
    public func tg_videoGravity(_ str: String) -> TGPhotoPickerConfig {
        self.videoGravity = str
        return self
    }
    
    @discardableResult
    public func tg_captureDeviceType(_ type: AVCaptureDeviceType) -> TGPhotoPickerConfig {
        self.captureDeviceType = type
        return self
    }
    
    @discardableResult
    public func tg_previewPadding(_ padding: CGFloat) -> TGPhotoPickerConfig {
        self.previewPadding = padding
        return self
    }

    class func getImage(_ name:String) -> UIImage{
        let currentBundle = Bundle(path: Bundle(for: TGPhotoPicker.self).path(forResource: "TGPhotoPicker", ofType: "bundle")!)
        return UIImage(contentsOfFile: (currentBundle?.path(forResource: name, ofType: "png"))!)!
    }

    class func getImageNo2x3xSuffix(_ name:String) -> UIImage{
        let currentBundle = Bundle(path: Bundle(for: TGPhotoPicker.self).path(forResource: "TGPhotoPicker", ofType: "bundle")!)
        return UIImage(contentsOfFile: (((currentBundle?.resourcePath)! as NSString).appendingPathComponent(name+".png") ))!
    }

    public func getDigitImage(_ num: UInt,_ type: TGCheckboxType = TGPhotoPickerConfig.shared.checkboxType, _ isCellSize: Bool = true,_ fontSize:CGFloat = TGPhotoPickerConfig.shared.fontSize - 1) -> UIImage?{
        var W = isCellSize ? self.checkboxCellWH : self.checkboxBarWH
        var H = isCellSize ? self.checkboxCellWH : self.checkboxBarWH
        let L = self.checkboxLineW
        let B = self.checkboxPadding
        let P = self.checkboxPosition
        
        let str: NSString = String(num) as NSString
        
        var reduceFontSize = fontSize - 3 * B / 10
        reduceFontSize -= num > 9 ? 1.5 : 0
        reduceFontSize -= num > 19 ? 1.5 : 0
        reduceFontSize -= type == .triangle ? 2 : 0
        reduceFontSize -= type == .diagonalBelt ? 2 : 0
        let font: UIFont = L >= 2 ? UIFont.boldSystemFont(ofSize: reduceFontSize) : UIFont.systemFont(ofSize: reduceFontSize)
        
        var attrs = [NSFontAttributeName:font,NSForegroundColorAttributeName: UIColor.white]
        //NSShadowAttributeName NSVerticalGlyphFormAttributeName，NSObliquenessAttributeName，NSExpansionAttributeName
        if type == .onlyCheckbox {
            let shadow = NSShadow()
            shadow.shadowBlurRadius = 4
            shadow.shadowColor = UIColor.gray
            shadow.shadowOffset = CGSize(width: shadowW, height: shadowH)
            if shadowW>0 || shadowH>0{
                attrs = [NSFontAttributeName:UIFont.boldSystemFont(ofSize: fontSize),NSForegroundColorAttributeName: tinColor,NSShadowAttributeName:shadow,NSVerticalGlyphFormAttributeName:0 as NSNumber]
            }else{
                attrs = [NSFontAttributeName:UIFont.boldSystemFont(ofSize: fontSize),NSForegroundColorAttributeName: tinColor]
            }
        }
        
        let viewSize = CGSize(width: TGPhotoPickerConfig.ScreenW, height: CGFloat(MAXFLOAT))
        let size = str.boundingRect(with: viewSize, options: [.usesLineFragmentOrigin], attributes:attrs,context: nil)
        
        let X = B/2 + (W - B - size.width)/2
        let Y = B/2 + (H - B - size.height)/2
        
        var addX: CGFloat = 0
        var addY: CGFloat = 0
        
        switch type {
        case .onlyCheckbox:
            return UIImage.size(width: W, height: H)
                .color(.clear)
                .image
                .with({ context in
                    str.draw(in: CGRect(x: X, y: Y , width: W, height: H), withAttributes:attrs)
                })
        case .circle,.star,.heart:
            return UIImage.size(width: W, height: H)
                .corner(radius: W * 0.5)
                .color(self.tinColor)
                .border(color: .clear)
                .border(width: B)
                .image
                .with({ context in
                    str.draw(in: CGRect(x: X, y: Y, width: W, height: H), withAttributes:attrs)
                })
        case .square:
            switch P {
            case .topLeft:
                addX = -self.checkboxCorner * TGPhotoPickerConfig.factor
                addY = -self.checkboxCorner * TGPhotoPickerConfig.factor
            case .topRight:
                addX = self.checkboxCorner * TGPhotoPickerConfig.factor
                addY = -self.checkboxCorner * TGPhotoPickerConfig.factor
            case .bottomLeft:
                addX = -self.checkboxCorner * TGPhotoPickerConfig.factor
                addY = self.checkboxCorner * TGPhotoPickerConfig.factor
            case .bottomRight:
                addX = self.checkboxCorner * TGPhotoPickerConfig.factor
                addY = self.checkboxCorner * TGPhotoPickerConfig.factor
            }
            return UIImage.size(width: W, height: H)
                .corner(topLeft: P == .bottomRight ? self.checkboxCorner : 0,
                        topRight: P == .bottomLeft ? self.checkboxCorner : 0,
                        bottomLeft: P == .topRight ? self.checkboxCorner : 0,
                        bottomRight: P == .topLeft ? self.checkboxCorner : 0)
                .color(self.tinColor)
                .image
                .with({ context in
                    str.draw(in: CGRect(x: X + addX, y: Y + addY, width: W, height: H), withAttributes:attrs)
                })
        case .belt:
            addX = (self.checkboxPosition == .topRight || self.checkboxPosition == .bottomRight) ? (W * 2 + B * 0.5) : (-B * 0.5)
            addY = -B * 0.5
            W = W * 3
            H = H - B
            var fromPoint: CGPoint?
            var toPoint:CGPoint?
            switch self.checkboxPosition{
            case .topLeft:
                fromPoint = CGPoint(x: 0, y: 0)
                toPoint = CGPoint(x: 1, y: 1)
            case .topRight:
                fromPoint = CGPoint(x: 1, y: 0)
                toPoint = CGPoint(x: 0, y: 1)
            case .bottomLeft:
                fromPoint = CGPoint(x: 0, y: 1)
                toPoint = CGPoint(x: 1, y: 0)
            case .bottomRight:
                fromPoint = CGPoint(x: 1, y: 1)
                toPoint = CGPoint(x: 0, y: 0)
            }
            return UIImage.size(width: W, height: H)
                .corner(topLeft: P == .bottomRight ? self.checkboxCorner : 0,
                        topRight: P == .bottomLeft ? self.checkboxCorner : 0,
                        bottomLeft: P == .topRight ? self.checkboxCorner : 0,
                        bottomRight: P == .topLeft ? self.checkboxCorner : 0)
                .color(gradient: [self.tinColor.withAlphaComponent(self.checkboxBeginngAlpha), UIColor.white.withAlphaComponent(0.01)], locations: [0, 1], from: fromPoint!, to: toPoint!)
                .image
                .with({ context in
                    str.draw(in: CGRect(x: X + addX, y: Y + addY, width: W, height: H), withAttributes:attrs)
                })
        case .triangle,.diagonalBelt:
            let beltLineW = W * 0.75
            let smallToBigSecondAddY: CGFloat = num > 19 ? 1 : (num > 9 ? 0.75 : 0.25)
            var beltMoveTo: CGPoint?
            var beltLineTo: CGPoint?
            var positionX: CGFloat = 0
            var positionY: CGFloat = 0
            switch self.checkboxPosition {
            case .topLeft:
                addX = -W / 5
                addY = -(W / 5 + smallToBigSecondAddY)
                positionX = -0.000001
                positionY = 0
                beltMoveTo = CGPoint(x: W * 0.5, y: 0)
                beltLineTo = CGPoint(x: 0, y: H * 0.5)
            case .topRight:
                addX = W / 5
                addY = -(W / 5 + smallToBigSecondAddY)
                positionX = W * 0.5
                positionY = 0
                beltMoveTo = CGPoint(x: W * 0.5, y: 0)
                beltLineTo = CGPoint(x: W, y: H * 0.5)
            case .bottomLeft:
                addX = -W / 5
                addY = W / 5  + smallToBigSecondAddY
                positionX = 0
                positionY = W * 0.5
                beltMoveTo = CGPoint(x: -W * 0.25, y: H * 0.25)
                beltLineTo = CGPoint(x: W * 0.5, y: H)
            case .bottomRight:
                addX = W / 5
                addY = W / 5 + smallToBigSecondAddY
                positionX = W * 0.5
                positionY = W * 0.5
                beltMoveTo = CGPoint(x: W, y: H * 0.5)
                beltLineTo = CGPoint(x: W * 0.5, y: H)
            }

            let image = UIImage.size(width: W, height: H)
                .color(.clear)
                .image
                .with({ context in
                    context.setLineCap(.square)
                    self.tinColor.setStroke()
                    context.setLineWidth(beltLineW)
                    context.move(to: beltMoveTo!)
                    context.addLine(to: beltLineTo!)
                    context.strokePath()
                    
                    str.draw(in: CGRect(x: X + addX, y: Y + addY, width: W, height: H), withAttributes:attrs)
                })
            return type == .triangle ? image : UIImage.size(width: W * 1.5, height: H * 1.5).color(.clear).image + image.position(CGPoint(x: positionX, y: positionY))
//        default:
//            return nil
        }
    }
    
    public func getCheckboxImage(_ isCellSize: Bool = true,
                                 _ isRemove: Bool = false,
                                 _ checkboxType:TGCheckboxType = TGPhotoPickerConfig.shared.checkboxType,
                                 _ useUserSize: CGFloat = 0
                                 ) -> (select:UIImage,unselect:UIImage,size:CGSize){
        var W = (useUserSize > 0) ? useUserSize : (isCellSize ? self.checkboxCellWH : self.checkboxBarWH)
        var H = (useUserSize > 0) ? useUserSize : (isCellSize ? self.checkboxCellWH : self.checkboxBarWH)
        let M = W * TGPhotoPickerConfig.factor
        let L = self.checkboxLineW
        let B = self.checkboxPadding
        let P = self.checkboxPosition
        
        var shape = isRemove ? removeShape : selectShape
        shape[7] = isRemove ? shape[7] : (isCellSize ? shape[7] : 3)
        
        let tin = isRemove ? self.removeHighlightedColor : self.tinColor
        
        let type = (useUserSize > 0) ? checkboxType : (isRemove ? self.removeType : checkboxType)
        
        var imageSelect:UIImage?
        var imageUnselect:UIImage?
        
        var fromPoint: CGPoint?
        var toPoint:CGPoint?
        switch self.checkboxPosition{
        case .topLeft:
            fromPoint = CGPoint(x: 0, y: 0)
            toPoint = CGPoint(x: 1, y: 1)
        case .topRight:
            fromPoint = CGPoint(x: 1, y: 0)
            toPoint = CGPoint(x: 0, y: 1)
        case .bottomLeft:
            fromPoint = CGPoint(x: 0, y: 1)
            toPoint = CGPoint(x: 1, y: 0)
        case .bottomRight:
            fromPoint = CGPoint(x: 1, y: 1)
            toPoint = CGPoint(x: 0, y: 0)
        }
        
        var addX: CGFloat = 0
        var addY: CGFloat = 0
        
        switch  type{
        case .onlyCheckbox:
            imageUnselect = UIImage.size(width: W, height: H)
                .color(.clear)
                .image
                .with({ context in
                    context.setLineCap(.round)
                    UIColor.white.withAlphaComponent(0.7).setStroke()
                    context.setLineWidth(L)
                    context.move(to: CGPoint(x: M * shape[0], y: M * shape[1]))
                    context.addLine(to: CGPoint(x: M * shape[2], y: M * shape[3]))
                    context.move(to: CGPoint(x: M * shape[4], y: M * shape[5]))
                    context.addLine(to: CGPoint(x: M * shape[6], y: M * shape[7]))
                    context.strokePath()
                })
            
            imageSelect = UIImage.size(width: W, height: H)
                .color(.clear)
                .image
                .with({ context in
                    context.setLineCap(.round)
                    tin.setStroke()
                    context.setLineWidth(L)
                    context.move(to: CGPoint(x: M * shape[0], y: M * shape[1]))
                    context.addLine(to: CGPoint(x: M * shape[2], y: M * shape[3]))
                    context.move(to: CGPoint(x: M * shape[4], y: M * shape[5]))
                    context.addLine(to: CGPoint(x: M * shape[6], y: M * shape[7]))
                    context.strokePath()
                })
        case .circle:
            let spaceW = min(W/10,L*2)
            imageUnselect = (UIImage.size(width: W, height: H)
                .corner(radius: W * 0.5)
                .border(color: .clear)
                .border(width: B)
                .color(UIColor.white.withAlphaComponent(0.3))
                .image
                +
                UIImage.size(width: W - B, height: H - B)
                    .corner(radius: (W - B) * 0.5)
                    .border(color: UIColor.white.withAlphaComponent(0.7))
                    .border(width: spaceW * 0.5)
                    .color(.clear)
                    .image)
                .with({ context in
                    context.setLineCap(.round)
                    
                    switch self.type{
                    case .weibo:
                        isRemove ? UIColor.white.setStroke() : UIColor.clear.setStroke()
                    default :
                        UIColor.white.setStroke()
                    }
                    
                    context.setLineWidth(L)
                    context.move(to: CGPoint(x: M * shape[0], y: M * shape[1]))
                    context.addLine(to: CGPoint(x: M * shape[2], y: M * shape[3]))
                    context.move(to: CGPoint(x: M * shape[4], y: M * shape[5]))
                    context.addLine(to: CGPoint(x: M * shape[6], y: M * shape[7]))
                    context.strokePath()
                })
            
            imageSelect = UIImage.size(width: W, height: H)
                .corner(radius: W * 0.5)
                .border(color: .clear)
                .border(width: B)
                .color(gradient: [tin.withAlphaComponent(isCellSize ? self.checkboxBeginngAlpha : 1), tin.withAlphaComponent(isCellSize ? self.checkboxEndingAlpha : 1)], locations: [0, 1], from: fromPoint!, to: toPoint!)
                .image
                .with({ context in
                    context.setLineCap(.round)
                    UIColor.white.setStroke()
                    context.setLineWidth(L)
                    context.move(to: CGPoint(x: M * shape[0], y: M * shape[1]))
                    context.addLine(to: CGPoint(x: M * shape[2], y: M * shape[3]))
                    context.move(to: CGPoint(x: M * shape[4], y: M * shape[5]))
                    context.addLine(to: CGPoint(x: M * shape[6], y: M * shape[7]))
                    context.strokePath()
                })
        case .square:
            switch self.checkboxPosition {
            case .topLeft:
                addX = -self.checkboxCorner * TGPhotoPickerConfig.factor
                addY = -self.checkboxCorner * TGPhotoPickerConfig.factor
            case .topRight:
                addX = self.checkboxCorner * TGPhotoPickerConfig.factor
                addY = -self.checkboxCorner * TGPhotoPickerConfig.factor
            case .bottomLeft:
                addX = -self.checkboxCorner * TGPhotoPickerConfig.factor
                addY = self.checkboxCorner * TGPhotoPickerConfig.factor
            case .bottomRight:
                addX = self.checkboxCorner * TGPhotoPickerConfig.factor
                addY = self.checkboxCorner * TGPhotoPickerConfig.factor
            }
            imageUnselect = UIImage.size(width: W, height: H)
                .corner(topLeft: P == .bottomRight ? self.checkboxCorner : 0,
                        topRight: P == .bottomLeft ? self.checkboxCorner : 0,
                        bottomLeft: P == .topRight ? self.checkboxCorner : 0,
                        bottomRight: P == .topLeft ? self.checkboxCorner : 0)
                .color(UIColor.white.withAlphaComponent(0.3))
                .image
                .with({ context in
                    context.setLineCap(.round)
                    UIColor.white.setStroke()
                    context.setLineWidth(L)
                    context.move(to: CGPoint(x: M * shape[0] + addX, y: M * shape[1] + addY))
                    context.addLine(to: CGPoint(x: M * shape[2] + addX, y: M * shape[3] + addY))
                    context.move(to: CGPoint(x: M * shape[4] + addX, y: M * shape[5] + addY))
                    context.addLine(to: CGPoint(x: M * shape[6] + addX, y: M * shape[7] + addY))
                    context.strokePath()
                })
            
            imageSelect = UIImage.size(width: W, height: H)
                .corner(topLeft: P == .bottomRight ? self.checkboxCorner : 0,
                        topRight: P == .bottomLeft ? self.checkboxCorner : 0,
                        bottomLeft: P == .topRight ? self.checkboxCorner : 0,
                        bottomRight: P == .topLeft ? self.checkboxCorner : 0)
                .color(gradient: [tin.withAlphaComponent(self.checkboxBeginngAlpha), tin.withAlphaComponent(self.checkboxEndingAlpha)], locations: [0, 1], from: fromPoint!, to: toPoint!)
                .image
                .with({ context in
                    context.setLineCap(.round)
                    UIColor.white.setStroke()
                    context.setLineWidth(L)
                    context.move(to: CGPoint(x: M * shape[0] + addX, y: M * shape[1] + addY))
                    context.addLine(to: CGPoint(x: M * shape[2] + addX, y: M * shape[3] + addY))
                    context.move(to: CGPoint(x: M * shape[4] + addX, y: M * shape[5] + addY))
                    context.addLine(to: CGPoint(x: M * shape[6] + addX, y: M * shape[7] + addY))
                    context.strokePath()
                })
        case .belt:
            addX = (self.checkboxPosition == .topRight || self.checkboxPosition == .bottomRight) ? (W * 2 + B * 0.5) : (-B * 0.5)
            addY = -B * 0.5
            W = W * 3
            H = H - B
            imageUnselect = UIImage.size(width: W, height: H)
                .corner(topLeft: P == .bottomRight ? self.checkboxCorner : 0,
                        topRight: P == .bottomLeft ? self.checkboxCorner : 0,
                        bottomLeft: P == .topRight ? self.checkboxCorner : 0,
                        bottomRight: P == .topLeft ? self.checkboxCorner : 0)
                .color(gradient: [UIColor.white.withAlphaComponent(0.3), UIColor.white.withAlphaComponent(0.01)], locations: [0, 1], from: fromPoint!, to: toPoint!)
                .image
                .with({ context in
                    context.setLineCap(.round)
                    UIColor.white.setStroke()
                    context.setLineWidth(L)
                    context.move(to: CGPoint(x: M * shape[0] + addX, y: M * shape[1] + addY))
                    context.addLine(to: CGPoint(x: M * shape[2] + addX, y: M * shape[3] + addY))
                    context.move(to: CGPoint(x: M * shape[4] + addX, y: M * shape[5] + addY))
                    context.addLine(to: CGPoint(x: M * shape[6] + addX, y: M * shape[7] + addY))
                    context.strokePath()
                })
            
            imageSelect = UIImage.size(width: W, height: H)
                .corner(topLeft: P == .bottomRight ? self.checkboxCorner : 0,
                        topRight: P == .bottomLeft ? self.checkboxCorner : 0,
                        bottomLeft: P == .topRight ? self.checkboxCorner : 0,
                        bottomRight: P == .topLeft ? self.checkboxCorner : 0)
                .color(gradient: [tin.withAlphaComponent(self.checkboxBeginngAlpha), UIColor.white.withAlphaComponent(0.01)], locations: [0, 1], from: fromPoint!, to: toPoint!)
                .image
                .with({ context in
                    context.setLineCap(.round)
                    UIColor.white.setStroke()
                    context.setLineWidth(L)
                    context.move(to: CGPoint(x: M * shape[0] + addX, y: M * shape[1] + addY))
                    context.addLine(to: CGPoint(x: M * shape[2] + addX, y: M * shape[3] + addY))
                    context.move(to: CGPoint(x: M * shape[4] + addX, y: M * shape[5] + addY))
                    context.addLine(to: CGPoint(x: M * shape[6] + addX, y: M * shape[7] + addY))
                    context.strokePath()
                })
        case .diagonalBelt:
            let beltLineW = W * 0.5
            W = W * 1.5
            H = H * 1.5
            var beltMoveTo: CGPoint?
            var beltLineTo: CGPoint?
            switch self.checkboxPosition {
            case .topRight:
                addX = M * (isRemove ? 5.75 : 5)
                addY = -M * (isRemove ? 1 : 2)
                beltMoveTo = CGPoint(x: W * 0.5, y: 0)
                beltLineTo = CGPoint(x: W,       y: H * 0.5)
            case .bottomLeft:
                addX = -M * 1.25
                addY = M * 5.5
                beltMoveTo = CGPoint(x: -W * 0.25, y: H * 0.25)
                beltLineTo = CGPoint(x: W * 0.5,   y: H)
            case .topLeft:
                addX = -M * (isRemove ? 1.25 : 0.5)
                addY = -M * (isRemove ? 1 : 2)
                beltMoveTo = CGPoint(x: W * 0.5, y: 0)
                beltLineTo = CGPoint(x: 0,       y: H * 0.5)
            case .bottomRight:
                addX = M * (isRemove ? 5.25 : 5.75)
                addY = M * (isRemove ? 6 : 5)
                beltMoveTo = CGPoint(x: W,       y: H * 0.5)
                beltLineTo = CGPoint(x: W * 0.5, y: H)
            }
            imageUnselect = UIImage.size(width: W, height: H)
                .color(.clear)
                .image
                .with({ context in
                    context.setLineCap(.square)
                    UIColor.white.withAlphaComponent(0.3).setStroke()
                    context.setLineWidth(beltLineW)
                    context.move(to: beltMoveTo!)
                    context.addLine(to: beltLineTo!)
                    context.strokePath()
                    
                    context.setLineCap(.round)
                    UIColor.white.setStroke()
                    context.setLineWidth(L)
                    context.move(to: CGPoint(x: M * shape[0] + addX, y: M * shape[1] + addY))
                    context.addLine(to: CGPoint(x: M * shape[2] + addX, y: M * shape[3] + addY))
                    context.move(to: CGPoint(x: M * shape[4] + addX, y: M * shape[5] + addY))
                    context.addLine(to: CGPoint(x: M * shape[6] + addX, y: M * shape[7] + addY))
                    context.strokePath()
                })
            
            imageSelect = UIImage.size(width: W, height: H)
                .color(.clear)
                .image
                .with({ context in
                    context.setLineCap(.square)
                    tin.setStroke()
                    context.setLineWidth(beltLineW)
                    context.move(to: beltMoveTo!)
                    context.addLine(to: beltLineTo!)
                    context.strokePath()
                    
                    context.setLineCap(.round)
                    UIColor.white.setStroke()
                    context.setLineWidth(L)
                    context.move(to: CGPoint(x: M * shape[0] + addX, y: M * shape[1] + addY))
                    context.addLine(to: CGPoint(x: M * shape[2] + addX, y: M * shape[3] + addY))
                    context.move(to: CGPoint(x: M * shape[4] + addX, y: M * shape[5] + addY))
                    context.addLine(to: CGPoint(x: M * shape[6] + addX, y: M * shape[7] + addY))
                    context.strokePath()
                })
        case .triangle:
            let beltLineW = W * 0.75
            var beltMoveTo: CGPoint?
            var beltLineTo: CGPoint?
            switch self.checkboxPosition {
            case .topRight:
                addX = M * 2
                addY = -M * (isRemove ? 1.75 : 2.5)
                beltMoveTo = CGPoint(x: W * 0.5, y: 0)
                beltLineTo = CGPoint(x: W, y: H * 0.5)
            case .bottomLeft:
                addX = -M * (isRemove ? 2 : 1.75)
                addY = M * (isRemove ? 1.75 : 1.5)
                beltMoveTo = CGPoint(x: -W * 0.25, y: H * 0.25)
                beltLineTo = CGPoint(x: W * 0.5, y: H)
            case .topLeft:
                addX = -M * (isRemove ? 2 : 1.5)
                addY = -M * (isRemove ? 1.75 : 2.5)
                beltMoveTo = CGPoint(x: W * 0.5, y: 0)
                beltLineTo = CGPoint(x: 0, y: H * 0.5)
            case .bottomRight:
                addX = M * (isRemove ? 2 : 1.5)
                addY = M * (isRemove ? 1.75 : 1.5)
                beltMoveTo = CGPoint(x: W, y: H * 0.5)
                beltLineTo = CGPoint(x: W * 0.5, y: H)
            }
            
            imageUnselect = UIImage.size(width: W, height: H)
                .color(.clear)
                .image
                .with({ context in
                    context.setLineCap(.square)
                    UIColor.white.withAlphaComponent(0.3).setStroke()
                    context.setLineWidth(beltLineW)
                    context.move(to: beltMoveTo!)
                    context.addLine(to: beltLineTo!)
                    context.strokePath()
                    
                    context.setLineCap(.round)
                    UIColor.white.setStroke()
                    context.setLineWidth(L)
                    context.move(to: CGPoint(x: M * shape[0] + addX, y: M * shape[1] + addY))
                    context.addLine(to: CGPoint(x: M * shape[2] + addX, y: M * shape[3] + addY))
                    context.move(to: CGPoint(x: M * shape[4] + addX, y: M * shape[5] + addY))
                    context.addLine(to: CGPoint(x: M * shape[6] + addX, y: M * shape[7] + addY))
                    context.strokePath()
                })
            
            imageSelect = UIImage.size(width: W, height: H)
                .color(.clear)
                .image
                .with({ context in
                    context.setLineCap(.square)
                    tin.setStroke()
                    context.setLineWidth(beltLineW)
                    context.move(to: beltMoveTo!)
                    context.addLine(to: beltLineTo!)
                    context.strokePath()
                    
                    context.setLineCap(.round)
                    UIColor.white.setStroke()
                    context.setLineWidth(L)
                    context.move(to: CGPoint(x: M * shape[0] + addX, y: M * shape[1] + addY))
                    context.addLine(to: CGPoint(x: M * shape[2] + addX, y: M * shape[3] + addY))
                    context.move(to: CGPoint(x: M * shape[4] + addX, y: M * shape[5] + addY))
                    context.addLine(to: CGPoint(x: M * shape[6] + addX, y: M * shape[7] + addY))
                    context.strokePath()
                })
        case .heart:
            let spaceW = W/8
            let radius = (W-spaceW*2)/4
            let leftCenter = CGPoint(x: spaceW+radius, y: spaceW+radius)
            let rightCenter = CGPoint(x: spaceW+radius*3, y: spaceW+radius)
            
            imageUnselect = UIImage.size(width: W, height: H)
                .color(.clear)
                .image
                .with({ context in
                    let heartLine = UIBezierPath(arcCenter: leftCenter, radius: radius, startAngle: CGFloat(Double.pi), endAngle: 0, clockwise: true)
                    heartLine.addArc(withCenter: rightCenter, radius: radius, startAngle: CGFloat(Double.pi), endAngle: 0, clockwise: true)
                    heartLine.addQuadCurve(to: CGPoint(x: W/2, y: H-spaceW*2), controlPoint: CGPoint(x: W-spaceW, y: H*0.6))
                    heartLine.addQuadCurve(to: CGPoint(x: spaceW, y: spaceW+radius), controlPoint: CGPoint(x: spaceW, y: H*0.6))
                    context.addPath(heartLine.cgPath)
                    context.setLineCap(.round)
                    UIColor.white.withAlphaComponent(0.7).setStroke()
                    context.setLineWidth(L)
                    context.strokePath()
                })
            imageSelect = UIImage.size(width: W, height: H)
                .color(.clear)
                .image
                .with({ context in
                    let heartLine = UIBezierPath(arcCenter: leftCenter, radius: radius, startAngle: CGFloat(Double.pi), endAngle: 0, clockwise: true)
                    heartLine.addArc(withCenter: rightCenter, radius: radius, startAngle: CGFloat(Double.pi), endAngle: 0, clockwise: true)
                    heartLine.addQuadCurve(to: CGPoint(x: W/2, y: H-spaceW*2), controlPoint: CGPoint(x: W-spaceW, y: H*0.6))
                    heartLine.addQuadCurve(to: CGPoint(x: spaceW, y: spaceW+radius), controlPoint: CGPoint(x: spaceW, y: H*0.6))
                    context.addPath(heartLine.cgPath)
                    context.setLineCap(.round)
                    tin.set()
                    context.fillPath()
                })
        case .star:
            let spaceW = W/10
            let centerPoint = CGPoint(x: W * 0.5, y: H * 0.5)
            let radius: Float = Float(W * 0.5 - spaceW)
            var p = CGPoint(x: centerPoint.x, y: centerPoint.y-CGFloat(radius))
            let angle: Float = Float(4 * Double.pi / 5.0);
            
            imageUnselect = UIImage.size(width: W, height: H)
                .color(.clear)
                .border(color: UIColor.white.withAlphaComponent(0.7))
                .border(width: TGPhotoPickerConfig.shared.isShowBorder ? TGPhotoPickerConfig.shared.checkboxLineW : 0)
                .corner(radius: W * 0.5)
                .image
                .with({ context in
                    context.setLineCap(.round)
                    UIColor.white.withAlphaComponent(0.3).setFill()
                    context.setLineWidth(L)
                    context.move(to: p)
                    for i in 1...5{
                        let x = centerPoint.x - CGFloat(sinf(Float(i) * angle) * radius)
                        let y = centerPoint.y - CGFloat(cosf(Float(i) * angle) * radius)
                        context.addLine(to: CGPoint(x: (p.x + x)/2 + (i == 2 || i == 5 ? L : -L), y: (p.y + y)/2 + (i == 3 ? -L : 0) ))
                        p = CGPoint(x: x, y: y)
                        context.addLine(to: p)
                    }
                    context.fillPath()
                })
            imageSelect = UIImage.size(width: W, height: H)
                .color(.clear)
                .image
                .with({ context in
                    context.setLineCap(.round)
                    tin.setFill()
                    //context.setLineWidth(L)
                    context.move(to: p)
                    for i in 1...5{
                        let x = centerPoint.x - CGFloat(sinf(Float(i) * angle) * radius)
                        let y = centerPoint.y - CGFloat(cosf(Float(i) * angle) * radius)
                        context.addLine(to: CGPoint(x: (p.x + x)/2 + (i == 2 || i == 5 ? L : -L), y: (p.y + y)/2 + (i == 3 ? -L : 0) ))
                        p = CGPoint(x: x, y: y)
                        context.addLine(to: p)
                    }
                    context.fillPath()
                })
        //default: break
        }
        
        return(imageSelect!,imageUnselect!,CGSize(width: W, height: H))
    }
    
    private func cacheNumberImage(){
        if isShowNumber{
            switch checkboxType {
            case .onlyCheckbox,.circle,.square,.belt,.diagonalBelt,.triangle,.heart,.star:
                //cache
                cacheNumerImageArr.removeAll()
                for i in 1...maxImageCount{
                    if let image = getDigitImage(UInt(i)){
                        cacheNumerImageArr.append(image)
                    }
                }
            //default:
                //clear cache
                //cacheNumerImageArr.removeAll()
            }
        }else{
            //clear cache
            cacheNumerImageArr.removeAll()
        }
    }
    
    class func getChineseAlbumName(_ type: PHAssetCollectionSubtype,_ name: String = "") -> String{
        switch type {
        case .smartAlbumPanoramas:
            return "全景照片"
        case .smartAlbumVideos:
            return "视频"
        case .smartAlbumFavorites:
            return "个人收藏"
        case .smartAlbumTimelapses:
            return "延时摄影"
        case .smartAlbumAllHidden:
            return "隐藏"
        case .smartAlbumRecentlyAdded:
            return "最近添加"
        case .smartAlbumBursts:
            return "连拍快照"
        case .smartAlbumSlomoVideos:
            return "慢动作"
        case .smartAlbumUserLibrary:
            return "所有照片"//相机胶卷
        case .smartAlbumSelfPortraits:
            return "自拍"
        case .smartAlbumScreenshots:
            return "屏幕快照"
        case .smartAlbumDepthEffect:
            return "景深效果"
        case .smartAlbumLivePhotos:
            return "Live Photo"
        default:
            switch name {
            case "Recently Deleted":
                return "最近删除"
            default:
                return name
            }
        }
    }
}

extension UIColor{
    func getAlpha() -> CGFloat {
        var r : CGFloat = 0
        var g : CGFloat = 0
        var b : CGFloat = 0
        var a : CGFloat = 0
        
        if self.getRed(&r, green: &g, blue: &b, alpha: &a){
            return a
        }
        
        guard let cmps = self.cgColor.components else {
            return 1
        }
        return cmps[3]
    }
}
