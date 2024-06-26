//
//  SwiftUIView.swift
//
//
//  Created by HU on 2024/4/26.
//

import SwiftUI
import BrickKit

struct QuickLookView: View {
    @State private var isPresentedEdit = false
    @EnvironmentObject var viewModel: GalleryModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        GeometryReader { proxy in
            
            VStack{
                
                TabView(selection: $viewModel.previewSelectIndex) {
                    ForEach(Array(viewModel.selectedAssets.enumerated()), id: \.element) {index, asset in
                        
                        switch asset.fetchPHAssetType(){
                        case .livePhoto:
                            QLivePhotoView(asset: asset)
                                .frame(width: proxy.size.width)
                                .clipped()
                                .tag(index) 
                        case .video:
                            QLVideoView(asset: asset)
                                .frame(width: proxy.size.width)
                                .clipped()
                                .tag(index)
                        case.gif:
                            QLGifView(asset: asset)
                                .frame(width: proxy.size.width)
                                .clipped()
                                .tag(index) 
                        default:
                            QLImageView(asset: asset)
                                .frame(width: proxy.size.width)
                                .clipped()
                                .tag(index)
                        }
                        
                    }
                    
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .maxHeight(.infinity)
                .id(UUID())
                
                ScrollViewReader { value in
                    
                    HScrollStack(spacing: 10) {
                        ForEach(Array(viewModel.selectedAssets.enumerated()), id: \.element) {index, picture in
                            
                            QLThumbnailView(asset: picture, index: index)
                                .frame(width: 90, height: 90)
                                .environmentObject(viewModel)
                                .id(index)
                                .onTapGesture {
                                    viewModel.previewSelectIndex = index
                                }
                            
                        }
                    }
                    .padding(.horizontal, 10)
                    .maxHeight(110)
                    .background(.backColor)
                    .shadow(color: .gray.opacity(0.2), radius: 0.5, y: -0.8)
                    .onChange(of: viewModel.previewSelectIndex) { new in
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            withAnimation {
                                value.scrollTo(new, anchor: .center)
                            }
                        }
                    }
                }
                
                HStack{
                    
                    Button {
                        
                        Task{
                            let sset = viewModel.selectedAssets[viewModel.previewSelectIndex]
                            viewModel.selectedAsset = await sset.getOriginalSource()
                            isPresentedEdit.toggle()
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
        .onDisappear{
            viewModel.previewSelectIndex = 0
        }
        .navigationBarBackButtonHidden()
        .toolbar {
            
            ToolbarItem(placement: .principal) {
                Text("\(viewModel.previewSelectIndex + 1)/\(viewModel.selectedAssets.count)")
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
                Text("\(viewModel.previewSelectIndex + 1)")
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
                    viewModel.selectedAssets.replaceSubrange(viewModel.previewSelectIndex...viewModel.previewSelectIndex, with: [replace])
                }
                         .statusBar(hidden: true)
                         .ignoresSafeArea()
                         
            }
            
        }
    }
}

