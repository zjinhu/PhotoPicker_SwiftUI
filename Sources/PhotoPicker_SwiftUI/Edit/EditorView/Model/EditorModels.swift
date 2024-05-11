//
//  EditorModels.swift
//  HXPhotoPicker
//
//  Created by Silence on 2023/4/29.
//

import UIKit
import AVFoundation

public struct EditorVideoFactor {
    /// 时间区域
    public let timeRang: CMTimeRange
    /// 裁剪圆切或者自定义蒙版时，被遮住的部分的处理类型
    /// 可自定义颜色，毛玻璃效果统一为 .light
    public let maskType: EditorView.MaskType?
    /// 导出视频的分辨率
    public let preset: ExportPreset
    /// 导出视频的质量 [0-10]
    public let quality: Int
    public init(
        timeRang: CMTimeRange = .zero,
        maskType: EditorView.MaskType? = nil,
        preset: ExportPreset,
        quality: Int
    ) {
        self.timeRang = timeRang
        self.maskType = maskType
        self.preset = preset
        self.quality = quality
    }

}

extension EditorVideoFactor {
    
    func isEqual(_ facotr: EditorVideoFactor) -> Bool {
        if timeRang.start.seconds != facotr.timeRang.start.seconds {
            return false
        }
        if timeRang.duration.seconds != facotr.timeRang.duration.seconds {
            return false
        }
        if preset != facotr.preset {
            return false
        }
        if quality != facotr.quality {
            return false
        }
        return true
    }
}

public struct EditorStickerText {
    public let image: UIImage
    public let text: String
    public let textColor: UIColor
    public let showBackgroud: Bool
    
    public init(image: UIImage, text: String, textColor: UIColor, showBackgroud: Bool) {
        self.image = image
        self.text = text
        self.textColor = textColor
        self.showBackgroud = showBackgroud
    }
}

struct EditorStickerItem: Codable {
    
    var type: EditorStickerItemType
    
    var text: EditorStickerText? { type.text }
    
    var image: UIImage? { type.image }
    
    var imageData: Data? { type.imageData }
    
    var isText: Bool { type.isText }

    var frame: CGRect = .zero
    
    init(
        _ type: EditorStickerItemType
    ) {
        self.type = type
    }
}

public enum EditorStickerItemType {
    case image(UIImage)
    case imageData(Data)
    case text(EditorStickerText)

    var image: UIImage? {
        switch self {
        case .image(let image):
            return image
        case .imageData(let data):
            return .init(data: data)
        case .text(let text):
            return text.image
        }
    }
    
    var imageData: Data? {
        switch self {
        case .imageData(let data):
            return data
        default:
            return nil
        }
    }
    
    var text: EditorStickerText? {
        switch self {
        case .text(let text):
            return text
        default:
            return nil
        }
    }
    
    var isText: Bool {
        switch self {
        case .text:
            return true
        default:
            return false
        }
    }

}

extension EditorStickerItem {
    
    func itemFrame(_ maxWidth: CGFloat) -> CGRect {
        var width = maxWidth - 60

        if type.isText {
            width = maxWidth - 30
        }
        let imageSize = type.image?.size ?? .init(width: 1, height: 1)
        let height = width
        var itemWidth: CGFloat = 0
        var itemHeight: CGFloat = 0
        let imageWidth = imageSize.width
        var imageHeight = imageSize.height
        if imageWidth > width {
            imageHeight = width / imageWidth * imageHeight
        }
        if imageHeight > height {
            itemWidth = height / imageSize.height * imageWidth
            itemHeight = height
        }else {
            if imageWidth > width {
                itemWidth = width
            }else {
                itemWidth = imageWidth
            }
            itemHeight = imageHeight
        }
        return CGRect(x: 0, y: 0, width: itemWidth, height: itemHeight)
    }
}

extension EditorStickerText: Codable {
    enum CodingKeys: CodingKey {
        case image
        case text
        case textColor
        case showBackgroud
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let imageData = try container.decode(Data.self, forKey: .image)

            image = try NSKeyedUnarchiver.unarchivedObject(ofClass: UIImage.self, from: imageData)!

        text = try container.decode(String.self, forKey: .text)
        let colorData = try container.decode(Data.self, forKey: .textColor)
  
            textColor = try NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: colorData)!

        showBackgroud = try container.decode(Bool.self, forKey: .showBackgroud)
    }
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
  
            let imageData = try NSKeyedArchiver.archivedData(withRootObject: image, requiringSecureCoding: false)
            try container.encode(imageData, forKey: .image)
            let colorData = try NSKeyedArchiver.archivedData(withRootObject: textColor, requiringSecureCoding: false)
            try container.encode(colorData, forKey: .textColor)

        try container.encode(text, forKey: .text)
        try container.encode(showBackgroud, forKey: .showBackgroud)
    }
}

extension EditorStickerItemType: Codable {
    enum CodingKeys: CodingKey {
        case image
        case imageData
        case text
        case error
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .image(let image):
         
                let imageData = try NSKeyedArchiver.archivedData(withRootObject: image, requiringSecureCoding: false)
                try container.encode(imageData, forKey: .image)

        case .imageData(let imageData):
            try container.encode(imageData, forKey: .imageData)
        case .text(let text):
            try container.encode(text, forKey: .text)

        }
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let imageData = try? container.decode(Data.self, forKey: .image) {
            let image: UIImage?
     
                image = try NSKeyedUnarchiver.unarchivedObject(ofClass: UIImage.self, from: imageData)

            if let image = image {
                self = .image(image)
                return
            }
        }
        if let data = try? container.decode(Data.self, forKey: .imageData) {
            self = .imageData(data)
            return
        }
        if let text = try? container.decode(EditorStickerText.self, forKey: .text) {
            self = .text(text)
            return
        }

