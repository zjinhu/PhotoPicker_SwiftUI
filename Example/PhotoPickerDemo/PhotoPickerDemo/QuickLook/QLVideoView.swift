//
//  SwiftUIView.swift
//
//
//  Created by HU on 2024/4/28.
//

import SwiftUI
import AVKit
import Photos
import BrickKit
import PhotoPicker_SwiftUI
public struct QLVideoView: View {
    var asset: SelectedAsset
    @State private var player = AVPlayer()
    @State var isPlaying: Bool = false
 
    @StateObject var videoModel: VideoViewModel
 
    public init(asset: SelectedAsset) {
        self.asset = asset
        _videoModel = StateObject(wrappedValue: VideoViewModel(asset: asset))
    }
    
    public var body: some View {
        ZStack {
            PlayerView(player: player)
            
            if !isPlaying {
                Button{
                    player.play()
                    isPlaying = true
                } label: {
                    Image(systemName: "play")
                        .foregroundColor(.white)
                        .padding()
                }
            }
        }
        .onAppear{
            // 添加播放完成的通知
            NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: player.currentItem, queue: .main) { _ in
                isPlaying = false
                player.seek(to: .zero)
            }
        }
        .task {
            await loadAsset()
        }
        .onDisappear{
            isPlaying = false
            player.pause()
            player.seek(to: .zero)
        }
        .onChange(of: videoModel.playerItem) { new in
            player.replaceCurrentItem(with: new)
        }
    }
    
    private func loadAsset() async {
        if let url = asset.editResult?.videoURL{
            videoModel.playerItem = AVPlayerItem(url: url)
            return
        }
        await videoModel.loadAsset()
    }
}

struct PlayerView: UIViewRepresentable {
    var player: AVPlayer
    
    func makeUIView(context: Context) -> PlayerUIView {
        let playerUIView = PlayerUIView()
        playerUIView.configure(with: player)
        return playerUIView
    }
    
    func updateUIView(_ uiView: PlayerUIView, context: Context) {
        // 确保player layer的frame更新
        uiView.configure(with: player)
    }
}

class PlayerUIView: UIView {
    private var playerLayer: AVPlayerLayer?
    
    // 初始化并设置AVPlayer
    func configure(with player: AVPlayer) {
        if playerLayer == nil {
            playerLayer = AVPlayerLayer(player: player)
            layer.addSublayer(playerLayer!)
        } else {
            playerLayer?.player = player
        }
        playerLayer?.frame = bounds
        playerLayer?.videoGravity = .resizeAspect
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer?.frame = bounds
    }
}
