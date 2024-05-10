//
//  EditorViewProtocol.swift
//  HXPhotoPicker
//
//  Created by Silence on 2023/5/5.
//

import UIKit
import AVFoundation
import PencilKit

public protocol EditorViewDelegate: AnyObject {
    /// 编辑状态将要发生改变
    func editorView(willBeginEditing editorView: EditorView)
    /// 编辑状态改变已经结束
    func editorView(didEndEditing editorView: EditorView)
    /// 即将进入编辑状态
    func editorView(editWillAppear editorView: EditorView)
    /// 已经进入编辑状态
    func editorView(editDidAppear editorView: EditorView)
    /// 即将结束编辑状态
    func editorView(editWillDisappear editorView: EditorView)
    /// 已经结束编辑状态
    func editorView(editDidDisappear editorView: EditorView)
    /// 画笔/涂鸦/贴图发生改变
    func editorView(contentViewBeginDraw editorView: EditorView)
    /// 画笔/涂鸦/贴图结束改变
    func editorView(contentViewEndDraw editorView: EditorView)
    /// 点击了贴纸
    /// 选中之后再次点击才会触发
    func editorView(_ editorView: EditorView, didTapStickerItem itemView: EditorStickersItemBaseView)
    /// 即将移除贴纸
    func editorView(_ editorView: EditorView, shouldRemoveStickerItem itemView: EditorStickersItemBaseView)
    /// 移除了贴纸
    func editorView(_ editorView: EditorView, didRemoveStickerItem itemView: EditorStickersItemBaseView)
    /// 贴纸重新添加之后的回调（旋转、添加上一次）
    func editorView(_ editorView: EditorView, resetItemViews itemViews: [EditorStickersItemBaseView])
    
    // MARK: Video
    /// 视频开始播放
    func editorView(_ editorView: EditorView, videoDidPlayAt time: CMTime)
    /// 视频暂停播放
    func editorView(_ editorView: EditorView, videoDidPauseAt time: CMTime)
    func editorView(videoReadyForDisplay editorView: EditorView)
    func editorView(videoResetPlay editorView: EditorView)
    func editorView(_ editorView: EditorView, videoIsPlaybackLikelyToKeepUp: Bool)
    func editorView(_ editorView: EditorView, videoReadyToPlay duration: CMTime)
    func editorView(_ editorView: EditorView, videoDidChangedBufferAt time: CMTime)
    /// 视频播放时间发生了改变
    func editorView(_ editorView: EditorView, videoDidChangedTimeAt time: CMTime)
    /// 视频滑动进度条发生了改变
    func editorView(
        _ editorView: EditorView,
        videoControlDidChangedTimeAt time: TimeInterval,
        for event: VideoControlEvent
    )
    
    /// 视频添加滤镜
    func editorView(_ editorView: EditorView, videoApplyFilter sourceImage: CIImage, at time: CMTime) -> CIImage
    
        func editorView(_ editorView: EditorView, toolPickerFramesObscuredDidChange toolPicker: PKToolPicker)
}

public extension EditorViewDelegate {
    func editorView(willBeginEditing editorView: EditorView) { }
    func editorView(didEndEditing editorView: EditorView) { }
    func editorView(editWillAppear editorView: EditorView) { }
    func editorView(editDidAppear editorView: EditorView) { }
    func editorView(editWillDisappear editorView: EditorView) { }
    func editorView(editDidDisappear editorView: EditorView) { }
    func editorView(contentViewBeginDraw editorView: EditorView) { }
    func editorView(contentViewEndDraw editorView: EditorView) { }
    func editorView(_ editorView: EditorView, didTapStickerItem itemView: EditorStickersItemBaseView) { }
    func editorView(_ editorView: EditorView, shouldRemoveStickerItem itemView: EditorStickersItemBaseView) { }
    func editorView(_ editorView: EditorView, didRemoveStickerItem itemView: EditorStickersItemBaseView) { }
    func editorView(_ editorView: EditorView, resetItemViews itemViews: [EditorStickersItemBaseView]) { }
    func editorView(_ editorView: EditorView, videoDidPlayAt time: CMTime) { }
    func editorView(_ editorView: EditorView, videoDidPauseAt time: CMTime) { }
    func editorView(videoReadyForDisplay editorView: EditorView) { }
    func editorView(videoResetPlay contentView: EditorView) { }
    func editorView(_ editorView: EditorView, videoIsPlaybackLikelyToKeepUp: Bool) { }
    func editorView(_ editorView: EditorView, videoReadyToPlay duration: CMTime) { }
    func editorView(_ editorView: EditorView, videoDidChangedBufferAt time: CMTime) { }
    func editorView(_ editorView: EditorView, videoDidChangedTimeAt time: CMTime) { }
    func editorView(
        _ editorView: EditorView,
        videoControlDidChangedTimeAt time: CMTime,
        for event: VideoControlEvent
    ) { }
    func editorView(
        _ editorView: EditorView,
        videoApplyFilter sourceImage: CIImage,
        at time: CMTime
    ) -> CIImage { sourceImage }
    
    func editorView(_ editorView: EditorView, toolPickerFramesObscuredDidChange toolPicker: PKToolPicker) { }
}
