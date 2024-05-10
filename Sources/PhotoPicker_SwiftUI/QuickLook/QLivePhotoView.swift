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
public struct QLivePhotoView: View {
    let asset: SelectedAsset
    @State var livePhoto: PHLivePhoto?
    
    public init(asset: SelectedAsset) {
        self.asset = asset
    }
    
    public var body: some View {
        ZStack(alignment: .topLeading) {
            LivePhoto(livePhoto: livePhoto)
                .ss.task {
                    if let _ = livePhoto{}else{
                        await loadAsset()
                    }
                }
            
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
    }
    
    private func loadAsset() async {

        livePhoto = await asset.asset.getLivePhoto()

    }
}
 

struct LivePhoto: UIViewRepresentable {
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