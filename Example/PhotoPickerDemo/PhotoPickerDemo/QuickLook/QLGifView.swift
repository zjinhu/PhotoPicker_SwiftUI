//
//  SwiftUIView.swift
//
//
//  Created by FunWidget on 2024/5/23.
//

import SwiftUI
import Photos
import BrickKit
import PhotoPicker_SwiftUI
public struct QLGifView: View {
    let asset: SelectedAsset
    @StateObject var gifModel: GifViewModel
 
    public init(asset: SelectedAsset) {
        self.asset = asset
        _gifModel = StateObject(wrappedValue: GifViewModel(asset: asset))
    }
    
    public var body: some View {
        VStack{
            if let data = gifModel.imageData{
                GifImage(data: data)
            }
        }
        .onAppear{
            if let _ = gifModel.imageData{}else{
                loadAsset()
            }
        }
        .onDisappear{
            gifModel.onStop()
        }
    }
    
    private func loadAsset() {
        if let data = asset.editResult?.gifData{
            gifModel.imageData = data
        }else{
            gifModel.loadImageData()
        }
    }
}

