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
                
                Text(number > 0 ? "\(number)" : "")
                    .foregroundColor(.white)
                    .frame(width: 20, height: 20)
                    .ss.background{
                        Color.blue
                    }
                    .clipShape(Circle())
                    .padding(5)
                
            }
            .ss.task {
                let image = try? await viewModel.photoLibrary.loadImage(for: asset.localIdentifier, targetSize: proxy.size)
                await MainActor.run {
                    self.image = image
                    getNumber()
                }
            }
            .onDisappear {
                self.image = nil
            }
            .onTapGesture {
                
                if viewModel.selectedPictures.contains(where: { pic in pic.asset == asset }),
                   let index = viewModel.selectedPictures.firstIndex(where: { picture in picture.asset == asset}){
                    
                    viewModel.selectedPictures.remove(at: index)
                    
                } else{
                    let picture = Picture(asset: asset)
                    viewModel.selectedPictures.append(picture)
                }
                
                getNumber()
            }
            .onChange(of: viewModel.selectedPictures) { value in
                getNumber()
            }
        }
    }
    
    func getNumber(){
        if viewModel.selectedPictures.contains(where: { picture in picture.asset == asset }){
            let index = viewModel.selectedPictures.firstIndex(where: { picture in picture.asset == asset}) ?? -1
            
            number = index + 1
        }else{
            number = 0
        }
    }
}
