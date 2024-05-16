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
    
    var album: AlbumItem
    
    var body: some View {
        
        GeometryReader { proxy in
            
            ScrollView {
                LazyVGrid(columns: columns, spacing: 5) {
                    
                    if album.count != 0, let array = album.result{
                        ForEach(0..<album.count, id: \.self) { index in
                            
                            ThumbnailView(asset: array[index])
                                .frame(height: (proxy.size.width - 5 * CGFloat(photoColumns)) / CGFloat(photoColumns))
                                .id(array[index].localIdentifier)
                                .environmentObject(viewModel)
                            
                        }
                    }
                    
                }
                .padding(.horizontal , 5)
            }
            
        }      
        .onAppear {
            let fetchOptions = PHFetchOptions()
            fetchOptions.includeHiddenAssets = false
            
            if viewModel.isStatic {
                fetchOptions.predicate = NSPredicate(format: "mediaType == %d", PHAssetMediaType.image.rawValue)
            }
            
            fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            album.fetchResult(options: fetchOptions)
        }
        
    }
}
