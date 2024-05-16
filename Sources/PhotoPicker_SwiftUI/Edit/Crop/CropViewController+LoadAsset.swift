//
//  File.swift
//  
//
//  Created by FunWidget on 2024/5/14.
//
import UIKit
import AVFoundation

extension CropViewController {
    
    enum LoadAssetStatus {
        case loadding(Bool = false)
        case succeed(EditorAsset.AssetType)
        case failure
    }
    
    func initAsset() {
        let asset = selectedAsset
        initAssetType(asset.type)
    }
    func initAssetType(_ type: EditorAsset.AssetType) {
        let viewSize = UIDevice.screenSize
        switch type {
        case .image(let image):
            if !isTransitionCompletion {
                loadAssetStatus = .succeed(.image(image))
                return
            }
            editorView.setImage(image)
            DispatchQueue.global().async {
                self.loadThumbnailImage(image, viewSize: viewSize)
            }
            loadCompletion()
            loadLastEditedData()
        case .imageData(let imageData):
            if !isTransitionCompletion {
                loadAssetStatus = .succeed(.imageData(imageData))
                return
            }
            editorView.setImageData(imageData)
            let image = self.editorView.image
            DispatchQueue.global().async {
                self.loadThumbnailImage(image, viewSize: viewSize)
            }
            loadCompletion()
            loadLastEditedData()
        case .video(let url):
            if !isTransitionCompletion {
                loadAssetStatus = .succeed(.video(url))
                return
            }
            let avAsset = AVAsset(url: url)
            let image = avAsset.getImage(at: 0.1)
            editorView.setAVAsset(avAsset, coverImage: image)
            editorView.loadVideo(isPlay: false)
            loadCompletion()
            loadLastEditedData()
        case .videoAsset(let avAsset):
            if !isTransitionCompletion {
                loadAssetStatus = .succeed(.videoAsset(avAsset))
                return
            }
            let image = avAsset.getImage(at: 0.1)
            editorView.setAVAsset(avAsset, coverImage: image)
            editorView.loadVideo(isPlay: false)
            loadCompletion()
            loadLastEditedData()
        }
    }
    
    func loadLastEditedData() {
        guard let result = selectedAsset.result else {
            return
        }
        switch result {
        case .image(let editedResult, let editedData):
            editorView.setAdjustmentData(editedResult.data)
        case .video(let editedResult, let editedData):

            editorView.setAdjustmentData(editedResult.data)
            loadVideoCropTimeData(editedData.cropTime)
        }

        if !firstAppear {
            editorView.layoutSubviews()
            checkLastResultState()
        }
        if config.video.isAutoPlay, selectedAsset.contentType == .video {
            DispatchQueue.main.async {
                self.videoControlView.resetLineViewFrsme(at: self.videoControlView.startTime)
                self.editorView.seekVideo(to: self.videoControlView.startTime)
                self.editorView.playVideo()

            }
        }
    }

    func loadCorpSizeData() {
        guard let result = selectedAsset.result else {
            return
        }

        func loadData(_ data: EditorCropSizeFator?, isRound: Bool) {
            guard let data = data else {
                return
            }

            finishRatioIndex = -1
            for (index, aspectRatio) in config.cropSize.aspectRatios.enumerated() {
                if data.isFixedRatio {
                    if aspectRatio.ratio.equalTo(.init(width: -1, height: -1)) || aspectRatio.ratio.equalTo(.zero) {
                        continue
                    }
                    let scale1 = CGFloat(Int(aspectRatio.ratio.width / aspectRatio.ratio.height * 1000)) / 1000
                    let scale2 = CGFloat(Int(data.aspectRatio.width / data.aspectRatio.height * 1000)) / 1000
                    if scale1 == scale2, !isRound {
                        finishRatioIndex = index
                        break
                    }
                }else {
                    if aspectRatio.ratio.equalTo(.zero) {
                        finishRatioIndex = index
                        break
                    }
                }
            }

            if data.angle != 0 {
                finishScaleAngle = data.angle
                lastScaleAngle = data.angle
            }
        }
        DispatchQueue.main.async {
            switch result {
            case .image(let editedResult, let editedData):
                loadData(
                    editedData.cropSize,
                    isRound: editedResult.data?.content.adjustedFactor?.isRoundMask ?? false
                )
            case .video(let editedResult, let editedData):
                loadData(
                    editedData.cropSize,
                    isRound: editedResult.data?.content.adjustedFactor?.isRoundMask ?? false
                )
            }
        }
    }
    
    func loadVideoCropTimeData(_ data: EditorVideoCropTime?) {
        guard let data = data else {
            return
        }
        videoControlInfo = data.controlInfo
        if !firstAppear {
            updateVideoControlInfo()
        }
        controlViewStartEndTime(at: .init(seconds: data.startTime, preferredTimescale: data.preferredTimescale))
        if !firstAppear {
            DispatchQueue.main.async {
                self.updateVideoTimeRange()
            }
        }
    }
    
    func loadVideoControl() {
        let asset = selectedAsset
        switch asset.type {
        case .video(let videoURL):
            videoControlView.layoutSubviews()
            videoControlView.loadData(.init(url: videoURL))
            updateVideoTimeRange()
            isLoadVideoControl = true

        default:
            break
        }
    }

    func loadThumbnailImage(_ image: UIImage?, viewSize: CGSize) {
        guard let image = image else {
            selectedThumbnailImage = selectedOriginalImage
            return
        }
        var maxSize: CGFloat = max(viewSize.width, viewSize.height)
        DispatchQueue.main.sync {
            if !view.size.equalTo(.zero) {
                maxSize = min(view.width, view.height) * 2
            }
        }
        let maxLength = max(image.width, image.height)
        if maxLength > maxSize {
            let thumbnailScale = maxSize / maxLength
            let _image = image.scaleImage(toScale: max(thumbnailScale, config.photo.filterScale))
            selectedThumbnailImage = _image

        }
        if selectedThumbnailImage == nil {
            selectedThumbnailImage = image
        }
    }

    func loadCompletion() {
        isLoadCompletion = true
        if !isLoadVideoControl && !firstAppear {
            loadVideoControl()
        }
        if editorView.type == .image {
            selectedOriginalImage = editorView.image
        }else if editorView.type == .video {
            selectedOriginalImage = nil
        }
    }
    
    func checkLastResultState() {
        resetButton.isEnabled = isReset
        checkFinishButtonState()
    }

    func loadFailure(message: String = .textManager.editor.videoLoadFailedAlertMessage.text) {
        if isDismissed {
            return
        }
        PhotoTools.showConfirm(
            viewController: self,
            title: .textManager.editor.loadFailedAlertTitle.text,
            message: message,
            actionTitle: .textManager.editor.loadFailedAlertDoneTitle.text
        ) { [weak self] _ in
            self?.backClick(true)
        }
    }
}
