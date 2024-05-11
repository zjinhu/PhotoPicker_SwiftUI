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
    @Published var autoCrop: Bool = false
    @Published var closedGallery: Bool = false
    @Published var isStatic: Bool = false
    @Published var permission: PhotoLibraryPermission = .denied
    @Published var selectedAssets: [SelectedAsset] = []
    @Published var showToast: Bool = false
    @Published var cropRatio: CGSize = .zero
    @Published var selectedAsset: SelectedAsset?
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
        let albums = await photoLibrary.fetchAllAlbums(type: isStatic ? .image : nil)
        await MainActor.run {
            withAnimation {
                self.albums = albums
            }
        }
    }
}
