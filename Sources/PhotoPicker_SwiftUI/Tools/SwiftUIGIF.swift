import SwiftUI
import UIKit
import ImageIO
import AVFoundation
import MobileCoreServices

struct AnimationImages {
    public let frames: [UIImage]
    public let duration: Double
}

class GifTool{
    public static func gifImage(data: Data) async -> AnimationImages? {
        await withCheckedContinuation { continuation in
            DispatchQueue.global().async {
                let animationImages = gifImage(data: data)
                continuation.resume(returning: animationImages)
            }
        }
    }
    
    public static func gifImage(data: Data) -> AnimationImages? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil)
        else {
            return nil
        }
        let count = CGImageSourceGetCount(source)
        let delays = (0..<count).map {
            // store in ms and truncate to compute GCD more easily
            Int(delayForImage(at: $0, source: source) * 1000)
        }
        let duration = delays.reduce(0, +)
        let gcd = delays.reduce(0, gcd)
        
        var frames = [UIImage]()
        for i in 0..<count {
            if let cgImage = CGImageSourceCreateImageAtIndex(source, i, nil) {
                let frame = UIImage(cgImage: cgImage)
                let frameCount = delays[i] / gcd
                
                for _ in 0..<frameCount {
                    frames.append(frame)
                }
            } else {
                return nil
            }
        }
        
        return AnimationImages(frames: frames, duration: Double(duration) / 1000.0)
    }
    
    public static func gifImage(name: String) -> AnimationImages? {
        guard let url = Bundle.main.url(forResource: name, withExtension: "gif"),
              let data = try? Data(contentsOf: url)
        else {
            return nil
        }
        return gifImage(data: data)
    }
    
    public static func gifData(name: String) -> Data? {
        guard let url = Bundle.main.url(forResource: name, withExtension: "gif"),
              let data = try? Data(contentsOf: url)
        else {
            return nil
        }
        return data
    }
    
    public static func createGIF(with images: [UIImage?],
                                 frameDelay: TimeInterval = 0.1,
                                 loopCount: Int = 0) -> Data? {
        guard !images.isEmpty else { return nil }
        
        let fileProperties: [String: Any] = [
            kCGImagePropertyGIFDictionary as String: [
                kCGImagePropertyGIFLoopCount as String: loopCount
            ]
        ]
        
        let frameProperties: [String: Any] = [
            kCGImagePropertyGIFDictionary as String: [
                kCGImagePropertyGIFDelayTime as String: frameDelay
            ]
        ]
        
        let data = NSMutableData()
        guard let destination = CGImageDestinationCreateWithData(data, kUTTypeGIF, images.count, nil) else { return nil }
        
        CGImageDestinationSetProperties(destination, fileProperties as CFDictionary)
        
        for image in images {
            if let cgImage = image?.cgImage {
                CGImageDestinationAddImage(destination, cgImage, frameProperties as CFDictionary)
            }
        }
        
        guard CGImageDestinationFinalize(destination) else { return nil }
        
        return data as Data
    }
    
    private static func gcd(_ a: Int, _ b: Int) -> Int {
        let absB = abs(b)
        let r = abs(a) % absB
        if r != 0 {
            return gcd(absB, r)
        } else {
            return absB
        }
    }
    
    private static func delayForImage(at index: Int, source: CGImageSource) -> Double {
        let defaultDelay = 1.0
        
        let cfProperties = CGImageSourceCopyPropertiesAtIndex(source, index, nil)
        let gifPropertiesPointer = UnsafeMutablePointer<UnsafeRawPointer?>.allocate(capacity: 0)
        defer {
            gifPropertiesPointer.deallocate()
        }
        let unsafePointer = Unmanaged.passUnretained(kCGImagePropertyGIFDictionary).toOpaque()
        if CFDictionaryGetValueIfPresent(cfProperties, unsafePointer, gifPropertiesPointer) == false {
            return defaultDelay
        }
        let gifProperties = unsafeBitCast(gifPropertiesPointer.pointee, to: CFDictionary.self)
        var delayWrapper = unsafeBitCast(CFDictionaryGetValue(gifProperties,
                                                              Unmanaged.passUnretained(kCGImagePropertyGIFUnclampedDelayTime).toOpaque()),
                                         to: AnyObject.self)
        if delayWrapper.doubleValue == 0 {
            delayWrapper = unsafeBitCast(CFDictionaryGetValue(gifProperties,
                                                              Unmanaged.passUnretained(kCGImagePropertyGIFDelayTime).toOpaque()),
                                         to: AnyObject.self)
        }
        
        if let delay = delayWrapper as? Double,
           delay > 0 {
            return delay
        } else {
            return defaultDelay
        }
    }
}
extension GifTool{

