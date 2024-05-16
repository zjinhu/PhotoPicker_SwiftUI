//
//  CropViewController.swift
//
//
//  Created by FunWidget on 2024/5/14.
//

import UIKit
import AVFoundation
import Photos
public class CropViewController: HXBaseViewController {
    
    public typealias FinishHandler = (EditorAsset, CropViewController) -> Void
    public typealias CancelHandler = (CropViewController) -> Void
    
    public weak var delegate: CropViewControllerDelegate?
    public var config: EditorConfiguration
    public let assets: [EditorAsset]
    public var selectedAsset: EditorAsset
    public var editedResult: EditedResult?
    public var finishHandler: FinishHandler?
    public var cancelHandler: CancelHandler?
    
    public private(set) var selectedIndex: Int = 0
    
    public var topMaskView: UIView!
    public var bottomMaskView: UIView!
    public var topMaskLayer: CAGradientLayer!
    public var bottomMaskLayer: CAGradientLayer!
 
    var finishScaleAngle: CGFloat = 0
    var lastScaleAngle: CGFloat = 0
    var finishRatioIndex: Int
    
    var backgroundInsetRect: CGRect = .zero
    var isDismissed: Bool = false
    var isPopTransition: Bool = false
    var isTransitionCompletion: Bool = true
    var loadAssetStatus: LoadAssetStatus = .loadding()
    weak var assetLoadingView: PhotoHUDProtocol?
    var selectedOriginalImage: UIImage?
    var selectedThumbnailImage: UIImage?
    var assetRequestID: PHImageRequestID?
    var isLoadCompletion: Bool = false
    var isLoadVideoControl: Bool = false
 
    weak var videoPlayTimer: Timer?
    var orientationDidChange: Bool = false
    var videoControlInfo: EditorVideoControlInfo?
    var videoCoverView: UIImageView?
    weak var videoTool: EditorVideoTool?
    
    public init(
        _ asset: EditorAsset,
        config: EditorConfiguration = .init(),
        delegate: CropViewControllerDelegate? = nil,
        finish: FinishHandler? = nil,
        cancel: CancelHandler? = nil
    ) {
        self.assets = [asset]
        self.selectedAsset = asset
        self.config = config
        self.delegate = delegate
        finishHandler = finish
        cancelHandler = cancel
        editedResult = asset.result
        finishRatioIndex = config.cropSize.isRoundCrop ? -1 : config.cropSize.defaultSeletedIndex
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        removeVideo()
    }
    
    func removeVideo() {
        if editorView.type == .video {
            editorView.pauseVideo()
            editorView.cancelVideoCroped()
            videoTool?.cancelExport()
            videoTool = nil
        }
    }
    
    lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    lazy var leftRotateButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "rotate.left"), for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(didLeftRotateButtonClick(button:)), for: .touchUpInside)
        button.contentEdgeInsets = UIEdgeInsets(top: 4, left: 10, bottom: 4, right: 10)
        return button
    }()
    
    lazy var rightRotateButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "rotate.right"), for: .normal)
        button.tintColor = .white
        button.contentEdgeInsets = UIEdgeInsets(top: 4, left: 10, bottom: 4, right: 10)
        button.addTarget(self, action: #selector(didRightRotateButtonClick(button:)), for: .touchUpInside)
        return button
    }()
    
    lazy var resetButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "arrow.2.circlepath"), for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(didResetButtonClick(button:)), for: .touchUpInside)
        button.contentEdgeInsets = UIEdgeInsets(top: 4, left: 10, bottom: 4, right: 10)
        return button
    }()
    
    lazy var finishButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "checkmark"), for: .normal)
        button.tintColor = .white
        button.contentEdgeInsets = UIEdgeInsets(top: 4, left: 10, bottom: 4, right: 10)
        button.addTarget(self, action: #selector(didFinishButtonClick(button:)), for: .touchUpInside)
        button.isEnabled = !config.isWhetherFinishButtonDisabledInUneditedState
        return button
    }()
    
    lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(didCancelButtonClick(button:)), for: .touchUpInside)
        button.contentEdgeInsets = UIEdgeInsets(top: 4, left: 10, bottom: 4, right: 10)
        return button
    }()
    
    var navModalStyle: UIModalPresentationStyle?
    var navFrame: CGRect?
    var firstAppear = true
    var isFullScreen: Bool {
        let isFull = splitViewController?.modalPresentationStyle == .fullScreen
        if let nav = navigationController {
            return nav.modalPresentationStyle == .fullScreen || nav.modalPresentationStyle == .custom || isFull
        }else {
            if let navModalStyle {
                return navModalStyle == .fullScreen || navModalStyle == .custom || isFull
            }
            return modalPresentationStyle == .fullScreen || modalPresentationStyle == .custom || isFull
        }
    }
    
    lazy var editorView: EditorView = {
        let editorView = EditorView()
        editorView.editContentInset = { [weak self] _ in
            guard let self = self else {
                return .zero
            }
            if UIDevice.isPortrait {
                let top: CGFloat
                let bottom: CGFloat
                var bottomMargin = UIDevice.bottomMargin
                if !self.isFullScreen, UIDevice.isPad {
                    bottomMargin = 0
                }
                if self.config.buttonType == .bottom {
                    if self.isFullScreen {
                        top = UIDevice.isPad ? 50 : UIDevice.topMargin + 10
                    }else {
                        top = 30
                    }
                    bottom = bottomMargin + 55 + 140
                }else {
                    let navHeight: CGFloat
                    if let barHeight = self.navigationController?.navigationBar.height {
                        navHeight = barHeight
                    }else {
                        navHeight = UIDevice.navBarHeight
                    }
                    if self.isFullScreen {
                        let navY: CGFloat
                        if UIDevice.isPad {
                            navY = UIDevice.generalStatusBarHeight
                        }else {
                            if let barY = self.navigationController?.navigationBar.y, barY >= 0 {
                                navY = barY
                            }else {
                                navY = UIDevice.generalStatusBarHeight
                            }
                        }
                        top = navY + navHeight + 15
                    }else {
                        top = navHeight + 15
                    }
                    if UIDevice.isPad {
                        bottom = bottomMargin + 160
                    }else {
                        bottom = bottomMargin + 140
                    }
                }
                let left = UIDevice.isPad ? 30 : UIDevice.leftMargin + 15
                let right = UIDevice.isPad ? 30 : UIDevice.rightMargin + 15
                return .init(top: top, left: left, bottom: bottom, right: right)
            }else {
                let margin = self.view.width + 15
                return .init(
                    top: UIDevice.topMargin + 55,
                    left: margin,
                    bottom: UIDevice.bottomMargin + 15,
                    right: margin
                )
            }
        }
        editorView.urlConfig = config.urlConfig
        editorView.exportScale = config.photo.scale
        editorView.initialRoundMask = config.cropSize.isRoundCrop
        editorView.initialFixedRatio = config.cropSize.isFixedRatio
        editorView.initialAspectRatio = config.cropSize.aspectRatio
        editorView.maskType = config.cropSize.maskType
        editorView.isShowScaleSize = config.cropSize.isShowScaleSize
        if config.cropSize.isFixedRatio {
            editorView.isResetIgnoreFixedRatio = config.cropSize.isResetToOriginal
        }else {
            editorView.isResetIgnoreFixedRatio = true
        }
        editorView.editDelegate = self
        editorView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapClick)))
        return editorView
    }()
    
    lazy var backgroundView: UIScrollView = {
        let backgroundView = UIScrollView()
        backgroundView.maximumZoomScale = 1
        backgroundView.showsVerticalScrollIndicator = false
        backgroundView.showsHorizontalScrollIndicator = false
        backgroundView.clipsToBounds = false
        backgroundView.scrollsToTop = false
        backgroundView.isScrollEnabled = false
        backgroundView.bouncesZoom = false
        backgroundView.delegate = self
        backgroundView.contentInsetAdjustmentBehavior = .never
        return backgroundView
    }()
    
    lazy var videoControlView: EditorVideoControlView = {
        var cropTime = config.video.cropTime
        if config.isFixedCropSizeState && config.isIgnoreCropTimeWhenFixedCropSizeState {
            cropTime.maximumTime = 0
        }
        let videoControlView = EditorVideoControlView(config: cropTime)
        videoControlView.delegate = self
        return videoControlView
    }()
    
    public override func deviceOrientationWillChanged() {
        
        if editorView.type == .video {
            if ProcessInfo.processInfo.isiOSAppOnMac, editorView.isVideoPlaying {
                stopPlayVideo()
                editorView.pauseVideo()
            }
            videoControlView.stopScroll()
            videoControlView.stopLineAnimation()
            videoControlInfo = videoControlView.controlInfo
        }
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        initViews()
        addViews()
        initAsset()
    }
    
    private func initViews() {
        
        topMaskLayer = PhotoTools.getGradientShadowLayer(true)
        topMaskView = UIView()
        topMaskView.isUserInteractionEnabled = false
        topMaskView.layer.addSublayer(topMaskLayer)
        
        bottomMaskLayer = PhotoTools.getGradientShadowLayer(false)
        bottomMaskView = UIView()
        bottomMaskView.isUserInteractionEnabled = false
        bottomMaskView.layer.addSublayer(bottomMaskLayer)
        
    }
    
    private func addViews() {
        view.clipsToBounds = true
        view.backgroundColor = .black
        
        view.addSubview(backgroundView)
        backgroundView.addSubview(editorView)
        
        view.addSubview(bottomMaskView)
        view.addSubview(topMaskView)
        view.addSubview(videoControlView)
        
        view.addSubview(stackView)
        
        stackView.addArrangedSubview(cancelButton)
        stackView.addArrangedSubview(leftRotateButton)
        stackView.addArrangedSubview(resetButton)
        stackView.addArrangedSubview(rightRotateButton)
        stackView.addArrangedSubview(finishButton)
        
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        editorView.frame = view.bounds
        
        backgroundView.frame = view.bounds
        backgroundView.contentSize = view.size
        
        bottomMaskLayer.removeFromSuperlayer()
        
        let buttonHeight: CGFloat
        if UIDevice.isPortrait && config.buttonType == .bottom {
            buttonHeight = 50
        }else {
            buttonHeight = 44
        }
        
        if UIDevice.isPortrait {
            layoutPortraitViews(buttonHeight)
        }else {
            layoutNotPortraitViews()
        }
        
        topMaskLayer.frame = topMaskView.bounds
        updateBottomMaskLayer()
        
        if firstAppear {
            firstAppear = false
            loadVideoControl()
            if isLoadCompletion {
            }
            loadCorpSizeData()
            editorView.layoutSubviews()
            checkLastResultState()
        }
        updateVideoControlInfo()
        if orientationDidChange {
            editorView.update()
            orientationDidChange = false
        }
        
        stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -UIDevice.bottomMargin).isActive = true
        stackView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
        stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16).isActive = true
    }
    
    func layoutPortraitViews(_ buttonHeight: CGFloat) {
        bottomMaskLayer = PhotoTools.getGradientShadowLayer(false)
        bottomMaskView.layer.addSublayer(bottomMaskLayer)
        
        if navFrame == nil {
            navFrame = navigationController?.navigationBar.frame
        }
        let navHeight: CGFloat
        if let frameHeight = navFrame?.height {
            navHeight = frameHeight
        }else {
            navHeight = UIDevice.navBarHeight
        }
        var navY: CGFloat = 0
        if isFullScreen {
            if UIDevice.isPad {
                navY = UIDevice.generalStatusBarHeight
            }else {
                if let minY = navFrame?.minY, minY >= 0 {
                    navY = minY
                }else {
                    navY = UIDevice.generalStatusBarHeight
                }
            }
            topMaskView.frame = .init(x: 0, y: 0, width: view.width, height: navY + navHeight + 10)
        }else {
            topMaskView.frame = .init(x: 0, y: 0, width: view.width, height: navHeight)
        }
        
        if orientationDidChange || firstAppear {
            videoControlView.frame = .init(x: 0, y: view.height - UIDevice.bottomMargin - 80, width: view.width, height: 50)
        }
    }
    
    func layoutNotPortraitViews() {
        bottomMaskLayer = PhotoTools.getGradientShadowLayer(
            startPoint: .init(x: 0, y: 0),
            endPoint: .init(x: 1, y: 0)
        )
        bottomMaskView.isHidden = true
        if isTransitionCompletion && !isPopTransition {
            bottomMaskView.alpha = 0
        }
        bottomMaskView.layer.addSublayer(bottomMaskLayer)
        
        topMaskView.isHidden = false
        bottomMaskView.isHidden = false
        if isTransitionCompletion && !isPopTransition {
            topMaskView.alpha = 1
            bottomMaskView.alpha = 1
        }
        
        topMaskView.frame = .init(x: 0, y: 0, width: view.width, height: UIDevice.topMargin + 50)
        
        if orientationDidChange || firstAppear {
            videoControlView.frame = .init(
                x: 0,
                y: view.height - UIDevice.bottomMargin - 60,
                width: view.width, height: 40
            )
        }
        
    }
    
    
    func updateBottomMaskLayer() {
        if UIDevice.isPortrait {
            let layerHeight = UIDevice.bottomMargin + 55
   
            bottomMaskView.frame = .init(x: 0, y: view.height - layerHeight, width: view.width, height: layerHeight)
        }else {
            let layerWidth  = 65 + UIDevice.rightMargin
            
            bottomMaskView.frame = .init(x: view.width - layerWidth, y: 0, width: layerWidth, height: view.height)
        }
        bottomMaskLayer.frame = bottomMaskView.bounds
    }
    
    func updateVideoControlInfo() {
        if let videoControlInfo = videoControlInfo {
            videoControlView.reloadVideo()
            videoControlView.layoutIfNeeded()
            if ProcessInfo.processInfo.isiOSAppOnMac {
                videoControlView.setControlInfo(videoControlInfo)
                videoControlView.resetLineViewFrsme(at: editorView.videoPlayTime)
                updateVideoTimeRange()
            }else {
                DispatchQueue.main.async {
                    self.videoControlView.setControlInfo(videoControlInfo)
                    self.videoControlView.resetLineViewFrsme(at: self.editorView.videoPlayTime)
                    self.updateVideoTimeRange()
                }
            }
            self.videoControlInfo = nil
        }
    }
}
