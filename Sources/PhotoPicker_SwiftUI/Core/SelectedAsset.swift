//
//  SwiftUIView.swift
//
//
//  Created by FunWidget on 2024/4/24.
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

public struct SelectedAsset : Identifiable, Equatable, Hashable{
    
    public let id = UUID()
    
    public let asset: PHAsset
    
    public var cropImage: UIImage?
    
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
