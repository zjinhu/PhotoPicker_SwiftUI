//
//  SwiftUIView.swift
//  
//
//  Created by FunWidget on 2024/4/24.
//

import SwiftUI
import Photos

//相簿列表项
public struct AlbumItem : Identifiable, Equatable {
    public let id = UUID()
    //相簿名称
    var title: String?
    //相簿内的资源
    var fetchResult: PHFetchResult<PHAsset>
    
    public init(title: String?, fetchResult: PHFetchResult<PHAsset>){
        self.title = title
        self.fetchResult = fetchResult
    }
}

public struct Picture : Identifiable, Equatable{
    public let id = UUID()
    public let asset: PHAsset
    public var selected = false
    
    public func toImage(width: Int = 100, height: Int = 100, mode: PHImageContentMode = .aspectFit) -> Image {
        let manager = PHImageManager.default()
        let option = PHImageRequestOptions()
        var image = UIImage()
        option.isSynchronous = true
        manager.requestImage(for: asset, targetSize: CGSize(width: width, height: height), contentMode: mode, options: option, resultHandler: {(result, info)->Void in
            image = result!
        })
        return Image(uiImage: image)
    }
}
