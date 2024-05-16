//
//  EditViewController.swift
//  
//
//  Created by FunWidget on 2024/5/13.
//

import UIKit
import AVFoundation
import Photos


class EditViewController: EditorViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initViews()
        addViews()
        initAsset()
    }
 
    private var stackView: UIStackView!
    
    private func initViews() {

        cancelButton = UIButton(type: .custom)
        cancelButton.setTitle(.textManager.editor.tools.cancelTitle.text, for: .normal)
        cancelButton.setTitleColor(config.cancelButtonTitleColor, for: .normal)
        cancelButton.setTitleColor(config.cancelButtonTitleColor.withAlphaComponent(0.5), for: .highlighted)
        cancelButton.titleLabel?.font = .textManager.editor.tools.cancelTitleFont
        cancelButton.contentHorizontalAlignment = .left
        cancelButton.addTarget(self, action: #selector(didCancelButtonClick(button:)), for: .touchUpInside)
        
        finishButton = UIButton(type: .custom)
        finishButton.setTitle(.textManager.editor.tools.finishTitle.text, for: .normal)
        finishButton.setTitleColor(config.finishButtonTitleNormalColor, for: .normal)
        finishButton.setTitleColor(config.finishButtonTitleNormalColor.withAlphaComponent(0.5), for: .highlighted)
        finishButton.setTitleColor(config.finishButtonTitleDisableColor.withAlphaComponent(0.5), for: .disabled)
        finishButton.titleLabel?.font = .textManager.editor.tools.finishTitleFont
        finishButton.contentHorizontalAlignment = .right
        finishButton.addTarget(self, action: #selector(didFinishButtonClick(button:)), for: .touchUpInside)
        finishButton.isEnabled = !config.isWhetherFinishButtonDisabledInUneditedState
        
        resetButton = UIButton(type: .custom)
        resetButton.setTitle(.textManager.editor.tools.resetTitle.text, for: .normal)
        resetButton.setTitleColor(.white, for: .normal)
        resetButton.setTitleColor(.white.withAlphaComponent(0.5), for: .highlighted)
        resetButton.setTitleColor(.white.withAlphaComponent(0.5), for: .disabled)
        resetButton.titleLabel?.font = .textManager.editor.tools.resetTitleFont
        resetButton.addTarget(self, action: #selector(didResetButtonClick(button:)), for: .touchUpInside)
        resetButton.alpha = 0
        resetButton.isHidden = true
        
        leftRotateButton = ExpandButton(type: .system)
        leftRotateButton.setImage(.imageResource.editor.crop.rotateLeft.image, for: .normal)
        if let btnSize = leftRotateButton.currentImage?.size {
            leftRotateButton.size = btnSize
        }
        leftRotateButton.tintColor = .white
        leftRotateButton.addTarget(self, action: #selector(didLeftRotateButtonClick(button:)), for: .touchUpInside)
        leftRotateButton.alpha = 0
        leftRotateButton.isHidden = true
        
        rightRotateButton = ExpandButton(type: .system)
        rightRotateButton.setImage(.imageResource.editor.crop.rotateRight.image, for: .normal)
        if let btnSize = rightRotateButton.currentImage?.size {
            rightRotateButton.size = btnSize
        }
        rightRotateButton.tintColor = .white
        rightRotateButton.addTarget(self, action: #selector(didRightRotateButtonClick(button:)), for: .touchUpInside)
        rightRotateButton.alpha = 0
        rightRotateButton.isHidden = true
        
        editorView = EditorView()
        
        backgroundView = UIScrollView()
        backgroundView.maximumZoomScale = 1
        backgroundView.showsVerticalScrollIndicator = false
        backgroundView.showsHorizontalScrollIndicator = false
        backgroundView.clipsToBounds = false
        backgroundView.scrollsToTop = false
        backgroundView.isScrollEnabled = false
        backgroundView.bouncesZoom = false
        backgroundView.delegate = self
        backgroundView.contentInsetAdjustmentBehavior = .never
        
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
                let margin = self.view.width - self.rotateScaleView.x + 15
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
        if !config.brush.colors.isEmpty {
            editorView.drawLineColor = config.brush.colors[
                min(max(config.brush.defaultColorIndex, 0), config.brush.colors.count - 1)
            ].color
        }

        editorView.editDelegate = self
        editorView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapClick)))
        
        topMaskLayer = PhotoTools.getGradientShadowLayer(true)
        topMaskView = UIView()
        topMaskView.isUserInteractionEnabled = false
        topMaskView.layer.addSublayer(topMaskLayer)
        
        bottomMaskLayer = PhotoTools.getGradientShadowLayer(false)
        bottomMaskView = UIView()
        bottomMaskView.isUserInteractionEnabled = false
        bottomMaskView.layer.addSublayer(bottomMaskLayer)
        
        stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        
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
        if orientationDidChange {
            editorView.frame = view.bounds
        }
        
        bottomMaskLayer.removeFromSuperlayer()

        topMaskLayer.frame = topMaskView.bounds
        
        
        updateBottomMaskLayer()
 
        updateVideoControlInfo()
        if orientationDidChange {
            editorView.update()
            orientationDidChange = false
        }
        
        stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -40).isActive = true
        stackView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
        stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16).isActive = true
    }
}

