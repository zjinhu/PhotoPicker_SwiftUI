//
//  File.swift
//  
//
//  Created by HU on 2024/5/14.
//

import Foundation
import UIKit
import Photos

public protocol CropViewControllerDelegate: AnyObject {
    
    /// 完成编辑
    /// - Parameters:
    ///   - editorViewController: 对应的`EditorViewController`
    ///   - asset: 当前编辑对象，asset.result 为空则没有编辑
    func editorViewController(
        _ editorViewController: CropViewController,
        didFinish asset: EditorAsset
    )
    
    /// 取消编辑
    /// - Parameter editorViewController: 对应的`EditorViewController`
    func editorViewController(
        didCancel editorViewController: CropViewController
    )
    
    // MARK: 只支持 push/pop ，跳转之前需要 navigationController?.delegate = editorViewController
    /// 转场动画时长
    func editorViewController(
        _ editorViewController: CropViewController,
        transitionDuration mode: EditorTransitionMode
    ) -> TimeInterval
    
    /// 转场过渡动画时展示的image
    /// - Parameters:
    ///   - photoEditorViewController: 对应的 PhotoEditorViewController
    func editorViewController(
        transitionPreviewImage editorViewController: CropViewController
    ) -> UIImage?
    
    /// 跳转界面时起始的视图，用于获取位置大小。与 transitioBegenPreviewFrame 一样
    func editorViewController(
        transitioStartPreviewView editorViewController: CropViewController
    ) -> UIView?
    
    /// 界面返回时对应的视图，用于获取位置大小。与 transitioEndPreviewFrame 一样
    func editorViewController(
        transitioEndPreviewView editorViewController: CropViewController
    ) -> UIView?
    
    /// 跳转界面时对应的起始位置大小
    func editorViewController(
        transitioStartPreviewFrame editorViewController: CropViewController
    ) -> CGRect?
    
    /// 界面返回时对应的位置大小
    func editorViewController(
        transitioEndPreviewFrame editorViewController: CropViewController
    ) -> CGRect?
    
}
    
public extension CropViewControllerDelegate {
    
    func editorViewController(
        _ editorViewController: CropViewController,
        didFinish asset: EditorAsset
    ) {
        back(editorViewController)
    }

    func editorViewController(
        didCancel editorViewController: CropViewController
    ) {
        back(editorViewController)
    }

    func editorViewController(
        _ editorViewController: CropViewController,
        transitionDuration mode: EditorTransitionMode
    ) -> TimeInterval { 0.55 }
    
    func editorViewController(
        transitionPreviewImage editorViewController: CropViewController
    ) -> UIImage? { nil }
    
    func editorViewController(
        transitioStartPreviewView editorViewController: CropViewController
    ) -> UIView? { nil }
    
    func editorViewController(
        transitioEndPreviewView editorViewController: CropViewController
    ) -> UIView? { nil }
    
    func editorViewController(
        transitioStartPreviewFrame editorViewController: CropViewController
    ) -> CGRect? { nil }
    
    func editorViewController(
        transitioEndPreviewFrame editorViewController: CropViewController
    ) -> CGRect? { nil }
    
    private func back(
        _ editorViewController: CropViewController
    ) {
        if !editorViewController.config.isAutoBack {
            if let navigationController = editorViewController.navigationController,
               navigationController.viewControllers.count > 1 {
                navigationController.popViewController(animated: true)
            }else {
                editorViewController.dismiss(animated: true)
            }
        }
    }
}
 
