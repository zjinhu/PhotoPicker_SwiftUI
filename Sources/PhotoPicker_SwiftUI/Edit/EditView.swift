//
//  SwiftUIView.swift
//
//
//  Created by FunWidget on 2024/5/9.
//

import SwiftUI
import BrickKit
struct EditView: UIViewControllerRepresentable {
    
    @Environment(\.dismiss) private var dismiss
    var cropRatio: CGFloat
    var asset: SelectedAsset
    let done : (SelectedAsset) -> Void
    init(asset: SelectedAsset,
         cropRatio: Double,
         done: @escaping (SelectedAsset) -> Void) {
        self.asset = asset
        self.cropRatio = cropRatio
        self.done = done
    }
    
    var editedResult: EditedResult?
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIViewController(context: Context) -> UIViewController {
        return makeCropper(context: context)
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        
    }
    
    func makeCropper(context: Context) -> UIViewController {
        
        switch asset.assetType {
        case .image:
            let vc = EditorViewController(.init(type: .image(asset.toImage()), result: editedResult), config: .init())
            vc.delegate = context.coordinator
            return vc
        case .livePhoto:
            if let url = asset.getLivePhotoVideoUrl(){
                let vc = EditorViewController(.init(type: .video(url), result: editedResult), config: .init())
                vc.delegate = context.coordinator
                return vc
            }
        case.video:
            if let url = asset.videoUrl{
                let vc = EditorViewController(.init(type: .video(url), result: editedResult), config: .init())
                vc.delegate = context.coordinator
                return vc
            }
        default:
            break
        }
        
        return UIViewController()
    }
    
    class Coordinator: EditorViewControllerDelegate {
        var parent: EditView
        
        init(_ parent: EditView) {
            self.parent = parent
        }
        
        /// 完成编辑
        /// - Parameters:
        ///   - editorViewController: 对应的 EditorViewController
        ///   - result: 编辑后的数据
        func editorViewController(_ editorViewController: EditorViewController,
                                  didFinish asset: EditorAsset) {
            
        }
        
        /// 取消编辑
        /// - Parameter photoEditorViewController: 对应的 PhotoEditorViewController
        func editorViewController(didCancel editorViewController: EditorViewController) {
            
        }
        
    }
}

