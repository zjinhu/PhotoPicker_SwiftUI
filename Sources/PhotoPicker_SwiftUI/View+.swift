//
//  SwiftUIView.swift
//
//
//  Created by HU on 2024/4/25.
//

import SwiftUI
import Photos
import PhotosUI

public extension View {
    /// Customize the album to select photos
    /// - Parameters:
    ///   - isPresented: view state
    ///   - maxSelectionCount: Maximum number of selections 最大可选数量
    ///   - selectTitle: selectTitle 设置选中title
    ///   - autoCrop: maxSelectionCount == 1, Auto jump to crop photo 当最大可选数量为1时是否自动跳转裁剪
    ///   - cropRatio: Crop ratio, width height 裁剪比例
    ///   - onlyImage: Select photos only 只选择照片
    ///   - selected: Bind return result
    /// - Returns: description
    @ViewBuilder func galleryPicker(isPresented: Binding<Bool>,
                                    maxSelectionCount: Int = 0,
                                    selectTitle: String? = nil,
                                    autoCrop: Bool = false,
                                    cropRatio: CGSize = .zero,
                                    onlyImage: Bool = false,
                                    selected: Binding<[SelectedAsset]>) -> some View {
        fullScreenCover(isPresented: isPresented) {
            GalleryPageView(maxSelectionCount: maxSelectionCount,
                            selectTitle: selectTitle,
                            autoCrop: autoCrop,
                            cropRatio: cropRatio,
                            onlyImage: onlyImage,
                            selected: selected)
            .ignoresSafeArea()
        }
    }
    /// Customize albums to take screenshots after selecting photos
    /// - Parameters:
    ///   - isPresented: view state 弹窗页面状态
    ///   - cropVideoTime: Set the maximum cropping time 设置最大裁剪时长
    ///   - cropVideoFixTime: Can you manually adjust the cutting duration 是否可以手动调整裁剪时长
    ///   - cropRatio: Crop ratio, width height 设置裁剪比例
    ///   - asset: SelectedAsset 资源文件
    ///   - returnAsset: Return the cropped result 返回修改后的model
    /// - Returns: description
    @ViewBuilder func editPicker(isPresented: Binding<Bool>,
                                 cropVideoTime: TimeInterval = 5,
                                 cropVideoFixTime: Bool = false,
                                 cropRatio: CGSize = .zero,
                                 asset: SelectedAsset?,
                                 returnAsset: @escaping (SelectedAsset) -> Void) -> some View {
        
        fullScreenCover(isPresented: isPresented) {
            if asset != nil {
                EditView(asset: asset!,
                         cropVideoTime: cropVideoTime,
                         cropVideoFixTime: cropVideoFixTime,
                         cropRatio: cropRatio,
                         done: returnAsset)
                .statusBar(hidden: true)
                .ignoresSafeArea()
                
            }else{
                EmptyView()
            }
        }
    }
}
