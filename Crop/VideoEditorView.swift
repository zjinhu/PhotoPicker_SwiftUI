//
//  SwiftUIView.swift
//
//
//  Created by FunWidget on 2024/5/6.
//

import AVKit
import SwiftUI
import PhotosUI
import BrickKit
struct VideoEditorView: View {
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.dismiss) private var dismiss
    
    var selected: AVAsset
    
    @StateObject var editorVM = EditorViewModel()
    @StateObject var videoPlayer = VideoPlayerManager()
    
    var body: some View {
        GeometryReader { proxy in
            VStack{
                PlayerHolderView(editorVM: editorVM,
                                 videoPlayer: videoPlayer)
                
                PlayerControl(editorVM: editorVM,
                              videoPlayer: videoPlayer)
                .frame(height: 100)
                
                ZStack{
                    ThumbnailsSliderView(curretTime: $videoPlayer.currentTime, video: $editorVM.currentVideo) {
                        videoPlayer.scrubState = .scrubEnded(videoPlayer.currentTime)
                    }
                }
                .frame(height: 72)
                .background(.fourthBlack)
 
                HStack{
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(.white)
                            .frame(height: 16, alignment: .center)
                        
                    }
                    
                    Spacer()
                    
                    Button {
                        
                    } label: {
                        Text("还原".localString)
                            .font(.f15)
                            .foregroundColor(.white)
                            .padding(.horizontal , 10)
                            .padding(.vertical, 10)
                    }
                    
                    Spacer()
                    
                    Button {
                        Task{
                           await editorVM.renderVideo()
                        }
                    } label: {
                        Image(systemName: "checkmark")
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(.white)
                            .frame(height: 16, alignment: .center)
                        
                    }
                }
                .frame(height: 40)
                .padding(.horizontal, 32)
            }
            .onAppear{
                setVideo(proxy)
            }
        }
    }
    
    private func setVideo(_ proxy: GeometryProxy){
        
        videoPlayer.loadState = .loaded(selected)
        editorVM.setNewVideo(asset: selected, geo: proxy)
        
    }
}
