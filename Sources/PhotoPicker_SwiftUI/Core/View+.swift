//
//  SwiftUIView.swift
//
//
//  Created by FunWidget on 2024/4/25.
//

import SwiftUI
import Photos
public extension View {
    @ViewBuilder
    func galleryPicker(isPresented: Binding<Bool>,
                       maxSelectionCount: Int = 0,
                       onlyImage: Bool = false,
                       selected: Binding<[SelectedAsset]>) -> some View {
        fullScreenCover(isPresented: isPresented) {
            GalleryPageView(maxSelectionCount: maxSelectionCount,
                            onlyImage: onlyImage,
                            selected: selected)
                .ignoresSafeArea()
        }
    }
    
    @ViewBuilder
    func imageCrop(isPresented: Binding<Bool>,
                   image: Binding<UIImage?>) -> some View {
        fullScreenCover(isPresented: isPresented) {
            ImageCropView(image: image)
            .ignoresSafeArea()
        }
    }
}
