//
//  GalleryView.swift
//  PhotoRooms
//
//  Created by HU on 2024/4/22.
//

import Photos
import SwiftUI
import BrickKit

let photoColumns: Int = 4
struct GalleryView: View {
    
    @EnvironmentObject var viewModel: GalleryModel
    
    var columns: [GridItem] = [GridItem](repeating: GridItem(.flexible(), spacing: 5, alignment: .center), count: photoColumns)
    
    var results: PHFetchResult<PHAsset>
    
    var body: some View {
        
        GeometryReader { proxy in
            
            ScrollView {
                LazyVGrid(columns: columns, spacing: 5) {
                    
                    ForEach(0..<results.count, id: \.self) { index in
                        
                        ThumbnailView(asset: results[index])
                            .frame(height: (proxy.size.width - 5 * CGFloat(photoColumns)) / CGFloat(photoColumns))
                            .id(results[index].localIdentifier)
                            .environmentObject(viewModel)
                        
                    }
                    
                }
                .padding(.horizontal , 5)
            }
            
        }
        
    }
}
