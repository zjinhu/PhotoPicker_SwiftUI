//
//  File.swift
//  
//
//  Created by HU on 2024/5/14.
//

import Foundation
import UIKit

extension CropViewController: UINavigationControllerDelegate {
    public func navigationController(
        _ navigationController: UINavigationController,
        animationControllerFor operation: UINavigationController.Operation,
        from fromVC: UIViewController,
        to toVC: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        if operation == .push {
            isTransitionCompletion = false
            return EditorTransition(mode: .push)
        }else if operation == .pop {
            isPopTransition = true
            return EditorTransition(mode: .pop)
        }
        return nil
    }
}

extension CropViewController: UIViewControllerTransitioningDelegate {
    
    public func animationController(
        forPresented presented: UIViewController,
        presenting: UIViewController,
        source: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        isTransitionCompletion = false
        return EditorTransition(mode: .present)
    }
    
    public func animationController(
        forDismissed dismissed: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        isPopTransition = true
        return EditorTransition(mode: .dismiss)
    }
}


extension CropViewController {
    
    func setTransitionImage(_ image: UIImage) {
        editorView.setImage(image)
    }
    
    func transitionHide() {
        bottomMaskView.alpha = 0
        topMaskView.alpha = 0
    }
    
    func transitionShow() {
        if config.isFixedCropSizeState {
            return
        }
        if selectedAsset.contentType == .image {
            if let type = config.photo.defaultSelectedToolOption, type == .cropSize {
                return
            }
        }else if selectedAsset.contentType == .video {
            if let type = config.video.defaultSelectedToolOption, type == .cropSize {
                return
            }
        }
        showTools()
    }
    
    func showTools(_ isCropSize: Bool = false) {
        if cancelButton.alpha == 1 {
            return
        }
        cancelButton.alpha = 1
        finishButton.alpha = 1
        if !isCropSize {
            showMasks()
        }
    }
    
    func showMasks() {
        
        topMaskView.alpha = 1
        bottomMaskView.alpha = 1
        
    }
    
    func hideMasks() {
        
        topMaskView.alpha = 0
        bottomMaskView.alpha = 0
        
    }
    
    func transitionCompletion() {
        switch loadAssetStatus {
        case .loadding(let isProgress):
            if isProgress {
                
                assetLoadingView = PhotoManager.HUDView.show(with: nil, delay: 0, animated: true, addedTo: view)
                
            }else {
                PhotoManager.HUDView.show(with: nil, delay: 0, animated: true, addedTo: view)
            }
        case .succeed(let type):
            initAssetType(type)
        case .failure:
            if selectedAsset.contentType == .video {
                loadFailure(message: .textManager.editor.videoLoadFailedAlertMessage.text)
            }else {
                loadFailure(message: .textManager.editor.photoLoadFailedAlertMessage.text)
            }
        }
    }
}
