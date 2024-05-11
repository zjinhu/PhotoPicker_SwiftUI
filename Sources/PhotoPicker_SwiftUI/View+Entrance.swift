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
    ///   - maxSelectionCount: Maximum number of selections
    ///   - autoCrop: maxSelectionCount == 1, Auto jump to crop photo
    ///   - cropRatio: Crop ratio, width height
    ///   - onlyImage: Select photos only
    ///   - selected: Bind return result
    /// - Returns: description
    @ViewBuilder func galleryPicker(isPresented: Binding<Bool>,
                                    maxSelectionCount: Int = 0,
                                    autoCrop: Bool = false,
                                    cropRatio: CGSize = .zero,
                                    onlyImage: Bool = false,
                                    selected: Binding<[SelectedAsset]>) -> some View {
        fullScreenCover(isPresented: isPresented) {
            GalleryPageView(maxSelectionCount: maxSelectionCount,
                            autoCrop: autoCrop,
                            cropRatio: cropRatio,
                            onlyImage: onlyImage,
                            selected: selected)
            .ignoresSafeArea()
        }
    }
    
    /// Customize albums to take screenshots after selecting photos
    /// - Parameters:
    ///   - isPresented: view state
    ///   - cropRatio: Crop ratio, width divided by height
    ///   - asset: SelectedAsset
    ///   - returnAsset: Return the cropped result
    /// - Returns: description
    @ViewBuilder func editPicker(isPresented: Binding<Bool>,
                                cropRatio: CGSize = .zero,
                                asset: SelectedAsset?,
                                returnAsset: @escaping (SelectedAsset) -> Void) -> some View {
        
        fullScreenCover(isPresented: isPresented) {
            if let asset {
                EditView(asset: asset,
                         cropRatio: cropRatio,
                         done: returnAsset)
                .ignoresSafeArea()
            }else{
                EmptyView()
            }
        }
    }
}

public extension View {
    
    //System album selection of a single photo
    func photoPicker(
        isPresented: Binding<Bool>,
        selected: Binding<PHPickerResult?>,
        matching filter: PHPickerFilter? = nil,
        preferredAssetRepresentationMode: PHPickerConfiguration.AssetRepresentationMode = .automatic,
        photoLibrary: PHPhotoLibrary = .shared()
    ) -> some View {
        let binding = Binding(
            get: {
                [selected.wrappedValue].compactMap { $0 }
            },
            set: { newValue in
                selected.wrappedValue = newValue.first
            }
        )
        return photoPicker(
            isPresented: isPresented,
            selected: binding,
            maxSelectionCount: 1,
            matching: filter,
            preferredAssetRepresentationMode: preferredAssetRepresentationMode,
            photoLibrary: photoLibrary
        )
    }
    
    //System Album to select multiple photos
    func photoPicker(
        isPresented: Binding<Bool>,
        selected: Binding<[PHPickerResult]>,
        maxSelectionCount: Int? = nil,
        matching filter: PHPickerFilter? = nil,
        preferredAssetRepresentationMode: PHPickerConfiguration.AssetRepresentationMode = .automatic,
        photoLibrary: PHPhotoLibrary = .shared()
    ) -> some View {
        _photoPicker(
            isPresented: isPresented,
            selected: selected,
            filter: filter,
            maxSelectionCount: maxSelectionCount,
            preferredAssetRepresentationMode: preferredAssetRepresentationMode,
            library: photoLibrary
        )
    }
}
