//
//  SwiftUIView.swift
//  
//
//  Created by HU on 2024/4/28.
//

import SwiftUI
import Photos
import BrickKit
public struct QLImageView: View {
    let asset: SelectedAsset
    @State var image: UIImage?
    
    public init(asset: SelectedAsset) {
        self.asset = asset
    }
    
    public var body: some View {
        Image(uiImage: image ?? UIImage())
            .resizable()
            .scaledToFill()
            .onAppear {
                
                if let _ = image{}else{
                    loadAsset()
                }

            }
    }
    
    private func loadAsset() {
        
        if let ima = asset.image{
            image = ima
            return
        }

        image = asset.asset.getImage()
    }
}
 
