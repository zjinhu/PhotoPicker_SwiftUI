//
//  SwiftUIView.swift
//
//
//  Created by HU on 2024/4/24.
//

import SwiftUI
import Photos

//相簿列表项
struct AlbumItem : Identifiable, Equatable {
    let id = UUID()
    //相簿名称
    var title: String?
    //相簿内的资源
    var fetchResult: PHFetchResult<PHAsset>
    
    init(title: String?, fetchResult: PHFetchResult<PHAsset>){
        self.title = title
        self.fetchResult = fetchResult
    }
}

public class SelectedAsset : Hashable{
    public static func == (lhs: SelectedAsset, rhs: SelectedAsset) -> Bool {
        lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
         hasher.combine(id)
    }
    
    public let id = UUID()
    
    public let asset: PHAsset
    
    init(asset: PHAsset) {
        self.asset = asset
        if assetType == .video{
            Task{ @MainActor in
                videoUrl = try? await getVideoUrl()
            }
        }
    }
    
    public var videoUrl: URL?
    
    public var cropImage: UIImage?
    
    public var assetType: SelectedAssetType{
        switch asset.mediaType {
        case .image:
            if asset.mediaSubtypes.contains(.photoLive) {
                return .livePhoto
            }
            return .image
        case .video:
            return .video
        case .audio:
            return .audio
        default:
            return .unknown
        }
    }
    
    public func toImageView(size: CGSize = PHImageManagerMaximumSize,
                            mode: PHImageContentMode = .default) -> Image {
        let manager = PHImageManager.default()
        let option = PHImageRequestOptions()
        var image = UIImage()
        option.isSynchronous = true
        manager.requestImage(for: asset, targetSize: size, contentMode: mode, options: option) { result, info in
            image = result!
        }
        return Image(uiImage: image)
    }
    
    public func toImage(size: CGSize = PHImageManagerMaximumSize,
                        mode: PHImageContentMode = .default) -> UIImage {
        let manager = PHImageManager.default()
        let option = PHImageRequestOptions()
        var image = UIImage()
        option.isSynchronous = true
        manager.requestImage(for: asset, targetSize: size, contentMode: mode, options: option) { result, info in
            image = result!
        }
        return image
    }
 
    func getVideoUrl() async throws -> URL? {
 
        let options = PHVideoRequestOptions()
        options.version = .original
        options.deliveryMode = .highQualityFormat
        options.isNetworkAccessAllowed = true

        return try await withCheckedThrowingContinuation { continuation in
            PHImageManager.default().requestAVAsset(forVideo: asset, options: options) { avAsset, _, _ in
                if let urlAsset = avAsset as? AVURLAsset {
                    continuation.resume(returning: urlAsset.url)
                } else {
                    continuation.resume(returning: nil)
                }
            }
        }
    }
 
    func getLivePhotoVideoUrl() -> URL? {
        guard asset.mediaSubtypes.contains(.photoLive) else { return nil }

        let resources = PHAssetResource.assetResources(for: asset)
        guard let pairedVideoResource = resources.first(where: { $0.type == .pairedVideo }) else {
            return nil
        }

        let videoURL = pairedVideoResource.value(forKey: "privateFileURL") as? URL
        return videoURL
    }
    
    public enum SelectedAssetType{
        case image
        case livePhoto
        case video
        case audio
        case unknown
    }
    
    public func fetchPHAssetType() -> SelectedAssetType {
        switch asset.mediaType {
        case .image:
            if asset.mediaSubtypes.contains(.photoLive) {
                return .livePhoto
            }
            return .image
        case .video:
            return .video
        case .audio:
            return .audio
        default:
            return .unknown
        }
    }
}
