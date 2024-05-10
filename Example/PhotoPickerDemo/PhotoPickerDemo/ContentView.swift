//
//  ContentView.swift
//  Example
//
//  Created by FunWidget on 2024/4/22.
//

import SwiftUI
import PhotoPicker_SwiftUI
import Photos
import PhotosUI

class SelectItem: ObservableObject{
    @Published var pictures: [SelectedAsset] = []
    @Published var selectedIndex = 0
    @Published var selectedAsset: SelectedAsset?
}

struct ContentView: View {
    @State var isPresentedGallery = false
    @State var isPresentedCrop = false

    @State private var showPicker: Bool = false
    @State private var selectedItems: [PHPickerResult] = []
    @State private var selectedImages: [UIImage]?
    
    @StateObject var selectItem = SelectItem()
    
    var body: some View {
        NavigationView{
            
            VStack {
                
                Button {
                    isPresentedGallery.toggle()
                } label: {
                    Text("打开自定义相册")
                        .foregroundColor(Color.red)
                        .frame(height: 50)
                }
                .galleryPicker(isPresented: $isPresentedGallery,
                               maxSelectionCount: 6,
                               cropRatio: 2,
                               onlyImage: false,
                               selected: $selectItem.pictures)
 
                Button {
                    showPicker.toggle()
                } label: {
                    Text("打开系统相册")
                }
                .photoPicker(isPresented: $showPicker,
                             selected: $selectedItems,
                             maxSelectionCount: 5,
                             matching: .any(of: [.images, .livePhotos, .videos]))
                .onChange(of: selectedItems) { newItems in
                    var images = [UIImage]()
                    Task{
                        for item in newItems{
                            if let image = try await item.loadTransfer(type: UIImage.self){
                                images.append(image)
                            }
                        }
                        await MainActor.run {
                            selectedImages = images
                        }
                    }
                }

                List {
                    
                    if let selectedImages {
                        ForEach(selectedImages, id: \.self) { picture in
                            Image(uiImage: picture)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 250, height: 250)
                        }
                    }
 
                    ForEach(Array(selectItem.pictures.enumerated()), id: \.element) { index, picture in
                        
                        
                        Button {

                            selectItem.selectedIndex = index
                            
                            switch picture.fetchPHAssetType(){
                            case .image:
                                if let image = picture.asset.getImage(){
                                    selectItem.selectedAsset = picture
                                    selectItem.selectedAsset?.image = image
                                    isPresentedCrop.toggle()
                                }
                            case .livePhoto, .video:
                                Task{
                                    if let url = await picture.asset.getVideoUrl(){
                                        await MainActor.run{
                                            selectItem.selectedAsset = picture
                                            selectItem.selectedAsset?.videoUrl = url
                                            isPresentedCrop.toggle()
                                        }
                                    }
                                }
                            default: break
                            }
                            
                        } label: {
                            QLImageView(asset: picture)
                        }
                        .tag(index)

                    }
 
                }
                .id(UUID())
            }
        }
        .editPicker(isPresented: $isPresentedCrop,
                   cropRatio: 0.5,
                    asset: selectItem.selectedAsset) { asset in
            selectItem.pictures.replaceSubrange(selectItem.selectedIndex...selectItem.selectedIndex, with: [asset])
        }
    }
}

#Preview {
    ContentView()
}
