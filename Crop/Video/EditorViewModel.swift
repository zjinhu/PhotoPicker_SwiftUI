//
//  File.swift
//  
//
//  Created by FunWidget on 2024/5/6.
//

import Foundation
import AVKit
import SwiftUI
import Photos
import Combine

class EditorViewModel: ObservableObject{
    
    @Published var currentVideo: Video?
    @Published var isSelectVideo: Bool = true
    
    
    @Published var renderState: ExportState = .unknown

    @Published var progressTimer: TimeInterval = .zero

    private var cancellable = Set<AnyCancellable>()

    private let editorHelper = VideoEditor()
    private var timer: Timer?
    
    func setNewVideo(asset: AVAsset, geo: GeometryProxy){
        currentVideo = .init(asset: asset)
        currentVideo?.updateThumbnails(geo)
    }
     
    @MainActor
    func renderVideo() async{
        guard let video = currentVideo else { return }
        
        renderState = .loading
        self.timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { time in
            self.progressTimer += 1
        }
        
        do{
            let url = try await editorHelper.startRender(video: video)
            renderState = .loaded(url)
            self.saveVideoInLib(url)
            self.resetTimer()
        }catch{
            renderState = .failed(error)
            self.resetTimer()
        }
    }
    
    private func resetTimer(){
        timer?.invalidate()
        timer = nil
        progressTimer = .zero
    }
    
    private func saveVideoInLib(_ url: URL){
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)
        }) {[weak self] saved, error in
            guard let self = self else {return}
            if saved {
                DispatchQueue.main.async {
                    self.renderState = .saved
                }
            }
        }
    }
    
    enum ExportState: Identifiable, Equatable {
        
        case unknown, loading, loaded(URL), failed(Error), saved
        
        var id: Int{
            switch self {
            case .unknown: return 0
            case .loading: return 1
            case .loaded: return 2
            case .failed: return 3
            case .saved: return 4
            }
        }
        
        static func == (lhs: EditorViewModel.ExportState, rhs: EditorViewModel.ExportState) -> Bool {
            lhs.id == rhs.id
        }
    }
}

extension EditorViewModel{

    func reset(){
        currentVideo?.resetRangeDuration()
        currentVideo?.resetRate()
    }
    
    func updateRate(rate: Float){
        currentVideo?.updateRate(rate)
    }

}


