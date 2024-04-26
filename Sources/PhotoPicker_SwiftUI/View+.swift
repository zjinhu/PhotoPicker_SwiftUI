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
                       selected: Binding<[Picture]>) -> some View {
        fullScreenCover(isPresented: isPresented) {
            GalleryPageView(isPresented: isPresented, selected: selected)
                .ignoresSafeArea()
        }
    }
}
