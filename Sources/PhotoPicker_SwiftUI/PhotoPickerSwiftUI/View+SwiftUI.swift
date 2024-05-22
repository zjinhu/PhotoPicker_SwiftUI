//
//  SwiftUIView.swift
//
//
//  Created by HU on 2024/4/25.
//

import SwiftUI
import Photos
import PhotosUI
import PhotoPickerCore
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
}
