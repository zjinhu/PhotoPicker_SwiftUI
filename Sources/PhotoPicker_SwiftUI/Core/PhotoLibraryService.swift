//
//  PhotoLibraryService.swift
//  PhotoRooms
//
//  Created by FunWidget on 2024/4/22.
//

import SwiftUI
import Photos
 
class PhotoLibraryService: NSObject {
    let photoLibrary: PHPhotoLibrary
    let imageCachingManager = PHCachingImageManager()
    
    @Published var photoLibraryChange : PHChange?
    
    override init() {
        
        self.photoLibrary = .shared()
        super.init()
        self.photoLibrary.register(self)
        
        switch photoLibraryPermissionStatus {

        case .denied, .notDetermined, .restricted, .limited:
            Task{
                await requestPhotoLibraryPermission()
            }
        case .authorized:
            break
        @unknown default:
            break
        }
    }
}

extension PhotoLibraryService {
    func fetchAllAlbums(type: PHAssetMediaType?) async -> [AlbumItem] {
        if photoLibraryPermissionStatus != .authorized {
            return []
        }
        
        var albums : [AlbumItem] = []
        // 列出所有系统的智能相册
        let smartOptions = PHFetchOptions()
        let smartAlbums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum,
                                                                  subtype: .albumRegular,
                                                                  options: smartOptions)
        
        let userCollections = PHCollectionList.fetchTopLevelUserCollections(with: nil)
        as! PHFetchResult<PHAssetCollection>
        
        for i in 0..<smartAlbums.count{
            let assetCollection = smartAlbums.object(at: i)
            await albums.append(contentsOf: fetchAlbumsPhotos(collection: assetCollection, type: type))
        }
   
        for i in 0..<userCollections.count{
            let assetCollection = userCollections.object(at: i)
            await albums.append(contentsOf: fetchAlbumsPhotos(collection: assetCollection, type: type))
        }
        
        albums.sort { (item1, item2) -> Bool in
            return item1.fetchResult.count > item2.fetchResult.count
        }
        return albums
    }

    func fetchAlbumsPhotos(collection: PHAssetCollection, type: PHAssetMediaType?) async -> [AlbumItem] {

        await withCheckedContinuation { (continuation: CheckedContinuation<[AlbumItem], Never>) in
            
            var items : [AlbumItem] = []
            if collection.isKind(of: PHCollectionList.self){
                continuation.resume(returning: items)
            }else{
                imageCachingManager.allowsCachingHighQualityImages = false
                let fetchOptions = PHFetchOptions()
                fetchOptions.includeHiddenAssets = false
                
                if let type {
                    fetchOptions.predicate = NSPredicate(format: "mediaType == %d", type.rawValue)
                }
                
                fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
                let assetsFetchResult = PHAsset.fetchAssets(in: collection , options: fetchOptions)
                if assetsFetchResult.count > 0{
                    let title = titleOfAlbumForChinse(title: collection.localizedTitle)
                    items.append(AlbumItem(title: title, fetchResult: assetsFetchResult))
                }
                continuation.resume(returning: items)
            }
        }
    }

    
    //由于系统返回的相册集名称为英文，我们需要转换为中文
    private func titleOfAlbumForChinse(title: String?) -> String? {
        switch title {
        case "Slo-mo":
            "慢动作"
        case "Recents":
            "最近项目"
        case "Recently Added":
            "最近添加"
        case "Favorites":
            "个人收藏"
        case "Recently Deleted":
            "最近删除"
        case "Live Photos":
            "实况照片"
        case "Videos":
            "视频"
        case "All Photos":
            "所有照片"
        case "Selfies":
            "自拍"
        case "Screenshots":
            "屏幕快照"
        case "Camera Roll":
            "相机胶卷"
        default:
            title
        }
    }
 
    func loadImage(for localId: String, targetSize: CGSize = PHImageManagerMaximumSize, contentMode: PHImageContentMode = .default) async throws -> UIImage? {
        let results = PHAsset.fetchAssets(withLocalIdentifiers: [localId], options: nil)
        guard let asset = results.firstObject else {
            throw PhotoLibraryError.photoNotFound
        }
        let options = PHImageRequestOptions()
        options.deliveryMode = .opportunistic
        options.resizeMode = .fast
        options.isNetworkAccessAllowed = true
        options.isSynchronous = true
        return try await withCheckedThrowingContinuation { [unowned self] continuation in
            imageCachingManager.requestImage(for: asset,
                                             targetSize: targetSize,
                                             contentMode: contentMode,
                                             options: options,
                                             resultHandler: { image, info in
                if let error = info?[PHImageErrorKey] as? Error {
                    continuation.resume(throwing: error)
                    return
                }
                continuation.resume(returning: image)
            })
        }
    }
}

extension PhotoLibraryService {
    func savePhoto(for photoData: Data, withLivePhotoURL url: URL? = nil) async throws {
        guard photoLibraryPermissionStatus == .authorized else {
            throw PhotoLibraryError.photoLibraryDenied
        }
        
        do {
            try await photoLibrary.performChanges {
                let createRequest = PHAssetCreationRequest.forAsset()
                createRequest.addResource(with: .photo, data: photoData, options: nil)
                if let url {
                    let options = PHAssetResourceCreationOptions()
                    options.shouldMoveFile = true
                    createRequest.addResource(with: .pairedVideo, fileURL: url, options: options)
                }
            }
        } catch {
            throw PhotoLibraryError.photoSavingFailed
        }
    }
}

extension PhotoLibraryService {
    var photoLibraryPermissionStatus: PHAuthorizationStatus {
        PHPhotoLibrary.authorizationStatus(for: .readWrite)
    }
    
    func requestPhotoLibraryPermission() async -> PHAuthorizationStatus  {
        await PHPhotoLibrary.requestAuthorization(for: .readWrite)
    }
}

extension PhotoLibraryService: PHPhotoLibraryChangeObserver {
    public func photoLibraryDidChange(_ changeInstance: PHChange) {
        photoLibraryChange = changeInstance
    }
}

enum PhotoLibraryError: LocalizedError {
    case photoNotFound
    case photoSavingFailed
    case photoLibraryDenied
    case photoLoadingFailed
    case unknownError
}

extension PhotoLibraryError {
    var errorDescription: String? {
        switch self {
        case .photoNotFound:
            return "Photo Not Found"
        case .photoSavingFailed:
            return "Photo Saving Failed"
        case .photoLibraryDenied:
            return "Photo Library Access Denied"
        case .photoLoadingFailed:
            return "Photo Loading Failed"
        case .unknownError:
            return "Unknown Error"
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .photoNotFound:
            return "The photo is not found in the photo library."
        case .photoSavingFailed:
            return "Oops! There is an error occurred while saving a photo into the photo library."
        case .photoLibraryDenied:
            return "You need to allow the photo library access to save pictures you captured. Go to Settings and enable the photo library permission."
        case .photoLoadingFailed:
            return "Oops! There is an error occurred while loading a photo from the photo library."
        case .unknownError:
            return "Oops! The unknown error occurs."
        }
    }
}
