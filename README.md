<img src="https://github.com/targetcloud/TGPhotoPicker/blob/master/Banners.png" width = "12%" hight = "12%"/>

# TGPhotoPicker

the best photo picker plugin in swift(iOS8+) 
No using picture resources, based on TGImage

![Swift](https://img.shields.io/badge/Swift-3.0-orange.svg)
![Build](https://img.shields.io/badge/build-passing-green.svg)
![License MIT](https://img.shields.io/badge/license-MIT-green.svg?style=flat)
![Platform](https://img.shields.io/cocoapods/p/Pastel.svg?style=flat)
![Cocoapod](https://img.shields.io/badge/pod-v0.0.5-blue.svg)

## Demo Screenshot

###### 照片选择界面（.weibo）更多效果在下面哦:）

<img src="https://github.com/targetcloud/TGPhotoPicker/blob/master/img/IMG_2642.PNG" width = "60%" />

###### 参数调节界面(只为方便直观查看本插件的参数效果，实际使用时请直接参考TGPhotoPickerConfig.swift提供的参数)

<img src="https://github.com/targetcloud/TGPhotoPicker/blob/master/img/IMG_2641.PNG" width = "60%" />

###### 自定义拍照界面

<img src="https://github.com/targetcloud/TGPhotoPicker/blob/master/img/IMG_2584.PNG" width = "60%" />

## Recently Updated
- 0.0.5 添加AlertSheet类和useCustomActionSheet配置属性
- 0.0.4 新增11个属性，向下兼容iOS8，其中最主要的新增功能是2个，1是允许用户选择使用iOS8或iOS10拍照功能，推荐仍使用iOS8，默认使用iOS10;2是拍照时是否同时把拍照结果保存到系统相册中去，默认不保存
- 0.0.3 丰富的参数，`DIY`你满意的一款photo picker

## Features
- [x] 不使用图片资源，基于TGImage实现
- [x] 支持`链式`编程配置，程序员的最爱
- [x] 支持`Cocoapods`
- [x] 支持2种`遮罩`模式（直接在选择的照片cell上显示遮罩、选择到最大照片数量后其余照片cell显示遮罩）
- [x] 支持选择完成后，长按控件的照片cell进行位置调整(iOS `9` 及以上有效)
- [x] 支持2种`删除`模式（选择完成后直接点每个照片cell上的删除按钮删除、选择完成后预览单个照片大图时点工具栏上的删除按钮删除）
- [x] 支持选择指示器`选择时的顺序`数字显示（每个照片cell的状态有5种状态:未选择、选中状态、数字选中状态、删除状态、按住删除按钮时的高亮状态）
- [x] 支持2种`选择`模式（直接选择、预览选择）
- [x] 预置`weibo`、`wechat` 2种成组配置模式，省去多个参数配置，简化为一句代码配置
- [x] 支持8种`选择样式`（类型）`单勾`、`圈`、`方块`、`带`、`斜带`、`三角`、`心`、`星`
- [x] 支持4种`选择位置`（左上、左下、右上、右下）
- [x] 支持`tinColor`统一设置风格
- [x] 支持选择指示器`大小调节`
- [x] 自由选择iOS8或iOS10拍照功能
- [x] 轻量级、使用超灵活、功能超强大
- [x] 用例丰富，快速上手

## Usage
总体分为2种使用方式，有界面的话，用TGPhotoPicker实例化（即多选照片选择完成后把数据呈现在控件上），不需要界面的话用TGPhotoPickerManager.shared.takePhotoModels单例方法获取多选照片数据（这个又分两种，用模型或不用模型（直接用`分开的数组`））

###### 提示:

`1、请先在info.plist中添加以下两个key,以请求相机相册的访问权限（iOS10）`

`NSCameraUsageDescription`（Privacy - Camera Usage Description）
`NSPhotoLibraryUsageDescription`（Privacy - Photo Library Usage Description）

`2、作者的Xcode为8.3.3（8E3004b）若你的版本过低，可能会在TGPhotoPickerConfig.swift文件的case .smartAlbumScreenshots:处出现错误提示:Enum case 'smartAlbumScreenshots' not found in type 'PHAssetCollectionSubtype'   报错原因是这是iOS10.2/10.3新增两个值,    解决办法:1、请升级你的Xcode 2、注释相关代码`

#### 使用默认（有界面）
```swift
lazy var picker: TGPhotoPicker = TGPhotoPicker(self, frame: CGRect(x: 0, y: 50, width: UIScreen.main.bounds.width, height: 200))

override func viewDidLoad() {
        super.viewDidLoad()
        //放到界面中去
        self.view.addSubview(picker)
}
```

#### 带配置（有界面）
```swift
    lazy var picker: TGPhotoPicker = TGPhotoPicker(self, frame: CGRect(x: 0, y: 50, width: UIScreen.main.bounds.width, height: 200)) { (config) in
        config.type = .weibo
        //更多配置在这里添加
    }
```

#### 带配置(链式)
```swift
    lazy var picker: TGPhotoPicker = TGPhotoPicker(self, frame: CGRect(x: 0, y: 50, width: UIScreen.main.bounds.width, height: 200)) { (config) in
        config.tg_type(.wechat)
              .tg_checkboxLineW(1)
    }
```

#### 带配置（单例配置对象）
```swift
    lazy var picker: TGPhotoPicker = TGPhotoPicker(self, frame: CGRect(x: 0, y: 50, width: UIScreen.main.bounds.width, height: 200)) { _ in
        TGPhotoPickerConfig.shared.tg_type(.wechat)
            .tg_checkboxLineW(1)
            .tg_toolBarH(50)
            .tg_useChineseAlbumName(true)
    }
```

#### 其他使用方式（无界面） `模型`数组
```swift
TGPhotoPickerManager.shared.takePhotoModels(true, true) { (array) in
            //示例代码
            self.picker.tgphotos.removeAll()
            self.picker.tgphotos.append(contentsOf: array)
            DispatchQueue.main.async {
                self.picker.reloadData()
            }
        }
```

#### 其他使用方式（无界面） 4个`分开独立`的数组（即模型里成员分出来的）
```swift
TGPhotoPickerManager.shared.takePhotos(true, true, { (config) in
            //链式配置
            config.tg_type(TGPhotoPickerType.weibo)
                .tg_confirmTitle("我知道了")
                .tg_maxImageCount(12)
        }) { (asset, smallImg, bigImg, data) in
            //示例代码
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
```

#### 使用控件中的数据
```swift
func upLoadData(){
        var dataArray = [Data]()
        for model in picker.tgphotos {
            dataArray.append(model.imageData!)
        }
        //上传Data数组
    }
```

#### 可以配置的属性（以下为部分可以配置的参数,完整配置参数见TGPhotoPickerConfig.swift（其中官方Demo中列出了主要的32个参数的使用效果））
``` swift
    /** Alert样式*/
    var useCustomActionSheet: Bool = true
    
    /** 拍照后是否保存照片到相册*/
    var saveImageToPhotoAlbum: Bool = false
    
    /** 使用iOS8相机: false 根据iOS版本判断使用iOS10或iOS8相机; true 指定使用iOS8相机*/
    var useiOS8Camera: Bool = false
    
    /** 与useCustomSmartCollectionsMask结合使用,当useCustomSmartCollectionsMask为true时过滤需要显示smartAlbum的Album类型*/
    var customSmartCollections 
    
    /** 使用自定义的PHAssetCollectionSubtype集合来过滤显示自己想要的相册夹,如想显示慢动作和自拍,那么上面的useCustomSmartCollectionsMask数组中设置为（或添加）[PHAssetCollectionSubtype.smartAlbumSlomoVideos,PHAssetCollectionSubtype.smartAlbumSelfPortraits]*/
    var useCustomSmartCollectionsMask: Bool = true
    
    /** 是否使用中文名称显示smartAlbum的Album名*/
    var useChineseAlbumName: Bool = false
    
    /** 空内容的相册夹是否显示 */
    var isShowEmptyAlbum: Bool = false
    
    /** 升序排列照片*/
    var ascending: Bool = false
    
    /** 预置的成组配置, 微博 微信*/
    var type: TGPhotoPickerType = .normal
    
    /** 在选择类型为方 带时用到的Corner*/
    var checkboxCorner: CGFloat = 0
    
    /** 选择框显示的位置*/
    var checkboxPosition: TGCheckboxPosition = .topRight
    
    /** 移除按钮显示的位置*/
    var removePosition: TGCheckboxPosition = .topRight
    
    /** 移除类型,同选择类型*/
    var removeType: TGCheckboxType = .diagonalBelt
    
    /** 是否显示选择顺序*/
    var isShowNumber: Bool = true
    
    /** 纯数字模式下显示选择顺序时的数字阴影宽,不需要阴影设置为0*/
    var shadowW:CGFloat = 1.0
    
    /** 纯数字模式下显示选择顺序时的数字阴影高,不需要阴影设置为0*/
    var shadowH:CGFloat = 1.0
    
    /** 选择框类型（样式） 8种 */
    var checkboxType: TGCheckboxType = .diagonalBelt
    
    /** 显示在工具栏上的选择框的大小*/
    var checkboxBarWH: CGFloat = 30
    
    /** 显示在照片Cell上的选择框的大小*/
    var checkboxCellWH: CGFloat = 20
    
    /** 选择框起始透明度*/
    var checkboxBeginngAlpha: CGFloat = 1
    
    /** 选择框的结束透明度, 两者用于选择框渐变效果*/
    var checkboxEndingAlpha: CGFloat = 1
    
    /** 选择框的画线宽度, 工具栏上返回、删除按钮的画线宽度*/
    var checkboxLineW: CGFloat = 1.5
    
    /** 选择框的Padding*/
    var checkboxPadding: CGFloat = 1
    
    /** 选择时是否动画效果*/
    var checkboxAnimate: Bool = true
    
    /** 选择时或选择到最大照片数量时，当前或其他Cell的遮罩的透明度*/
    var maskAlpha: CGFloat = 0.6
    
    /** 使用选择遮罩: false,当选择照片数量达到最大值时,其余照片显示遮罩; true,其余照片不显示遮罩,而是已经选择的照片显示遮罩 */
    var useSelectMask: Bool = false
    
    /** 工具条的高度*/
    var toolBarH: CGFloat = 44.0
    
    /** 相册类型列表Cell的高度*/
    var albumCellH: CGFloat = 60.0
    
    /** 照片Cell的高宽,即选择时的呈现的宽高*/
    var selectWH: CGFloat = 80
    
    /** 控件本身的Cell的宽高,即选择后的呈现的宽高*/
    var mainCellWH: CGFloat = 80
    
    /** 自动宽高,用于控件本身Cell的宽高自动计算*/
    var autoSelectWH: Bool = false
    
    /** true,在选择照片界面,点击照片（非checkbox区域）时,不跳转到大图预览界面,而是直接选择或取消选择当前照片; false, 点击照片checkbox区域选择或取消选择当前照片,点击非checkbox区域跳转到大图预览界面*/
    var immediateTapSelect: Bool = false
    
    /** 控件或Cell之间布局时的padding*/
    var padding: CGFloat = 1
    
    /** 左右没有空白,即选择时呈现的UICollectionView没有contentInset中的左右Inset*/
    var leftAndRigthNoPadding: Bool = true
    
    /** 选择时呈现的UICollectionView的每行列数*/
    var colCount: CGFloat = 4
    
    /** 选择后控件本身呈现的UICollectionView的每行列数*/
    var mainColCount: CGFloat = 4
    
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
    var tinColor = UIColor(red: 7/255, green: 179/255, blue: 20/255, alpha: 1)
    
    /** 删除按钮的颜色*/
    var removeHighlightedColor: UIColor = .red
    
    /** 删除按钮是否隐藏*/
    var isRemoveButtonHidden: Bool = false
    
    /** 按钮无效时的文字颜色*/
    var disabledColor: UIColor = .gray
    
    /** 最大照片选择数量上限*/
    var maxImageCount: Int = 9
    
    /** 压缩比,0(most)..1(least) 越小图片就越小*/
    var compressionQuality: CGFloat = 0.5
```
#### 使用链式编程配置时，请在所有属性前加tg_前缀即可

#### 选择指示器各状态组合参数说明（选择类型checkboxType、大小checkboxCellWH、位置checkboxPosition各状态下都起作用,其他配置参数起作用时机见下表（最佳快速上手请使用官方Demo进行参数调配，参数效果立竿见影））

类型 | 未选择状态 | 选择状态 | 删除状态 | 删除高亮状态 | 数字状态| 其他说明
------ | ------ | ------ | ------ | ------ | ------ | ------
只有勾| 勾色white(0.7) 、checkboxLineW | 勾色tincolor、checkboxLineW | 叉色同左 | 叉色removeHighlightedColor | shadowW、shadowH、fontSize、checkboxLineW、checkboxPadding、字色tinColor |
圈勾| 圈色white(0.3)、border色white(0.7)、 勾色white、checkboxLineW、checkboxPadding |  圈色tincolor、 勾色white，checkboxLineW、 渐变（checkboxBeginngAlpha、checkboxEndingAlpha）、 checkboxPadding | 叉色同左 | 叉色removeHighlightedColor | 字色white、圈色tinColor、checkboxPadding | 微博未选择状态勾色clear、微博删除状态叉色white
方勾| 方色white(0.3)、 勾色white、checkboxLineW、checkboxCorner | 方色tincolor、渐变（checkboxBeginngAlpha、checkboxEndingAlpha）、 勾色white、checkboxCorner、checkboxLineW | 叉色同左 | 叉色removeHighlightedColor | 字色white、方色tinColor、checkboxCorner | 
带勾| 带色white(0.3)、 勾色white、渐变（checkboxBeginngAlpha、0.01）、checkboxLineW、checkboxCorner、checkboxPadding | 带色tincolor、 勾色white、    渐变（checkboxBeginngAlpha、0.01）、 checkboxCorner、checkboxPadding、checkboxLineW | 叉色同左 | 叉色removeHighlightedColor | 字色white、带色tinColor（渐变（checkboxBeginngAlpha、0.01））、checkboxCorner | 
斜带勾| 带色white(0.3)、 勾色white、checkboxLineW | 带色tincolor、 勾色white、checkboxLineW | 叉色同左 | 叉色removeHighlightedColor | 底色tinColor、字色white |
三角勾| 角色white(0.3)、 勾色white、checkboxLineW | 角色tincolor、 勾色white、checkboxLineW | 叉色同左 | 叉色removeHighlightedColor | 底色tinColor、字色white |
心| 心色white(0.7)、checkboxLineW、 无勾 | 心色tincolor、 无勾 | 叉色同左、removeType为circle | 叉色removeHighlightedColor | 同circle |
星 | 星色white(0.3)、border色white(0.7)、isShowBorder、checkboxLineW、无勾 | 星色tincolor、无勾、无border  | 叉色同左、removeType为circle | 叉色removeHighlightedColor | 同circle |

### 更多使用配置组合效果请download本项目或fork本项目查看


## ScreenShots

#### 1
<img src="https://github.com/targetcloud/TGPhotoPicker/blob/master/img/IMG_2480.PNG" width = "60%" />

#### 2
<img src="https://github.com/targetcloud/TGPhotoPicker/blob/master/img/IMG_2481.PNG" width = "60%" />

#### 3
<img src="https://github.com/targetcloud/TGPhotoPicker/blob/master/img/IMG_2482.PNG" width = "60%" />

#### 4
<img src="https://github.com/targetcloud/TGPhotoPicker/blob/master/img/IMG_2483.PNG" width = "60%" />

#### 5
<img src="https://github.com/targetcloud/TGPhotoPicker/blob/master/img/IMG_2484.PNG" width = "60%" />

#### 6
<img src="https://github.com/targetcloud/TGPhotoPicker/blob/master/img/IMG_2485.PNG" width = "60%" />

#### 7
<img src="https://github.com/targetcloud/TGPhotoPicker/blob/master/img/IMG_2486.PNG" width = "60%" />

#### 8
<img src="https://github.com/targetcloud/TGPhotoPicker/blob/master/img/IMG_2487.PNG" width = "60%" />

#### 9
<img src="https://github.com/targetcloud/TGPhotoPicker/blob/master/img/IMG_2488.PNG" width = "60%" />

#### 10
<img src="https://github.com/targetcloud/TGPhotoPicker/blob/master/img/IMG_2489.PNG" width = "60%" />

#### 11
<img src="https://github.com/targetcloud/TGPhotoPicker/blob/master/img/IMG_2490.PNG" width = "60%" />

#### 12
<img src="https://github.com/targetcloud/TGPhotoPicker/blob/master/img/IMG_2491.PNG" width = "60%" />

#### 13
<img src="https://github.com/targetcloud/TGPhotoPicker/blob/master/img/IMG_2492.PNG" width = "60%" />

#### 14
<img src="https://github.com/targetcloud/TGPhotoPicker/blob/master/img/IMG_2493.PNG" width = "60%" />

#### 15
<img src="https://github.com/targetcloud/TGPhotoPicker/blob/master/img/IMG_2494.PNG" width = "60%" />

#### 16
<img src="https://github.com/targetcloud/TGPhotoPicker/blob/master/img/IMG_2495.PNG" width = "60%" />

#### 17
<img src="https://github.com/targetcloud/TGPhotoPicker/blob/master/img/IMG_2496.PNG" width = "60%" />

#### 18
<img src="https://github.com/targetcloud/TGPhotoPicker/blob/master/img/IMG_2497.PNG" width = "60%" />

#### 19
<img src="https://github.com/targetcloud/TGPhotoPicker/blob/master/img/IMG_2498.PNG" width = "60%" />


## 运行效果

#### diagonalBelt
![](https://github.com/targetcloud/TGPhotoPicker/blob/master/gif/diagonalBelt.gif) 

#### circle
![](https://github.com/targetcloud/TGPhotoPicker/blob/master/gif/circle.gif) 

#### belt
![](https://github.com/targetcloud/TGPhotoPicker/blob/master/gif/b.gif) 

#### square
![](https://github.com/targetcloud/TGPhotoPicker/blob/master/gif/s.gif) 

#### onlyCheckbox
![](https://github.com/targetcloud/TGPhotoPicker/blob/master/gif/o.gif) 

#### triangle
![](https://github.com/targetcloud/TGPhotoPicker/blob/master/gif/t.gif) 

#### heart
![](https://github.com/targetcloud/TGPhotoPicker/blob/master/gif/h.gif) 

#### star
![](https://github.com/targetcloud/TGPhotoPicker/blob/master/gif/star.gif) 


## Installation
- 下载并拖动TGPhotoPicker到你的工程中

- Cocoapods
```
pod 'TGPhotoPicker'
```

## Reference
- http://blog.csdn.net/callzjy
- https://github.com/targetcloud/TGImage <img src="https://github.com/targetcloud/TGImage/blob/master/snapShot/Banners.png" width = "12%" hight = "12%"/>

如果你觉得赞，请`Star`

<img src="https://github.com/targetcloud/TGPhotoPicker/blob/master/logo.png" width = "12%" hight = "12%"/>
