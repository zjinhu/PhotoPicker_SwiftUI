//
//  SwiftUIView.swift
//  
//
//  Created by HU on 2024/4/29.
//

import SwiftUI
import Photos
import BrickKit
public struct QLThumbnailView: View {
    let asset: SelectedAsset
    let isStatic: Bool
    @State var time: Double = 0
    @State var image: UIImage?
    
    public init(asset: SelectedAsset, isStatic: Bool = false) {
        self.asset = asset
        self.isStatic = isStatic
    }
    
    public var body: some View {
        ZStack(alignment: .bottomLeading){

            Image(uiImage: image ?? UIImage())
                .resizable()
                .scaledToFill()
                .frame(width: 90, height: 90)
                .clipShape(Rectangle())
                .cornerRadius(5)
            
            if asset.asset.mediaSubtypes.contains(.photoLive), !isStatic{
                
                Image(systemName: "livephoto")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.white)
                    .frame(width: 14, height: 14)
                    .padding(5)
            }
            
            if time != 0, !isStatic{
                HStack{
                    Image(systemName: "video")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 14, height: 14)
                    
                    Text(time.formatDuration())
                        .font(.system(size: 12))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
            }
        }
        .ss.task {
            await loadAsset()
        }
    }
    
    private func loadAsset() async {
        
        if asset.asset.mediaType == .video{
            time = await asset.asset.getVideoTime()
        }

        if let _ = image{}else{
            image = asset.asset.getImage()
        }

    }
}

