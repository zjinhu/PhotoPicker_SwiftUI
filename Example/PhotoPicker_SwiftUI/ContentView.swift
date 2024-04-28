//
//  ContentView.swift
//  Example
//
//  Created by FunWidget on 2024/4/22.
//

import SwiftUI
import PhotoPicker_SwiftUI
import Photos
struct ContentView: View {
    @State var isPresentedGallery = false
    @State var pictures: [UIImage] = []
    @State private var image: UIImage? = UIImage(named: "sunflower")!
    @State var isPresentedCrop = false
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
                               maxSelectionCount: 5,
                               selected: $pictures)
                
                Button {
                    isPresentedCrop.toggle()
                } label: {
                    Text("编辑图片")
                        .foregroundColor(Color.red)
                        .frame(height: 50)
                }
                .imageCrop(isPresented: $isPresentedCrop, image: $image)
                
                List {
                    Image(uiImage: image!)
                        .resizable()
                        .scaledToFit()
                    ForEach(pictures, id: \.self) { picture in
                        Image(uiImage: picture)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 100, height: 100)
                            .clipped()
                    }
                }
            }
        }

    }
}

#Preview {
    ContentView()
}
