//
//  SwiftUIView.swift
//  
//
//  Created by HU on 2024/4/29.
//

import SwiftUI
import Photos
import BrickKit
import PhotoPicker_SwiftUI
public struct QLThumbnailView: View {
    let asset: SelectedAsset
    let index: Int
    @StateObject var photoModel: PhotoViewModel
    @EnvironmentObject var viewModel: GalleryModel
    
    public init(asset: SelectedAsset, index: Int) {
        self.asset = asset
        self.index = index
        _photoModel = StateObject(wrappedValue: PhotoViewModel(asset: asset))
    }
    
    public var body: some View {
        GeometryReader { proxy in
            Rectangle()
                .foregroundColor(Color.gray.opacity(0.3))
                .ss.overlay{
                    if let image = photoModel.image {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: proxy.size.width, height: proxy.size.height)
                            .clipped()
                            .allowsHitTesting(false)
                    }
                }
                .ss.overlay(alignment: .bottomLeading) {
                    if asset.asset.mediaSubtypes.contains(.photoLive), !asset.isStatic{
                        
                        Image(systemName: "livephoto")
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(.white)
                            .frame(width: 22, height: 22)
                            .padding(5)
                        
                    }
                }
                .ss.overlay(alignment: .bottomTrailing) {
                    if asset.asset.isGIF(), !asset.isStatic{
                        Text("GIF")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white)
                            .padding(.vertical, 5)
                            .background(.black.opacity(0.4))
                            .cornerRadius(5)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                    }
                }
                .ss.overlay(alignment: .bottomLeading) {
                    if let time = photoModel.time, !asset.isStatic{
                        HStack{
                            Image(systemName: "video")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 14, height: 14)
                            
                            Text(time.formatDuration())
                                .font(.system(size: 12))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                    }
                }
                .onAppear{
                    if let _ = photoModel.image{ }else{
                        photoModel.loadImage(size: proxy.size)
                    }
                }
                .onDisappear {
                    photoModel.onStop()
                }
                .task {
                    await photoModel.onStart()
                }
                .ss.border(viewModel.previewSelectIndex == index ? .mainBlue : .clear, cornerRadius: 5, lineWidth: 2)

        }
    }
}

