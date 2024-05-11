//
//  Video.swift
//  VideoEditorSwiftUI
//
//  Created by Bogdan Zykov on 19.04.2023.
//

import SwiftUI
import AVKit

struct Video: Identifiable{
    
    var id: UUID = UUID()
    let asset: AVAsset
    let originalDuration: Double
    var rangeDuration: ClosedRange<Double>
    var thumbnailsImages = [ThumbnailImage]()

    var rate: Float = 1.0
    var volume: Float = 1.0
    
    var totalDuration: Double{
        rangeDuration.upperBound - rangeDuration.lowerBound
    }
    
    init(asset: AVAsset){
        self.asset = asset
        self.originalDuration = asset.videoDuration()
        self.rangeDuration = 0...originalDuration
    }
    
    init(asset: AVAsset, rangeDuration: ClosedRange<Double>, rate: Float = 1.0, rotation: Double = 0){
 
        self.asset = asset
        self.originalDuration = asset.videoDuration()
        self.rangeDuration = rangeDuration
        self.rate = rate
    }
    
    mutating func updateThumbnails(_ geo: GeometryProxy){
        let imagesCount = thumbnailCount(geo)
        
        var offset: Float64 = 0
        for i in 0..<imagesCount{
            let thumbnailImage = ThumbnailImage(image: asset.getImage(Int(offset)))
            offset = Double(i) * (originalDuration / Double(imagesCount))
            thumbnailsImages.append(thumbnailImage)
        }
    }
       
    mutating func setVolume(_ value: Float){
        volume = value
    }
    
    mutating func updateRate(_ rate: Float){
       
        let lowerBound = (rangeDuration.lowerBound * Double(self.rate)) / Double(rate)
        let upperBound = (rangeDuration.upperBound *  Double(self.rate)) / Double(rate)
        rangeDuration = lowerBound...upperBound
        
        self.rate = rate
    }
    
    mutating func resetRate(){
        updateRate(1.0)
    }
    
    mutating func resetRangeDuration(){
        self.rangeDuration = 0...originalDuration
    }
    
    
    private func thumbnailCount(_ geo: GeometryProxy) -> Int {
        
        let num = Double(geo.size.width - 32) / Double(70 / 1.5)
        
        return Int(ceil(num))
    }
 
}


extension Video: Equatable{
    
    static func == (lhs: Video, rhs: Video) -> Bool {
        lhs.id == rhs.id
    }
}

extension Double{
    func nextAngle() -> Double {
        var next = Int(self) + 90
        if next >= 360 {
            next = 0
        } else if next < 0 {
            next = 360 - abs(next % 360)
        }
        return Double(next)
    }
}

struct ThumbnailImage: Identifiable{
    var id: UUID = UUID()
    var image: UIImage?
    
    
    init(image: UIImage? = nil) {
        self.image = image?.resize(to: .init(width: 250, height: 350))
    }
}

