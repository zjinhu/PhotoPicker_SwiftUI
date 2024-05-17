//
//  SwiftUIView.swift
//
//
//  Created by HU on 2024/4/24.
//

import SwiftUI
import Photos

public struct SelectedAsset : Identifiable, Equatable, Hashable{
    
    public let id = UUID()
    
    public let asset: PHAsset
    
    public var videoUrl: URL?
    public var image: UIImage?
    
    public init(asset: PHAsset) {
        self.asset = asset
    }
    
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
