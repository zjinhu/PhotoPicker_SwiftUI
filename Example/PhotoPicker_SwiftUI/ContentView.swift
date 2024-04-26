//
//  ContentView.swift
//  Example
//
//  Created by FunWidget on 2024/4/22.
//

import SwiftUI
import PhotoPicker_SwiftUI

struct ContentView: View {
    @State var isPresentedGallery = false
    @State var pictures: [Picture] = []
    
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
                               selected: $pictures)
                
                List {
                    ForEach(pictures) { picture in
                        picture.toImage() // You can fix the size by default width: 100, height: 100
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
