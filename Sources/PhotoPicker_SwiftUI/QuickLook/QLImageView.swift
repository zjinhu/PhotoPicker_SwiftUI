//
//  SwiftUIView.swift
//  
//
//  Created by HU on 2024/4/28.
//

import SwiftUI
import Photos
import BrickKit
struct QLImageView: View {
    @EnvironmentObject var previewModel: QuickLookModel
    let asset: SelectedAsset
    @State var image: UIImage?
    var body: some View {
        Image(uiImage: image ?? UIImage())
            .resizable()
            .scaledToFill()
            .ss.task{
                if let _ = image{}else{
                    await loadAsset()
                    previewModel.image = image
                }
                previewModel.selectedMode = .image
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
 
