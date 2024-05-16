//
//  File.swift
//
//
//  Created by HU on 2024/4/29.
//

import Foundation
import Photos
import UIKit
public extension PHAsset{
    
    func toImage(size: CGSize = PHImageManagerMaximumSize,
                 mode: PHImageContentMode = .default) -> UIImage? {
        let options = PHImageRequestOptions()
        options.isNetworkAccessAllowed = true
        options.deliveryMode = .opportunistic
        var image: UIImage?
        options.isSynchronous = true
        
        PHCachingImageManager.default().requestImage(for: self, targetSize: size, contentMode: mode, options: options) { result, info in
            image = result
        }
        return image
    }
    
    @discardableResult
    func getImage(size: CGSize = .zero,
                  mode: PHImageContentMode = .aspectFill,
                  resultClosure: @escaping (UIImage?)->()) -> PHImageRequestID{
        
        
        let options = PHImageRequestOptions()
        
        var requestSize: CGSize
        
        if size == .zero{
            requestSize = PHImageManagerMaximumSize
        }else{
            requestSize = CGSize(width: size.width * UIScreen.main.scale,
                                 height: size.height * UIScreen.main.scale)
            options.resizeMode = .exact
        }
        
        options.isNetworkAccessAllowed = true
        options.deliveryMode = .opportunistic
        
        return PHCachingImageManager.default().requestImage(
            for: self,
            targetSize: requestSize,
            contentMode: mode,
            options: options,
            resultHandler: { image, info in
                resultClosure(image) // called for every quality approximation
            }
        )
    }
    
    func getLivePhoto(size: CGSize = PHImageManagerMaximumSize,
                      mode: PHImageContentMode = .default) async -> PHLivePhoto? {
        
        let options = PHLivePhotoRequestOptions()
        options.isNetworkAccessAllowed = true      // 允许从iCloud下载
        options.deliveryMode = .opportunistic  // 请求高质量的Live Photo
        
        return await withCheckedContinuation { continuation in
            PHCachingImageManager.default().requestLivePhoto(for: self,
                                                             targetSize: size,
                                                             contentMode: mode,
                                                             options: options) { live, info in
                if let live = live {
                    continuation.resume(returning: live)
                }else{
                    continuation.resume(returning: nil)
                }
            }
        }
    }
    
    func getPlayerItem() async -> AVPlayerItem? {
        
        let options = PHVideoRequestOptions()
        options.version = .current
        options.deliveryMode = .automatic
        options.isNetworkAccessAllowed = true
        
        return await withCheckedContinuation { continuation in
            PHCachingImageManager.default().requestPlayerItem(forVideo: self, options: options) { playerItem, info in
                if let playerItem = playerItem {
                    continuation.resume(returning: playerItem)
                }else{
                    continuation.resume(returning: nil)
                }
            }
        }
    }
    
    func getVideoTime() async -> Double {
        
        let options = PHVideoRequestOptions()
        options.version = .current
        options.deliveryMode = .automatic
        options.isNetworkAccessAllowed = true
        
        return await withCheckedContinuation { continuation in
            PHCachingImageManager.default().requestAVAsset(forVideo: self, options: options) { (avAsset, audioMix, info) in
                if let avAsset = avAsset as? AVURLAsset {
                    let duration = CMTimeGetSeconds(avAsset.duration)
                    continuation.resume(returning: duration)
                }else{
                    continuation.resume(returning: 0)
                }
            }
        }
    }
    
    func getVideoUrl() async -> URL? {
        
        let options = PHVideoRequestOptions()
        options.version = .original
        options.deliveryMode = .automatic
        options.isNetworkAccessAllowed = true
        
        return await withCheckedContinuation { continuation in
            PHCachingImageManager.default().requestAVAsset(forVideo: self, options: options) { avAsset, _, _ in
                if let urlAsset = avAsset as? AVURLAsset {
                    continuation.resume(returning: urlAsset.url)
                }else{
                    continuation.resume(returning: nil)
                }
            }
        }
    }
    
    func getLivePhotoVideoUrl() -> URL? {
        guard self.mediaSubtypes.contains(.photoLive) else { return nil }
        
        let resources = PHAssetResource.assetResources(for: self)
        guard let pairedVideoResource = resources.first(where: { $0.type == .pairedVideo }) else {
            return nil
        }
        
        let videoURL = pairedVideoResource.value(forKey: "privateFileURL") as? URL
        return videoURL
    }
}
