//
//  SwiftUIView.swift
//  
//
//  Created by HU on 2024/4/28.
//

import SwiftUI
import PhotosUI
import Photos
import BrickKit
import PhotoPicker_SwiftUI
public struct QLivePhotoView: View {
    let asset: SelectedAsset
    @StateObject var photoModel: LivePhotoViewModel
    
    public init(asset: SelectedAsset) {
        self.asset = asset
        _photoModel = StateObject(wrappedValue: LivePhotoViewModel(asset: asset))
    }
    
    public var body: some View {
        ZStack(alignment: .topLeading) {
            LivePhotoView(livePhoto: photoModel.livePhoto)
 
            HStack{
                Image(systemName: "livephoto")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 16, height: 16)
                Text("实况")
                    .font(.system(size: 14))
            }
            .padding(5)
            .background(.white.opacity(0.7))
            .clipShape(Capsule())
            .padding(10)
        }
        .onAppear{
            if let _ = photoModel.livePhoto{}else{
                loadAsset()
            }
        }
        .onDisappear{
            photoModel.onStop()
        }
    }
    
    private func loadAsset() {
        
        if let ima = asset.editResult?.livePhoto{
            photoModel.livePhoto = ima
            return
        }
        photoModel.loadAsset()
    }
}
 

struct LivePhotoView: UIViewRepresentable {
    var livePhoto: PHLivePhoto?

    func makeUIView(context: Context) -> PHLivePhotoView {
        let livePhotoView = PHLivePhotoView()
        livePhotoView.livePhoto = livePhoto
        return livePhotoView
    }

    func updateUIView(_ uiView: PHLivePhotoView, context: Context) {
        uiView.livePhoto = livePhoto
    }
}
