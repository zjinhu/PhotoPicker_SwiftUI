//
//  VideoEditor.swift
//  VideoEditorSwiftUI
//
//  Created by Bogdan Zykov on 22.04.2023.
//

import Foundation
import AVFoundation
import UIKit
import Combine

class VideoEditor{
    
    @Published var currentTimePublisher: TimeInterval = 0.0
    
    ///The renderer is made up of half-sequential operations:
    func startRender(video: Video) async throws -> URL{
        do{
            let url = try await cutOperation(video: video)
            return url
        }catch{
            throw error
        }
    }
    
    ///Cut, resizing, rotate and set quality
    private func cutOperation(video: Video) async throws -> URL{
        
        let timeRange = getTimeRange(for: video.originalDuration, with: video.rangeDuration)
        let asset = video.asset
        
        guard let track = asset.tracks(withMediaType: .video).first else { throw ExporterError.unknow}
        let size = track.naturalSize.applying(track.preferredTransform)
        
        ///Create mutable video composition
        let videoComposition = AVMutableVideoComposition()
        ///Set rander video  size
        videoComposition.renderSize = CGSize(width: abs(size.width), height: abs(size.height))
        ///Set frame duration 30fps
        videoComposition.frameDuration = CMTimeMake(value: 1, timescale: 30)
        
        ///Set Video Composition Instruction
        let instruction = AVMutableVideoCompositionInstruction()
        
        ///Set time range
        instruction.timeRange = timeRange
        
        ///Set instruction in videoComposition
        videoComposition.instructions = [instruction]
        
        ///Create file path in temp directory
        let outputURL = createTempPath()
        
        ///Create exportSession
        let session = try exportSession(asset: asset, videoComposition: videoComposition, outputURL: outputURL, timeRange: timeRange)
        
        await session.export()
        
        if let error = session.error {
            throw error
        } else {
            if let url = session.outputURL{
                return url
            }
            throw ExporterError.failed
        }
    }
}

//MARK: - Helpers
extension VideoEditor{
    
    
    private func exportSession(asset: AVAsset,
                               videoComposition: AVMutableVideoComposition,
                               outputURL: URL,
                               timeRange: CMTimeRange) throws -> AVAssetExportSession {
        guard let export = AVAssetExportSession(
            asset: asset,
            presetName: isSimulator ? AVAssetExportPresetPassthrough : AVAssetExportPresetHighestQuality)
        else {
            print("Cannot create export session.")
            throw ExporterError.cannotCreateExportSession
        }
        export.videoComposition = videoComposition
        export.outputFileType = .mp4
        export.outputURL = outputURL
        export.timeRange = timeRange
        
        return export
    }
    
    ///create CMTimeRange
    private func getTimeRange(for duration: Double, with timeRange: ClosedRange<Double>) -> CMTimeRange {
        let start = timeRange.lowerBound.clamped(to: 0...duration)
        let end = timeRange.upperBound.clamped(to: start...duration)
        
        let startTime = CMTimeMakeWithSeconds(start, preferredTimescale: 1000)
        let endTime = CMTimeMakeWithSeconds(end, preferredTimescale: 1000)
        
        let timeRange = CMTimeRangeFromTimeToTime(start: startTime, end: endTime)
        return timeRange
    }
    
    private func createTempPath() -> URL{
        let tempPath = "\(NSTemporaryDirectory())temp_video.mp4"
        let tempURL = URL(fileURLWithPath: tempPath)
        FileManager.default.removefileExists(for: tempURL)
        return tempURL
    }
    
    
    ///needed for simulator fix AVVideoCompositionCoreAnimationTool crash only in simulator
    private var isSimulator: Bool {
#if targetEnvironment(simulator)
        true
#else
        false
#endif
    }
    
}

enum ExporterError: Error, LocalizedError{
    case unknow
    case cancelled
    case cannotCreateExportSession
    case failed
    
}


extension Double {
    func clamped(to range: ClosedRange<Double>) -> Double {
        return min(max(self, range.lowerBound), range.upperBound)
    }
    
    
    var degTorad: Double {
        return self * .pi / 180
    }
}