        throw DecodingError.dataCorruptedError(
            forKey: CodingKeys.error,
            in: container,
            debugDescription: "Invalid type"
        )
    }
}

public struct EditAdjustmentData: CustomStringConvertible {
    let content: Content
    let maskImage: UIImage?
    let drawView: [EditorDrawView.BrushInfo]
    let canvasData: EditorCanvasData?
    let mosaicView: [EditorMosaicView.MosaicData]
    let stickersView: EditorStickersView.Item?
    
    
    public var description: String {
        "data of adjustment."
    }
}

extension ImageEditedResult: Codable {
    enum CodingKeys: CodingKey {
        case image
        case urlConfig
        case imageType
        case data
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let imageData = try container.decode(Data.self, forKey: .image)
  
            image = try NSKeyedUnarchiver.unarchivedObject(ofClass: UIImage.self, from: imageData)!

        urlConfig = try container.decode(EditorURLConfig.self, forKey: .urlConfig)
        imageType = try container.decode(ImageType.self, forKey: .imageType)
        data = try container.decode(EditAdjustmentData.self, forKey: .data)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
    
            let imageData = try NSKeyedArchiver.archivedData(withRootObject: image, requiringSecureCoding: false)
            try container.encode(imageData, forKey: .image)

        try container.encode(urlConfig, forKey: .urlConfig)
        try container.encode(imageType, forKey: .imageType)
        try container.encode(data, forKey: .data)
    }
}

extension VideoEditedResult: Codable {
    enum CodingKeys: CodingKey {
        case urlConfig
        case coverImage
        case fileSize
        case videoTime
        case videoDuration
        case data
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let imageData = try container.decode(Data.self, forKey: .coverImage)
 
            coverImage = try NSKeyedUnarchiver.unarchivedObject(ofClass: UIImage.self, from: imageData)

        urlConfig = try container.decode(EditorURLConfig.self, forKey: .urlConfig)
        fileSize = try container.decode(Int.self, forKey: .fileSize)
        videoTime = try container.decode(String.self, forKey: .videoTime)
        videoDuration = try container.decode(TimeInterval.self, forKey: .videoDuration)
        data = try container.decode(EditAdjustmentData.self, forKey: .data)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        if let image = coverImage {
     
                let imageData = try NSKeyedArchiver.archivedData(withRootObject: image, requiringSecureCoding: false)
                try container.encode(imageData, forKey: .coverImage)
 
        }
        try container.encode(urlConfig, forKey: .urlConfig)
        try container.encode(fileSize, forKey: .fileSize)
        try container.encode(videoTime, forKey: .videoTime)
        try container.encode(videoDuration, forKey: .videoDuration)
        try container.encode(data, forKey: .data)
    }
}

extension EditAdjustmentData {
    struct Content: Codable {
        let editSize: CGSize
        let contentOffset: CGPoint
        let contentSize: CGSize
        let contentInset: UIEdgeInsets
        let mirrorViewTransform: CGAffineTransform
        let rotateViewTransform: CGAffineTransform
        let scrollViewTransform: CGAffineTransform
        let scrollViewZoomScale: CGFloat
        let controlScale: CGFloat
        let adjustedFactor: Adjusted?
        
        struct Adjusted: Codable {
            let angle: CGFloat
            let zoomScale: CGFloat
            let contentOffset: CGPoint
            let contentInset: UIEdgeInsets
            let maskRect: CGRect
            let transform: CGAffineTransform
            let rotateTransform: CGAffineTransform
            let mirrorTransform: CGAffineTransform
            
            let contentOffsetScale: CGPoint
            let min_zoom_scale: CGFloat
            let isRoundMask: Bool
            
            let ratioFactor: EditorControlView.Factor?
        }
    }
}

extension EditAdjustmentData: Codable {
    enum CodingKeys: CodingKey {
        case content
        case maskImage
        case canvasData
        case drawView
        case mosaicView
        case stickersView
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        content = try container.decode(Content.self, forKey: .content)
        let imageData = try? container.decode(Data.self, forKey: .maskImage)
        if let imageData = imageData {

                maskImage = try NSKeyedUnarchiver.unarchivedObject(ofClass: UIImage.self, from: imageData)

        }else {
            maskImage = nil
        }
        canvasData = try container.decode(EditorCanvasData.self, forKey: .canvasData)
        drawView = try container.decode([EditorDrawView.BrushInfo].self, forKey: .drawView)
        mosaicView = try container.decode([EditorMosaicView.MosaicData].self, forKey: .mosaicView)
        stickersView = try? container.decode(EditorStickersView.Item.self, forKey: .stickersView)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(content, forKey: .content)
        if let image = maskImage {
 
                let imageData = try NSKeyedArchiver.archivedData(withRootObject: image, requiringSecureCoding: false)
                try container.encode(imageData, forKey: .maskImage)

        }
        try container.encode(canvasData, forKey: .canvasData)
        try container.encode(drawView, forKey: .drawView)
        try container.encode(mosaicView, forKey: .mosaicView)
        try? container.encode(stickersView, forKey: .stickersView)
    }
}

public struct EditorVideoFilterInfo {
    
    /// 视频滤镜
    public let filterHandler: ((CIImage, CGFloat) -> CIImage?)?
    
    /// 滤镜参数
    public let parameterValue: CGFloat
    
    public init(
        parameterValue: CGFloat = 1,
        filterHandler: @escaping (CIImage, CGFloat) -> CIImage?
    ) {
        self.parameterValue = parameterValue
        self.filterHandler = filterHandler
    }
}
