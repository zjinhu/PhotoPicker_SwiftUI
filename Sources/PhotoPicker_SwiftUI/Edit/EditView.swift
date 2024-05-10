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
    var selectedAsset: SelectedAsset
    var editDone: (SelectedAsset) -> Void
    init(asset: SelectedAsset,
         cropRatio: Double,
         done: @escaping (SelectedAsset) -> Void) {
        self.selectedAsset = asset
        self.cropRatio = cropRatio
        self.editDone = done
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIViewController(context: Context) -> UIViewController {
        return makeCropper(context: context)
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        
    }
    
    func makeCropper(context: Context) -> UIViewController {

            if let image = selectedAsset.image,
                selectedAsset.assetType == .image{
                let vc = EditorViewController(.init(type: .image(image)), config: .init())
                vc.delegate = context.coordinator
                return vc
            }

            if let videoUrl = selectedAsset.videoUrl,
                (selectedAsset.assetType == .video || selectedAsset.assetType == .livePhoto){
                let vc = EditorViewController(.init(type: .video(videoUrl)), config: .init())
                vc.delegate = context.coordinator
                return vc
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
            switch parent.selectedAsset.assetType {
            case .image:
                parent.selectedAsset.image = asset.result?.image
            case .livePhoto:
                parent.selectedAsset.image = asset.result?.image
                parent.selectedAsset.videoUrl = asset.result?.url
            case.video:
                parent.selectedAsset.image = asset.result?.image
                parent.selectedAsset.videoUrl = asset.result?.url
            default:
                break
            }
            parent.editDone(parent.selectedAsset)
            parent.dismiss()
        }
        
        func editorViewController(didCancel editorViewController: EditorViewController) {
            parent.dismiss()
        }
        
    }
}

