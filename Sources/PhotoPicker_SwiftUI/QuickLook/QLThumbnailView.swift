//
//  SwiftUIView.swift
//  
//
//  Created by HU on 2024/4/29.
//

import SwiftUI
import Photos
import BrickKit
struct QLThumbnailView: View {
    let asset: SelectedAsset
    @EnvironmentObject var viewModel: GalleryModel
    @State var time: Double = 0
    @State var image: UIImage?
    var body: some View {
        ZStack(alignment: .bottomLeading){

            Image(uiImage: image ?? UIImage())
                .resizable()
                .scaledToFill()
                .frame(width: 90, height: 90)
                .clipShape(Rectangle())
                .cornerRadius(5)
            
            if asset.asset.mediaSubtypes.contains(.photoLive), viewModel.type != .image{
                
                Image(systemName: "livephoto")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.white)
                    .frame(width: 14, height: 14)
                    .padding(5)
            }
            
            if time != 0, viewModel.type != .image{
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
            if let ima = asset.cropImage{
                image = ima
            }
        }
        .ss.task {
            
            if let _ = image{}else{
                await loadImage()
            }
            
            if asset.asset.mediaType == .video{
                await loadAsset()
            }

        }
    }
    
    private func loadAsset() async {
        do {
            time = try await asset.asset.loadVideoTime()
        } catch {
            print("Error loading video: \(error)")
        }
    }
    
    private func loadImage() async {
            
        do {
            image = try await asset.asset.loadImage()
        } catch {
            print("Error loading video: \(error)")
        }
    }
    
}

