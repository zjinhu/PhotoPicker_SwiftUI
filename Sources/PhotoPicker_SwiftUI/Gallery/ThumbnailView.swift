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

    @State var number: Int = 0
    @State var buttonDisable: Bool = false
    @StateObject var photoModel: PhotoViewModel
    @EnvironmentObject var viewModel: GalleryModel
    @StateObject var selected = NowAsset()
    @State private var isNavigationActive = false
    let asset: PHAsset
    
    init(asset: PHAsset) {
        self.asset = asset
        _photoModel = StateObject(wrappedValue: PhotoViewModel(asset: asset))
    }
    
    var body: some View {
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
                .ss.overlay(alignment: .topLeading) {
                    if asset.mediaSubtypes.contains(.photoLive), !viewModel.isStatic{
                        
                        Image(systemName: "livephoto")
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(.white)
                            .frame(width: 22, height: 22)
                            .padding(5)
                        
                    }
                }
                .ss.overlay(alignment: .bottomLeading) {
                    if let time = photoModel.time{
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
                .ss.overlay{
                    if number > 0{
                        Color.black
                            .opacity(0.5)
                    }
                }
                .ss.overlay(alignment: .topTrailing) {
                    if viewModel.maxSelectionCount != 1{
    
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
                .ss.overlay{
                    if viewModel.autoCrop, viewModel.maxSelectionCount == 1{
                        NavigationLink(isActive: $isNavigationActive) {
                            if let selectedAsset = selected.selectedAsset{
                                EditView(asset: selectedAsset,
                                         cropRatio: viewModel.cropRatio){ replace in
                                    viewModel.selectedAssets.append(replace)
                                    viewModel.oneSelectedDone.toggle()
                                }
                                         .ignoresSafeArea()
                            }
                        } label: {
                            EmptyView()
                        }
                        
                        Button {
                            let selectItem = SelectedAsset(asset: asset)
                            
                            if selectItem.fetchPHAssetType() == .image, let image = asset.toImage(){
                                selected.selectedAsset = selectItem
                                selected.selectedAsset?.image = image
                                isNavigationActive = true
                            }
                            
                            if selectItem.fetchPHAssetType() == .livePhoto || selectItem.fetchPHAssetType() == .video{
                                Task{
                                    if let url = await asset.getVideoUrl(){
                                        await MainActor.run{
                                            selected.selectedAsset = selectItem
                                            selected.selectedAsset?.videoUrl = url
                                            isNavigationActive = true
                                        }
                                    }
                                }
                            }
                            
                        } label: {
                            Color.clear
                                .frame(width: proxy.size.width, height: proxy.size.height)
                        }
                        
                    }else{
                        Rectangle()
                            .foregroundColor(Color.white.opacity(buttonDisable ? 0.5 : 0.00001))
                            .contentShape(Rectangle())
                            .onTapGesture {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    if self.buttonDisable{
                                        self.viewModel.showToast.toggle()
                                    }else{
                                        self.onTap()
                                    }
                                }
                            }
                    }
                }
                .ss.task {
                    await photoModel.onStart()
                }
                .onAppear{
                    if let _ = photoModel.image{ }else{
                        photoModel.loadImage(size: proxy.size)
                    }
                    getPhotoStatus()
                }
                .onDisappear {
                    photoModel.onStop()
                }
                .onChange(of: viewModel.selectedAssets) { value in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        self.getPhotoStatus()
                    }
                }
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


class NowAsset: ObservableObject{
    
    @Published var selectedAsset: SelectedAsset?
}
