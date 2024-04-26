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
    @State var pictures: [Picture] = []
    
    var body: some View {
        NavigationView{
            
            VStack {
                
//                Button {
//                    isPresentedGallery.toggle()
//                } label: {
//                    Text("打开自定义相册,无限制")
//                        .foregroundColor(Color.red)
//                        .frame(height: 50)
//                }
//                .galleryPicker(isPresented: $isPresentedGallery,
//                               selected: $pictures)
                
//                Button {
//                    isPresentedGallery.toggle()
//                } label: {
//                    Text("打开自定义相册,选择一张")
//                        .foregroundColor(Color.red)
//                        .frame(height: 50)
//                }
//                .galleryPicker(isPresented: $isPresentedGallery,
//                               maxSelectionCount: 1,
//                               selected: $pictures)
                
                Button {
                    isPresentedGallery.toggle()
                } label: {
                    Text("打开自定义相册,选择3张")
                        .foregroundColor(Color.red)
                        .frame(height: 50)
                }
                .galleryPicker(isPresented: $isPresentedGallery,
                               maxSelectionCount: 3,
                               selected: $pictures)
                
                List {
                    ForEach(pictures) { picture in
                        picture.toImage(size: CGSize(width: 100, height: 100)) 
                    }
                }
            }
        }

    }
}

#Preview {
    ContentView()
}
