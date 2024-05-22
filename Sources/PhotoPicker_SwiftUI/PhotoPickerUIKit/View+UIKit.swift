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

    @ViewBuilder func galleryHostPicker(isPresented: Binding<Bool>,
                                        maxSelectionCount: Int = 0,
                                        selectTitle: String? = nil,
                                        autoCrop: Bool = false,
                                        cropRatio: CGSize = .zero,
                                        onlyImage: Bool = false,
                                        selected: Binding<[SelectedAsset]>) -> some View {
        fullScreenCover(isPresented: isPresented) {
            GalleryPageEntranceView(maxSelectionCount: maxSelectionCount,
                                    selectTitle: selectTitle,
                                    autoCrop: autoCrop,
                                    cropRatio: cropRatio,
                                    onlyImage: onlyImage,
                                    selected: selected)
            .ignoresSafeArea()
        }
    }

}
