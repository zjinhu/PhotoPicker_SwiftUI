//
//  ContentView.swift
//  Example
//
//  Created by HU on 2024/4/22.
//

import SwiftUI
import PhotoPicker_SwiftUI
import Photos
import PhotosUI
import BrickKit

class SelectItem: ObservableObject{
    @Published var pictures: [SelectedAsset] = []
    @Published var selectedIndex = 0
    @Published var selectedAsset: SelectedAsset?
}

struct ContentView: View {
    @State var isPresentedGallery = false
 
    @StateObject var selectItem = SelectItem()

    var body: some View {
        NavigationView{
            
            VStack {
 
                Button {
                    isPresentedGallery.toggle()
                } label: {
                    Text("打开自定义相册SwiftUI")
                        .foregroundColor(Color.red)
                        .frame(height: 50)
                }
                .galleryPicker(isPresented: $isPresentedGallery,
                               maxSelectionCount: 5,
                               onlyImage: false,
                               selected: $selectItem.pictures)
                

                List {
 
                    ForEach(Array(selectItem.pictures.enumerated()), id: \.element) { index, picture in
 
                            switch picture.fetchPHAssetType(){
                            case .gif:
                                QLGifView(asset: picture)
                            case .livePhoto:
                                QLivePhotoView(asset: picture)
                                    .frame(height: Screen.width)
                            case .video:
                                QLVideoView(asset: picture)
                                    .frame(height: 200)
                            default:
                                QLImageView(asset: picture)
                            }
 
                    }
                    
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
