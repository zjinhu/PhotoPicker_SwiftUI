//
//  SwiftUIView.swift
//
//
//  Created by FunWidget on 2024/4/25.
//

import SwiftUI

public extension View {
    @ViewBuilder
    func galleryPicker(isPresented: Binding<Bool>,
                       maxSelectionCount: Int = 0,
                       selected: Binding<[UIImage]>) -> some View {
        fullScreenCover(isPresented: isPresented) {
            GalleryPageView(maxSelectionCount: maxSelectionCount,
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
