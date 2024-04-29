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
    @State private var image: UIImage? = UIImage(named: "sunflower")!
    @State var isPresentedCrop = false
    
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
                               onlyImage: false,
                               selected: $pictures)
                
                Button {
                    isPresentedCrop.toggle()
                } label: {
                    Text("编辑图片")
                        .foregroundColor(Color.red)
                        .frame(height: 50)
                }
                .imageCrop(isPresented: $isPresentedCrop, image: $image)
                
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
                    
                    ForEach(pictures, id: \.self) { picture in
                        picture.toImageView()
                            .resizable()
                            .scaledToFill()
                            .frame(width: 100, height: 100)
                            .clipped()
                    }
                    
                    Image(uiImage: image!)
                        .resizable()
                        .scaledToFit()
                    
                }
            }
        }
        
    }
}

#Preview {
    ContentView()
}
