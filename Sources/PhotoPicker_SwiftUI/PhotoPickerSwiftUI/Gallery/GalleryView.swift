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
let gridSpace: CGFloat = 5
let gridSize = (Screen.width - gridSpace * CGFloat(photoColumns)) / CGFloat(photoColumns)

struct GalleryView: View {
    
    @EnvironmentObject var viewModel: GalleryModel
    
    let columns: [GridItem] = [GridItem](repeating: GridItem(.fixed(gridSize), spacing: gridSpace, alignment: .center), count: photoColumns)
    
    var album: AlbumItem
    
    var body: some View {
        
        ScrollView {
            LazyVGrid(columns: columns, spacing: 5) {
                
                if album.count != 0, let array = album.result{
                    ForEach(0..<album.count, id: \.self) { index in
                        
                        ThumbnailView(asset: array[index])
                            .frame(height: gridSize)
                            .id(array[index].localIdentifier)
                            .environmentObject(viewModel)
                        
                    }
                }
                
            }
            .padding(.horizontal , 5)
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
