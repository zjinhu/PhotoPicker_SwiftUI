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
                       selected: Binding<[Picture]>) -> some View {
        fullScreenCover(isPresented: isPresented) {
            GalleryPageView(isPresented: isPresented,
                            maxSelectionCount: maxSelectionCount,
                            selected: selected)
                .ignoresSafeArea()
        }
    }
}
