//
//  SwiftUIView.swift
//
//
//  Created by FunWidget on 2024/4/26.
//

import SwiftUI
import BrickKit

struct QuickLookView: View {
    @State private var isPresentedEdit = false
    @EnvironmentObject var viewModel: GalleryModel
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTab = 0
    
    @Binding var selected: [SelectedAsset]
    init(selected: Binding<[SelectedAsset]>) {
        _selected = selected
    }
    
    var body: some View {
        GeometryReader { proxy in
            
            VStack{
                
                TabView(selection: $selectedTab) {
                    ForEach(Array(viewModel.selectedAssets.enumerated()), id: \.element) {index, asset in
                        
                        if viewModel.type == .image{
                            asset.toImageView()
                                .resizable()
                                .scaledToFill()
                                .frame(width: proxy.size.width)
                                .clipped()
                                .tag(index)
                        }else{
                            switch asset.fetchPHAssetType(){
                            case .image:
                                ImageView(asset: asset)
                                    .frame(width: proxy.size.width)
                                    .clipped()
                                    .tag(index)
                            case .livePhoto:
                                LivePhotoView(asset: asset)
                                    .frame(width: proxy.size.width)
                                    .clipped()
                                    .tag(index)
                            case .video:
                                VideoView(asset: asset)
                                    .frame(width: proxy.size.width)
                                    .clipped()
                                    .tag(index)
                            case .unknown, .audio:
                                EmptyView()
                                    .tag(index)
                            }
                            
                        }

                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .maxHeight(.infinity)
                
                ScrollViewReader { value in
                    
                    HScrollStack(spacing: 10) {
                        ForEach(Array(viewModel.selectedAssets.enumerated()), id: \.element) {index, picture in
                            
                            QLThumbnailView(asset: picture)
                                .environmentObject(viewModel)
                                .ss.border(selectedTab == index ? .blue : .clear, cornerRadius: 5, lineWidth: 2)
                                .id(index)
                                .onTapGesture {
                                    selectedTab = index
                                }
                        }
                    }
                    .padding(.horizontal, 10)
                    .maxHeight(110)
                    .background(.white)
                    .shadow(color: .gray.opacity(0.2), radius: 0.5, y: -0.8)
                    .onChange(of: selectedTab) { new in
                        withAnimation {
                            value.scrollTo(new, anchor: .center)
                        }
                    }
                }
                
                HStack{
                    
                    Button {
                        isPresentedEdit.toggle()
                    } label: {
                        Text("编辑")
                            .font(.system(size: 15))
                            .foregroundColor(.primary)
                            .padding(.horizontal , 10)
                            .padding(.vertical, 10)
                    }
                    
                    Spacer()
                    
                    Button {
                        selected = viewModel.selectedAssets
                        viewModel.closedGallery.toggle()
                    } label: {
                        Text("完成")
                            .font(.system(size: 15))
                            .foregroundColor(.white)
                            .padding(.horizontal , 10)
                            .padding(.vertical, 10)
                            .background(.black)
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
                    .font(.system(size: 14)) // 自定义字体和大小
                    .foregroundColor(.gray) // 修改字体颜色
            }
            
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Text("取消")
                        .foregroundColor(.primary)
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Text("\(selectedTab + 1)")
                    .font(Font.system(size: 12))
                    .foregroundColor(.white)
                    .frame(width: 20, height: 20)
                    .ss.background{
                        Color.blue
                    }
                    .clipShape(Circle())
            }
        }
        .fullScreenCover(isPresented: $isPresentedEdit) {
            
        }
    }
}

