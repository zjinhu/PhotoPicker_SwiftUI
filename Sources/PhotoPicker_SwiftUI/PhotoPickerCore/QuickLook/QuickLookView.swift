//
//  SwiftUIView.swift
//
//
//  Created by HU on 2024/4/26.
//

import SwiftUI
import BrickKit

public struct QuickLookView: View {
    @State private var isPresentedEdit = false
    @EnvironmentObject var viewModel: GalleryModel
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTab = 0

    public init() {

    }
    
    public var body: some View {
        GeometryReader { proxy in
            
            VStack{
                
                TabView(selection: $selectedTab) {
                    ForEach(Array(viewModel.selectedAssets.enumerated()), id: \.element) {index, asset in
                        
                        if viewModel.isStatic{
                            QLImageView(asset: asset)
                                .frame(width: proxy.size.width)
                                .clipped()
                                .tag(index)
                        }else{
                            switch asset.fetchPHAssetType(){
                            case .image:
                                QLImageView(asset: asset)
                                    .frame(width: proxy.size.width)
                                    .clipped()
                                    .tag(index)
                            case .livePhoto:
                                QLivePhotoView(asset: asset)
                                    .frame(width: proxy.size.width)
                                    .clipped()
                                    .tag(index)
                                    .id(UUID())
                            case .video:
                                QLVideoView(asset: asset)
                                    .frame(width: proxy.size.width)
                                    .clipped()
                                    .tag(index)
                                    .id(UUID())
                                
                            case .unknown, .audio:
                                EmptyView()
                                    .tag(index)
                            }
                            
                        }
                        
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .maxHeight(.infinity)
//                .id(UUID())
                
                ScrollViewReader { value in
                    
                    HScrollStack(spacing: 10) {
                        ForEach(Array(viewModel.selectedAssets.enumerated()), id: \.element) {index, picture in
                            
                            QLThumbnailView(asset: picture, isStatic: viewModel.isStatic)
                                .frame(width: 90, height: 90)
                                .environmentObject(viewModel)
                                .ss.border(selectedTab == index ? .mainBlue : .clear, cornerRadius: 5, lineWidth: 2)
                                .id(index)
                                .onTapGesture {
                                    selectedTab = index
                                }
                        }
                    }
                    .padding(.horizontal, 10)
                    .maxHeight(110)
                    .background(.backColor)
                    .shadow(color: .gray.opacity(0.2), radius: 0.5, y: -0.8)
                    .onChange(of: selectedTab) { new in
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            withAnimation {
                                value.scrollTo(new, anchor: .center)
                            }
                        }
                    }
                    //                    .id(UUID())
                }
                
                HStack{
                    
                    Button {
                        let sset = viewModel.selectedAssets[selectedTab]
                        switch sset.fetchPHAssetType(){
                        case .image:
                            if let image = sset.asset.toImage(){
                                viewModel.selectedAsset = sset
                                viewModel.selectedAsset?.image = image
                                isPresentedEdit.toggle()
                            }
                        case .video:
                            Task{
                                if let url = await sset.asset.getVideoUrl(){
                                    await MainActor.run{
                                        viewModel.selectedAsset = sset
                                        viewModel.selectedAsset?.videoUrl = url
                                        isPresentedEdit.toggle()
                                    }
                                }
                            }
                        case .livePhoto:

                            sset.asset.getLivePhotoVideoUrl { url in
                                if let url {
                                    DispatchQueue.main.async {
                                        viewModel.selectedAsset = sset
                                        viewModel.selectedAsset?.videoUrl = url
                                        isPresentedEdit.toggle()
                                    }
                                }
                            }
                            
                        default: break
                        }
                        
                    } label: {
                        Text("编辑".localString)
                            .font(.f16)
                            .foregroundColor(.textColor)
                            .padding(.horizontal , 10)
                            .padding(.vertical, 10)
                    }
                    
                    Spacer()
                    
                    Button {
                        viewModel.onSelectedDone.toggle()
                    } label: {
                        Text("完成".localString)
                            .font(.f15)
                            .foregroundColor(.white)
                            .padding(.horizontal , 10)
                            .padding(.vertical, 10)
                            .background(.mainBlack)
                            .cornerRadius(8)
                    }
                }
                .padding(.horizontal, 20)
                .frame(height: 50)
            }
            
        }
        .navigationBarBackButtonHidden()
        .toolbar {
            
            ToolbarItem(placement: .principal) {
                Text("\(selectedTab + 1)/\(viewModel.selectedAssets.count)")
                    .font(.system(size: 18)) // 自定义字体和大小
                    .foregroundColor(.textColor) // 修改字体颜色
            }
            
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .resizable()
                        .scaledToFit()
                        .maxHeight(24)
                        .foregroundColor(Color.textColor)
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Text("\(selectedTab + 1)")
                    .font(Font.f15)
                    .foregroundColor(.white)
                    .frame(width: 28, height: 28)
                    .ss.background{
                        Color.mainBlue
                    }
                    .clipShape(Circle())
            }
        }
        .fullScreenCover(isPresented: $isPresentedEdit) {
            
            if let asset = viewModel.selectedAsset{
                EditView(asset: asset,
                         cropRatio: viewModel.cropRatio){ replace in
                    viewModel.selectedAssets.replaceSubrange(selectedTab...selectedTab, with: [replace])
                }
                         .ignoresSafeArea()
            }
            
        }
    }
}

