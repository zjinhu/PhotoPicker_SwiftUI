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
    func loadImage(size: CGSize = PHImageManagerMaximumSize,
                          mode: PHImageContentMode = .default) async throws -> UIImage {
        
        let option = PHImageRequestOptions()
        option.isSynchronous = true
        return try await withCheckedThrowingContinuation { continuation in
            PHImageManager.default().requestImage(for: self, targetSize: size, contentMode: mode, options: option) { result, info in
                if let result = result {
                    continuation.resume(returning: result)
                } else if let error = info?[PHImageErrorKey] as? Error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(throwing: NSError(domain: "error", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unknown error occurred"]))
                }
            }
        }
    }
    
    func loadLivePhoto(size: CGSize = PHImageManagerMaximumSize,
                              mode: PHImageContentMode = .default) async throws -> PHLivePhoto {
        
        let options = PHLivePhotoRequestOptions()
        options.isNetworkAccessAllowed = true      // 允许从iCloud下载
        options.deliveryMode = .highQualityFormat  // 请求高质量的Live Photo
        
        return try await withCheckedThrowingContinuation { continuation in
            PHImageManager.default().requestLivePhoto(for: self,
                                                      targetSize: size,
                                                      contentMode: mode,
                                                      options: options) { live, info in
                if let live = live {
                    continuation.resume(returning: live)
                } else if let error = info?[PHImageErrorKey] as? Error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(throwing: NSError(domain: "error", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unknown error occurred"]))
                }
            }
        }
    }
    
    func loadPlayerItem() async throws -> AVPlayerItem {
        
        let options = PHVideoRequestOptions()
        options.version = .current
        options.deliveryMode = .automatic
        options.isNetworkAccessAllowed = true
        
        return try await withCheckedThrowingContinuation { continuation in
            PHImageManager.default().requestPlayerItem(forVideo: self, options: options) { playerItem, info in
                if let playerItem = playerItem {
                    continuation.resume(returning: playerItem)
                } else if let error = info?[PHImageErrorKey] as? Error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(throwing: NSError(domain: "error", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unknown error occurred"]))
                }
            }
        }
    }
    
    func loadAVAsset() async throws -> AVAsset {
        
        let options = PHVideoRequestOptions()
        options.version = .current
        options.deliveryMode = .highQualityFormat
        options.isNetworkAccessAllowed = true
        
        return try await withCheckedThrowingContinuation { continuation in
            PHImageManager.default().requestAVAsset(forVideo: self, options: options) { (avAsset, audioMix, info) in
                
                if let avAsset {
                    continuation.resume(returning: avAsset)
                } else if let error = info?[PHImageErrorKey] as? Error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(throwing: NSError(domain: "error", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unknown error occurred"]))
                }
            }
        }
    }
    
    func loadVideoTime() async throws -> Double {
        
        let options = PHVideoRequestOptions()
        options.version = .current
        options.deliveryMode = .highQualityFormat
        options.isNetworkAccessAllowed = true
        
        return try await withCheckedThrowingContinuation { continuation in
            PHImageManager.default().requestAVAsset(forVideo: self, options: options) { (avAsset, audioMix, info) in
                if let avAsset = avAsset as? AVURLAsset {
                    let duration = CMTimeGetSeconds(avAsset.duration)
                    continuation.resume(returning: duration)
                } else if let error = info?[PHImageErrorKey] as? Error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(throwing: NSError(domain: "error", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unknown error occurred"]))
                }
            }
        }
    }
}
