//
//  ThumbnailView.swift
//  PhotoRooms
//
//  Created by HU on 2024/4/22.
//

import SwiftUI
import BrickKit
import Photos
struct ThumbnailView: View {
    @State var image: UIImage?
    @State var number: Int = 0
    @State var buttonDisable: Bool = false
    @State var time: Double = 0
    @EnvironmentObject var viewModel: GalleryModel
    
    let asset: PHAsset
    
    init(asset: PHAsset) {
        self.asset = asset
    }
    
    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .topLeading) {
                if let image {
                    
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: proxy.size.width, height: proxy.size.height)
                        .clipped()
                    
                } else {
                    Color.gray
                        .opacity(0.3)
                }
                
                if asset.mediaSubtypes.contains(.photoLive), viewModel.type != .image{
                    
                    Image(systemName: "livephoto")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(.white)
                        .frame(width: 22, height: 22)
                        .padding(5)
                    
                }
                
                if time != 0{
                    VStack{
                        Spacer()
                        
                        HStack{
                            Image(systemName: "video")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 14, height: 14)
                            
                            Text(time.formatDuration())
                                .font(.system(size: 12))
                        }
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                }
                
                if viewModel.maxSelectionCount != 1{
                    
                    if number > 0{
                        Color.black
                            .opacity(0.5)
                    }
                    HStack{
                        Spacer()
                        Text(number > 0 ? "\(number)" : "")
                            .font(Font.f12)
                            .foregroundColor(.white)
                            .frame(width: 22, height: 22)
                            .ss.background{
                                if number > 0{
                                    Color.mainBlue
                                }else{
                                    Color.black.opacity(0.2)
                                }
                            }
                            .clipShape(Circle())
                            .ss.border(.white, cornerRadius: 10, lineWidth: 2)
                            .padding(5)
                    }
                }
                
                Button {
                    onTap()
                } label: {
                    if buttonDisable{
                        Color.white.opacity(0.5)
                            .frame(width: proxy.size.width, height: proxy.size.height)
                    }else{
                        Color.clear
                            .frame(width: proxy.size.width, height: proxy.size.height)
                    }
                }
                .disabled(buttonDisable)
                
            }
            .ss.task {
                if asset.mediaType == .video{
                    await loadAsset()
                }
                let image = try? await viewModel.photoLibrary.loadImage(for: asset.localIdentifier, targetSize: proxy.size)
                await MainActor.run {
                    self.image = image
                }
            }
            .onDisappear {
                self.image = nil
            }
            .onChange(of: viewModel.selectedAssets) { value in
                getPhotoStatus()
            }
        }
    }
    
    private func loadAsset() async {
        do {
            time = try await asset.loadVideoTime()
        } catch {
            print("Error loading video: \(error)")
        }
    }
    
    func onTap(){
        if viewModel.maxSelectionCount == 1{
            let picture = SelectedAsset(asset: asset)
            viewModel.selectedAssets.append(picture)
            viewModel.oneSelectedDone.toggle()
            return
        }
        
        if viewModel.selectedAssets.contains(where: { pic in pic.asset == asset }),
           let index = viewModel.selectedAssets.firstIndex(where: { picture in picture.asset == asset}){
            
            viewModel.selectedAssets.remove(at: index)
            
        } else{
            let picture = SelectedAsset(asset: asset)
            viewModel.selectedAssets.append(picture)
        }
    }
    
    func getPhotoStatus(){
        
        if viewModel.selectedAssets.contains(where: { picture in picture.asset == asset }){
            let index = viewModel.selectedAssets.firstIndex(where: { picture in picture.asset == asset}) ?? -1
            
            number = index + 1
            
        }else{
            number = 0
            
            if viewModel.selectedAssets.count == viewModel.maxSelectionCount{
                buttonDisable = true
            }else{
                buttonDisable = false
            }
        }
    }
}
