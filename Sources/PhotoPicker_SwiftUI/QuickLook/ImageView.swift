//
//  SwiftUIView.swift
//  
//
//  Created by FunWidget on 2024/4/28.
//

import SwiftUI
import Photos
import BrickKit
struct ImageView: View {
    let asset: SelectedAsset
    @State var image: UIImage?
    var body: some View {
        Image(uiImage: image ?? UIImage())
            .resizable()
            .scaledToFill()
            .ss.task{
                if let _ = image{}else{
                    await loadAsset()
                }
            }
    }
    
    private func loadAsset() async {
        
        if let ima = asset.cropImage{
            image = ima
            return
        }
        
        do {
            image = try await asset.asset.loadImage()
        } catch {
            print("Error loading video: \(error)")
        }
    }
}
 
