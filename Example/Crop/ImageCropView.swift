//
//  SwiftUIView.swift
//  
//
//  Created by HU on 2024/4/28.
//

import SwiftUI
import Mantis
import BrickKit
struct ImageCropView: UIViewControllerRepresentable {
    var asset: SelectedAsset
    var cropRatio: CGFloat
    let done : (SelectedAsset) -> Void
    init(asset: SelectedAsset,
         cropRatio: Double,
         done: @escaping (SelectedAsset) -> Void) {
        self.asset = asset
        self.cropRatio = cropRatio
        self.done = done
    }
    
    @Environment(\.dismiss) private var dismiss

    class Coordinator: CropViewControllerDelegate {
        var parent: ImageCropView
        
        init(_ parent: ImageCropView) {
            self.parent = parent
        }
        
        func cropViewControllerDidCrop(_ cropViewController: Mantis.CropViewController, cropped: UIImage, transformation: Transformation, cropInfo: CropInfo) {
            parent.asset.cropImage = cropped
            parent.done(parent.asset)
            parent.dismiss()
        }
        
        func cropViewControllerDidCancel(_ cropViewController: Mantis.CropViewController, original: UIImage) {
            parent.dismiss()
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIViewController(context: Context) -> UIViewController {
        return makeNormalImageCropper(context: context)
     }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        
    }
}

extension ImageCropView {
    func makeNormalImageCropper(context: Context) -> UIViewController {
        var config = Mantis.Config()
        config.cropViewConfig.showAttachedRotationControlView = false
        config.cropToolbarConfig = CropToolbarConfig()
        config.presetFixedRatioType = cropRatio == 0 ? .canUseMultiplePresetFixedRatio() : .alwaysUsingOnePresetFixedRatio(ratio: cropRatio)
        let cropToolbar = CustomizedCropToolbar(frame: .zero)
        let cropViewController = Mantis.cropViewController(image: asset.toImage(),
                                                           config: config,
                                                           cropToolbar: cropToolbar)
        cropViewController.delegate = context.coordinator
        return cropViewController
    }
}

class CustomizedCropToolbar: UIView, CropToolbarProtocol {
    func handleFixedRatioSetted(ratio: Double) { }
    
    func handleFixedRatioUnSetted() { }
    
    var iconProvider: CropToolbarIconProvider?
    
    weak var delegate: CropToolbarDelegate?
    
    var config = CropToolbarConfig()
    
    private lazy var counterClockwiseRotationButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "rotate.left"), for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(counterClockwiseRotate), for: .touchUpInside)
        button.contentEdgeInsets = UIEdgeInsets(top: 4, left: 10, bottom: 4, right: 10)
        return button
    }()

    private lazy var clockwiseRotationButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "rotate.right"), for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(clockwiseRotate), for: .touchUpInside)
        button.contentEdgeInsets = UIEdgeInsets(top: 4, left: 10, bottom: 4, right: 10)
        return button
    }()
    
    private lazy var resetButton: UIButton = {
        let button = UIButton()
        button.setTitle("还原".localString, for: .normal)
//        button.setImage(UIImage(systemName: "arrow.2.circlepath"), for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(reset), for: .touchUpInside)
        button.contentEdgeInsets = UIEdgeInsets(top: 4, left: 10, bottom: 4, right: 10)
        return button
    }()

    private lazy var cropButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "checkmark"), for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(crop), for: .touchUpInside)
        button.contentEdgeInsets = UIEdgeInsets(top: 4, left: 10, bottom: 4, right: 10)
        return button
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(cancel), for: .touchUpInside)
        button.contentEdgeInsets = UIEdgeInsets(top: 4, left: 10, bottom: 4, right: 10)
        return button
    }()
 
    private var stackView: UIStackView?
 
    func createToolbarUI(config: CropToolbarConfig) {
        self.config = config
        
        backgroundColor = config.backgroundColor
 
        stackView = UIStackView()
        addSubview(stackView!)
        
        stackView?.translatesAutoresizingMaskIntoConstraints = false
        stackView?.alignment = .center
        stackView?.distribution = .fillEqually
        
        stackView?.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        stackView?.topAnchor.constraint(equalTo: topAnchor).isActive = true
        stackView?.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        stackView?.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        
        stackView?.addArrangedSubview(cancelButton)
        stackView?.addArrangedSubview(counterClockwiseRotationButton)
        stackView?.addArrangedSubview(resetButton)
        stackView?.addArrangedSubview(clockwiseRotationButton)
        stackView?.addArrangedSubview(cropButton)
    }
 
    public override var intrinsicContentSize: CGSize {
        let superSize = super.intrinsicContentSize
        
        if Orientation.treatAsPortrait {
            return CGSize(width: superSize.width, height: config.heightForVerticalOrientation)
        } else {
            return CGSize(width: config.widthForHorizontalOrientation, height: superSize.height)
        }
    }
 
    @objc private func crop() {
        delegate?.didSelectCrop(self)
    }
    
    @objc private func cancel() {
        delegate?.didSelectCancel(self)
    }
    
    @objc private func counterClockwiseRotate(_ sender: Any) {
        delegate?.didSelectCounterClockwiseRotate(self)
    }

    @objc private func clockwiseRotate(_ sender: Any) {
        delegate?.didSelectClockwiseRotate(self)
    }
 
    @objc private func reset(_ sender: Any) {
        delegate?.didSelectReset(self)
    }

}
