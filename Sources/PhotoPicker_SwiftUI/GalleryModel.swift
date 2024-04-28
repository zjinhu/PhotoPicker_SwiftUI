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
    let photoLibrary = PhotoLibraryService()
    @Published var albums: [AlbumItem] = []
    var maxSelectionCount: Int = 0
    @Published var oneSelectedDone: Bool = false
    @Published var closedGallery: Bool = false
    public init() {}

    @Published public var selectedPictures: [Picture] = []
    @Published var selectImages: [UIImage] = []
}

extension GalleryModel {
    public func loadImage(for assetId: String, targetSize: CGSize) async -> UIImage? {
        try? await photoLibrary.loadImage(for: assetId, targetSize: targetSize)
    }

    public func loadAllAlbums() async {
        let albums = await photoLibrary.fetchAllAlbums()
        await MainActor.run {
            withAnimation {
                self.albums = albums
            }
        }
    }
}
