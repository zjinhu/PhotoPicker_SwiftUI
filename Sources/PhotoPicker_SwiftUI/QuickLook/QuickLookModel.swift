//
//  File.swift
//  
//
//  Created by FunWidget on 2024/5/6.
//

import Foundation
import UIKit
import Photos
class QuickLookModel: ObservableObject{
     
    @Published var selectedMode: QuickLookMode = .image
    
    @Published var image: UIImage?
    @Published var livePhoto: PHLivePhoto?
    @Published var playerItem: AVPlayerItem?
 
}

enum QuickLookMode{
    case image
    case livePhoto
    case video
}
