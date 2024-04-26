//
//  ThumbnailView.swift
//  PhotoRooms
//
//  Created by FunWidget on 2024/4/22.
//

import SwiftUI
import BrickKit
import Photos
struct ThumbnailView: View {
    @State var image: UIImage?
    @State var number: Int = 0
    @State var buttonDisable: Bool = false
    
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
                
                if viewModel.maxSelectionCount != 1{
            
                    if number > 0{
                        Color.black
                            .opacity(0.5)
                    }
                    
                    Text(number > 0 ? "\(number)" : "")
                        .font(Font.system(size: 12))
                        .foregroundColor(.white)
                        .frame(width: 20, height: 20)
                        .ss.background{
                            if number > 0{
                                Color.blue
                            }else{
                                Color.black.opacity(0.3)
                                    .ss.border(.white, cornerRadius: 10, lineWidth: 2)
                            }
                        }
                        .clipShape(Circle())
                        .padding(5)
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
                let image = try? await viewModel.photoLibrary.loadImage(for: asset.localIdentifier, targetSize: proxy.size)
                await MainActor.run {
                    self.image = image
                }
            }
            .onDisappear {
                self.image = nil
            }
            .onChange(of: viewModel.selectedPictures) { value in
                getPhotoStatus()
            }
        }
    }
    
    func onTap(){
        if viewModel.maxSelectionCount == 1{
            let picture = Picture(asset: asset)
            viewModel.selectedPictures.append(picture)
            viewModel.oneSelectedDone.toggle()
            return
        }

        if viewModel.selectedPictures.contains(where: { pic in pic.asset == asset }),
           let index = viewModel.selectedPictures.firstIndex(where: { picture in picture.asset == asset}){
            
            viewModel.selectedPictures.remove(at: index)
            
        } else{
            let picture = Picture(asset: asset)
            viewModel.selectedPictures.append(picture)
        }
    }
    
    func getPhotoStatus(){
        
        if viewModel.selectedPictures.contains(where: { picture in picture.asset == asset }){
            let index = viewModel.selectedPictures.firstIndex(where: { picture in picture.asset == asset}) ?? -1
            
            number = index + 1
            
        }else{
            number = 0
            
            if viewModel.selectedPictures.count == viewModel.maxSelectionCount{
                buttonDisable = true
            }else{
                buttonDisable = false
            }
        }
    }
}
