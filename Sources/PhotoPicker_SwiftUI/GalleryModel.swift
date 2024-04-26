//
//  GalleryViewModel.swift
//  PhotoRooms
//
//  Created by FunWidget on 2024/4/23.
//

import Foundation
import Photos
import SwiftUI

public class GalleryModel: ObservableObject {
    public let photoLibrary = PhotoLibraryService()
//    private var subscribers: [AnyCancellable] = []
    
    public init() {

//        photoLibrary.$photoLibraryChange
//            .receive(on: DispatchQueue.main)
//            .sink { change in
//                self.bindLibraryUpdate(change: change)
//            }
//            .store(in: &subscribers)
    }
    
//    @Published public var results = PHFetchResult<PHAsset>()
    @Published public var albums : [AlbumItem] = []
    @Published public var selectedPictures: [Picture] = []
}

//extension GalleryModel {
//    private func bindLibraryUpdate(change: PHChange?) {
//        if let changes = change?.changeDetails(for: results) {
//            withAnimation {
//                results = changes.fetchResultAfterChanges
//            }
//        }
//    }
//}

extension GalleryModel {
    public func loadImage(for assetId: String, targetSize: CGSize) async -> UIImage? {
        try? await photoLibrary.loadImage(for: assetId, targetSize: targetSize)
    }
    
//    public func loadAllPhotos() async {
//        let results = await photoLibrary.fetchAllPhotos()
//        print("zhixing:\(results)")
//        await MainActor.run {
//            withAnimation {
//                self.results = results
//            }
//        }
//    }
    
    public func loadAllAlbums() async {
        let albums = await photoLibrary.fetchAllAlbums()
        await MainActor.run {
            withAnimation {
                self.albums = albums
            }
        }
    }
}
