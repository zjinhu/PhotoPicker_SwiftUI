//
//  GalleryViewModel.swift
//  PhotoRooms
//
//  Created by HU on 2024/4/23.
//

import Foundation
import Photos
import SwiftUI

class GalleryModel: ObservableObject {
    let photoLibrary = PhotoLibraryService()
    @Published var albums: [AlbumItem] = []
    var maxSelectionCount: Int = 0
    @Published var oneSelectedDone: Bool = false
    @Published var closedGallery: Bool = false
    @Published var type: PHAssetMediaType?
    @Published var permission: PhotoLibraryPermission = .denied
    @Published var selectedAssets: [SelectedAsset] = []
    
    init() {
 
        switch photoLibrary.photoLibraryPermissionStatus {
        case .restricted, .limited:
            permission = .limited
        case .authorized:
            permission = .authorized
        default:
            permission = .denied
            Task{
                await photoLibrary.requestPhotoLibraryPermission()
            }
        }
    }
    
    enum PhotoLibraryPermission {
        case denied
        case limited
        case authorized
    }
}

extension GalleryModel {
    public func loadImage(for assetId: String, targetSize: CGSize) async -> UIImage? {
        try? await photoLibrary.loadImage(for: assetId, targetSize: targetSize)
    }

    public func loadAllAlbums() async {
        let albums = await photoLibrary.fetchAllAlbums(type: type)
        await MainActor.run {
            withAnimation {
                self.albums = albums
            }
        }
    }
}