    public static func createVideoFromGif(gifData: Data, completion: @escaping (URL?) -> Void) {
        guard let images = gifImage(data: gifData)?.frames else {
            completion(nil)
            return
        }
        
        let temporaryDirectoryURL = FileManager.default.temporaryDirectory
        let outputURL = temporaryDirectoryURL.appendingPathComponent("gif.MOV")
        try? FileManager.default.removeItem(at: outputURL)
        
        let videoSize = images[0].size
        let videoDuration = Double(images.count) / 10.0 // Adjust frame rate as needed
        
        let writer = try! AVAssetWriter(outputURL: outputURL, fileType: .mov)
        let settings = [
            AVVideoCodecKey: AVVideoCodecType.h264,
            AVVideoWidthKey: NSNumber(value: Float(videoSize.width)),
            AVVideoHeightKey: NSNumber(value: Float(videoSize.height))
        ] as [String : Any]
        let writerInput = AVAssetWriterInput(mediaType: .video, outputSettings: settings)
        let sourceBufferAttributes: [String: Any] = [
            kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32ARGB),
            kCVPixelBufferWidthKey as String: Float(videoSize.width),
            kCVPixelBufferHeightKey as String: Float(videoSize.height)
        ]
        let adaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: writerInput, sourcePixelBufferAttributes: sourceBufferAttributes)
        
        writer.add(writerInput)
        writer.startWriting()
        writer.startSession(atSourceTime: .zero)
        
        let frameDuration = CMTime(seconds: videoDuration / Double(images.count), preferredTimescale: 600)
        var frameCount = 0
        
        writerInput.requestMediaDataWhenReady(on: DispatchQueue(label: "mediaInputQueue")) {
            while writerInput.isReadyForMoreMediaData {
                if frameCount >= images.count {
                    writerInput.markAsFinished()
                    writer.finishWriting {
                        completion(outputURL)
                    }
                    break
                }
                
                let image = images[frameCount]
                let buffer = pixelBuffer(from: image, size: videoSize)
                let presentationTime = CMTimeMultiply(frameDuration, multiplier: Int32(frameCount))
                
                adaptor.append(buffer, withPresentationTime: presentationTime)
                frameCount += 1
            }
        }
    }
    
    static private func pixelBuffer(from image: UIImage, size: CGSize) -> CVPixelBuffer {
        let options: [NSObject: AnyObject] = [
            kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue,
            kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue
        ]
        var pxbuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(size.width), Int(size.height), kCVPixelFormatType_32ARGB, options as CFDictionary, &pxbuffer)
        guard status == kCVReturnSuccess, let buffer = pxbuffer else {
            fatalError("Failed to create pixel buffer")
        }
        
        CVPixelBufferLockBaseAddress(buffer, [])
        let pxdata = CVPixelBufferGetBaseAddress(buffer)
        
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: pxdata, width: Int(size.width), height: Int(size.height), bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(buffer), space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)
        
        context?.draw(image.cgImage!, in: CGRect(origin: .zero, size: size))
        CVPixelBufferUnlockBaseAddress(buffer, [])
        
        return buffer
    }
    
    
    public static func createGifData(from videoURL: URL, completion: @escaping (Data?) -> Void) {
        let asset = AVAsset(url: videoURL)
        let assetReader = try! AVAssetReader(asset: asset)
        let videoTrack = asset.tracks(withMediaType: .video).first!
        
        let readerOutputSettings: [String: Any] = [
            kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)
        ]
        let assetReaderOutput = AVAssetReaderTrackOutput(track: videoTrack, outputSettings: readerOutputSettings)
        assetReader.add(assetReaderOutput)
        assetReader.startReading()
        
        var frames: [UIImage] = []
        
        while let sampleBuffer = assetReaderOutput.copyNextSampleBuffer(), let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) {
            let ciImage = CIImage(cvPixelBuffer: imageBuffer)
            let context = CIContext(options: nil)
            let cgImage = context.createCGImage(ciImage, from: ciImage.extent)!
            let uiImage = UIImage(cgImage: cgImage)
            frames.append(uiImage)
        }
        
        completion(createGIF(with: frames))
    }
}
