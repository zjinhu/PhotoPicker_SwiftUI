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
struct ContentView: View {
    @State var isPresentedGallery = false
    @State var pictures: [SelectedAsset] = []
    
    @State var isPresentedCrop = false
    @State private var selectedIndex = 0
    @State var selectedAsset: SelectedAsset?
    
    @State private var showPicker: Bool = false
    @State private var selectedItems: [PHPickerResult] = []
    @State private var selectedImages: [UIImage]?
    
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
                               onlyImage: true,
                               selected: $pictures)
 
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
                    
                    ForEach(Array(pictures.enumerated()), id: \.element) { index, picture in
                        
                        Button {
                            selectedIndex = index
                            selectedAsset = picture
                            isPresentedCrop.toggle()
                        } label: {
                            Image(uiImage: picture.cropImage ?? picture.toImage())
                                .resizable()
                                .scaledToFill()
                                .frame(width: 100, height: 100)
                                .clipped()
                        }

                    }
 
                }
                .id(UUID())
            }
        }
        .imageCrop(isPresented: $isPresentedCrop, asset: selectedAsset) { asset in
            pictures.replaceSubrange(selectedIndex...selectedIndex, with: [asset])
        }
    }
}

#Preview {
    ContentView()
}
