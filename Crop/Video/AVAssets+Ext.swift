//
//  AVAssets+Ext.swift
//  VideoEditorSwiftUI
//
//  Created by Bogdan Zykov on 16.04.2023.
//

import Foundation
import AVKit
import SwiftUI

extension AVAsset {
 
    func getImage(_ second: Int, compressionQuality: Double = 0.05) -> UIImage?{
        let imgGenerator = AVAssetImageGenerator(asset: self)
        guard let cgImage = try? imgGenerator.copyCGImage(at: .init(seconds: Double(second), preferredTimescale: 1), actualTime: nil) else { return nil}
        let uiImage = UIImage(cgImage: cgImage)
        guard let imageData = uiImage.jpegData(compressionQuality: compressionQuality), let compressedUIImage = UIImage(data: imageData) else { return nil }
        return compressedUIImage
    }
    
    
    func videoDuration() -> Double{
        return CMTimeGetSeconds(self.duration)
    }
}


