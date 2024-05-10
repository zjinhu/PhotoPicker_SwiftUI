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

public struct SelectedAsset : Hashable, Identifiable, Equatable {
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

    }
    
    public var videoUrl: URL?
    public var image: UIImage?
 
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
