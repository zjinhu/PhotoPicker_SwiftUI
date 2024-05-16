//
//  File.swift
//  
//
//  Created by FunWidget on 2024/5/14.
//

import Foundation
import UIKit
import AVFoundation
import Photos

extension CropViewController {
    var isEdited: Bool {
        var isCropTime: Bool = false
        if selectedAsset.contentType == .video {
            if editorView.videoDuration.seconds != videoControlView.middleDuration {
                isCropTime = true
            }
        }

        var isCropSize: Bool = false
        if selectedAsset.contentType == .image {
            isCropSize = editorView.isCropedImage
        }else if selectedAsset.contentType == .video {
            isCropSize = editorView.isCropedVideo
        }
 
        return isCropTime || isCropSize
    }
}

extension CropViewController {
    func processing() {
        switch selectedAsset.contentType {
        case .image:
            imageProcessing()
        case .video:
            videoProcessing()
        default:
            break
        }
    }
    
    func imageProcessing() {
        if editorView.isCropedImage {
            PhotoManager.HUDView.show(with: .textManager.editor.processingHUDTitle.text, delay: 0, animated: true, addedTo: view)
            if editorView.isCropedImage {
                editorView.cropImage { [weak self] result in
                    guard let self = self else { return }
                    PhotoManager.HUDView.dismiss(delay: 0, animated: true, for: self.view)
                    switch result {
                    case .success(let imageResult):
                        self.imageProcessCompletion(imageResult)
                    case .failure:
                        PhotoManager.HUDView.showInfo(with: .textManager.editor.processingFailedHUDTitle.text, delay: 1.5, animated: true, addedTo: self.view)
                    }
                }
            }
        }else {
            editedResult = nil
            selectedAsset.result = nil
            delegate?.editorViewController(self, didFinish: selectedAsset)
//            delegate?.editorViewController(self, didFinish: [])
            finishHandler?(selectedAsset, self)
            backClick()
        }
    }

    func imageProcessCompletion(_ result: ImageEditedResult) {
        let imageEditedResult: ImageEditedData
        let aspectRatio = editorView.aspectRatio
        let angle = lastScaleAngle
        let isFixedRatio = editorView.isFixedRatio

        imageEditedResult = .init(
            filter: nil,
            filterEdit: nil,
            cropSize: .init(
                isFixedRatio: isFixedRatio,
                aspectRatio: aspectRatio,
                angle: angle
            )
        )
        let editedResult = EditedResult.image(result, imageEditedResult)
        self.editedResult = editedResult
        selectedAsset.result = editedResult
        delegate?.editorViewController(self, didFinish: selectedAsset)
        finishHandler?(selectedAsset, self)
//        delegate?.editorViewController(self, didFinish: [editedResult])
        backClick()
    }
    
    func videoProcessing() {
        let isCropTime: Bool = editorView.videoDuration.seconds != videoControlView.middleDuration

        if editorView.isCropedVideo || isCropTime {
            let timeRange: CMTimeRange
            if isCropTime {
                timeRange = .init(start: videoControlView.startTime, end: videoControlView.endTime)
            }else {
                timeRange = .zero
            }

            let factor = EditorVideoFactor(
                timeRang: timeRange,
                maskType: config.cropSize.maskType,
                preset: config.video.preset,
                quality: config.video.quality
            )
            if editorView.isCropedVideo {
                let progressView = PhotoManager.HUDView.showProgress(with: .textManager.editor.processingHUDTitle.text, progress: 0, animated: true, addedTo: view)
                editorView.cropVideo(factor: factor, filter: nil) { progress in
                    progressView?.setProgress(progress)
                } completion: { [weak self] result in
                    guard let self = self else {
                        return
                    }
                    switch result {
                    case .success(let videoResult):
                        DispatchQueue.global(qos: .userInteractive).async {
                            DispatchQueue.main.async {
                                PhotoManager.HUDView.dismiss(delay: 0, animated: true, for: self.view)
                                self.videoProcessCompletion(videoResult)
                            }
                        }
                    case .failure(let error):
                        PhotoManager.HUDView.dismiss(delay: 0, animated: true, for: self.view)
                        if error.isCancel {
                            return
                        }
                        PhotoManager.HUDView.showInfo(with: .textManager.editor.processingFailedHUDTitle.text, delay: 1.5, animated: true, addedTo: self.view)
                    }
                }

            }else {
                if config.isFixedCropSizeState && config.isIgnoreCropTimeWhenFixedCropSizeState {
  
                        editedResult = nil
                        selectedAsset.result = nil
                        delegate?.editorViewController(self, didFinish: selectedAsset)
                        finishHandler?(selectedAsset, self)
                        backClick()
                    
                }
            }
        }else {
            editedResult = nil
            selectedAsset.result = nil
            delegate?.editorViewController(self, didFinish: selectedAsset)
            finishHandler?(selectedAsset, self)
//            delegate?.editorViewController(self, didFinish: [])
            backClick()
        }
    }

