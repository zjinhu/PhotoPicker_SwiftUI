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
                   asset: SelectedAsset?,
                   returnAsset: @escaping (SelectedAsset) -> Void) -> some View {
       
        fullScreenCover(isPresented: isPresented) {
            if let asset{
                ImageCropView(asset: asset, done: returnAsset)
                    .ignoresSafeArea()
            }else{
                EmptyView()
            }
        }
    }
}