    func videoProcessCompletion(
        _ result: VideoEditedResult
    ) {
        let editedData: VideoEditedData
        let aspectRatio = editorView.aspectRatio
        let angle = lastScaleAngle
        let isFixedRatio = editorView.isFixedRatio
        var cropTime: EditorVideoCropTime?
        let isCropTime: Bool = editorView.videoDuration.seconds != videoControlView.middleDuration
        if isCropTime {
            cropTime = .init(
                startTime: videoControlView.startDuration,
                endTime: videoControlView.endDuration,
                preferredTimescale: videoControlView.startTime.timescale,
                controlInfo: videoControlView.controlInfo
            )
        }
 
        editedData = .init(
            cropTime: cropTime,
            filterEdit: nil,
            filter: nil,
            cropSize: .init(
                isFixedRatio: isFixedRatio,
                aspectRatio: aspectRatio,
                angle: angle
            )
        )
        let editedResult = EditedResult.video(result, editedData)
        self.editedResult = editedResult
        selectedAsset.result = editedResult
        delegate?.editorViewController(self, didFinish: selectedAsset)
        finishHandler?(selectedAsset, self)
//        delegate?.editorViewController(self, didFinish: [editedResult])
        backClick()
    }
}

extension CropViewController {
    
    func backClick(_ isCancel: Bool = false) {

        PhotoManager.HUDView.dismiss(delay: 0, animated: true, for: view)
        removeVideo()
        if isCancel {
            isDismissed = true
            delegate?.editorViewController(didCancel: self)
            cancelHandler?(self)
        }
        if let assetRequestID = assetRequestID {
            PHImageManager.default().cancelImageRequest(assetRequestID)
        }
//        if config.isAutoBack {
//            if let navigationController = navigationController, navigationController.viewControllers.count > 1 {
//                navigationController.popViewController(animated: true)
//            }else {
//                dismiss(animated: true, completion: nil)
//            }
//        }
    }
}

extension CropViewController {
    func startPlayVideo() {
        if videoControlView.startDuration == videoControlView.currentDuration {
            startPlayVideoTimer()
        }else {
            let timeInterval = videoControlView.endDuration - videoControlView.currentDuration
            if timeInterval.isNaN { return }
            videoPlayTimer = Timer.scheduledTimer(
                withTimeInterval: timeInterval,
                repeats: false,
                block: { [weak self] in
                    guard let self = self else {
                        return
                    }
                    $0.invalidate()
                    if self.videoPlayTimer == nil || $0 != self.videoPlayTimer {
                        return
                    }
                    self.editorView.seekVideo(to: self.videoControlView.startTime)
                    self.startPlayVideoTimer()
                }
            )
        }
    }
    
    private func startPlayVideoTimer() {
        let timeInterval = videoControlView.middleDuration
        if timeInterval.isNaN { return }
        videoPlayTimer = Timer.scheduledTimer(
            withTimeInterval: timeInterval,
            repeats: true,
            block: { [weak self] in
                guard let self = self else {
                    return
                }
                if self.videoPlayTimer == nil || $0 != self.videoPlayTimer {
                    $0.invalidate()
                    return
                }
                self.editorView.seekVideo(to: self.videoControlView.startTime)
            }
        )
    }
    
    func stopPlayVideo() {
        videoPlayTimer?.invalidate()
        videoPlayTimer = nil
    }
}
