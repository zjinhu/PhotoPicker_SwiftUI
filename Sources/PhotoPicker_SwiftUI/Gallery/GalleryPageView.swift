//
//  SwiftUIView.swift
//  
//
//  Created by FunWidget on 2024/4/25.
//

import SwiftUI
import PagerTabStripView
import Photos
import BrickKit

struct GalleryPageView: View {
    @Environment(\.dismiss) private var dismiss
    @State var selection = 0
    @State private var showToast = false
    let maxSelectionCount: Int
    @StateObject var viewModel = GalleryModel()
    @Binding var selected: [SelectedAsset]
    var type: PHAssetMediaType?
    let onlyImage: Bool
    
    init(maxSelectionCount: Int = 0,
         onlyImage: Bool = false,
         selected: Binding<[SelectedAsset]>) {
        _selected = selected
        self.maxSelectionCount = maxSelectionCount
        self.onlyImage = onlyImage
        if onlyImage{
            self.type = .image
        }
    }
    
    var body: some View {
        NavigationView {
            VStack{
                
                if viewModel.permission == .limited {
                    HStack {
                        Text("你已允许访问选择照片，可管理选择更多照片".localString)
                            .font(.f12)
                            .foregroundColor(.secondGray)
                        
                        Spacer()
                        
                        Button {
                            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                                return
                            }
                            
                            if UIApplication.shared.canOpenURL(settingsUrl) {
                                UIApplication.shared.open(settingsUrl)
                            }
                        } label: {
                            Text("管理".localString)
                                .font(.f12)
                                .foregroundColor(.textColor)
                                .padding(.horizontal, 10)
                        }
                        .frame(height: 26)
                        .ss.border(Color.textColor, cornerRadius: 13, lineWidth: 1)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 9)
                    .background(.gray.opacity(0.2))
                    .cornerRadius(10)
                    .padding(.horizontal, 16)
                }

                PagerTabStripView(selection: $selection) {
                    
                    ForEach(viewModel.albums) { album in
                        GalleryView(results: album.fetchResult)
                            .pagerTabItem {
                                PageTitleView(title: album.title ?? "")
                            }
                            .environmentObject(viewModel)
                    }
                    
                }
                .frame(alignment: .center)
                .pagerTabStripViewStyle(.liner(indicatorBarHeight: 2,
                                               indicatorPadding: 5,
                                               indicatorBarColor: Color.textColor,
                                               padding: EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 0),
                                               tabItemSpacing: 30,
                                               tabItemHeight: 30,
                                               placedInToolbar: true))
                
                if maxSelectionCount != 1{
                    HStack{
                        
                        NavigationLink {
                            QuickLookView(selected: $selected)
                                .environmentObject(viewModel)
                        } label: {
                            Text("预览".localString)
                                .font(.f16)
                                .foregroundColor(.textColor)
                                .padding(.horizontal , 10)
                                .padding(.vertical, 10)
                        }
                        .disabled(viewModel.selectedAssets.count == 0)
                        
                        Spacer()
                        if !onlyImage{
                            RadioButton(label: "动态效果".localString) { bool in
                                if bool{
                                    self.viewModel.type = nil
                                }else{
                                    self.viewModel.type = .image
                                }
                            }
                        }
                        Spacer()
                        
                        Button {
                            selected = viewModel.selectedAssets
                            dismiss()
                        } label: {
                            Text(doneButtonTitle())
                                .font(.f15)
                                .foregroundColor(.white)
                                .padding(.horizontal , 10)
                                .padding(.vertical, 10)
                                .background(viewModel.selectedAssets.count == 0 ? .gray : .black)
                                .cornerRadius(8)
                        }
                        .disabled(viewModel.selectedAssets.count == 0)
                    }
                    .padding(.horizontal, 20)
                    .frame(height: 50)
                    .background(Color.backColor)
                    .shadow(color: .gray.opacity(0.2), radius: 0.5, y: -0.8)
                }

            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .resizable()
                            .scaledToFit()
                            .maxHeight(12)
                            .foregroundColor(Color.textColor)
                    }
                }
            }
        }
        .navigationViewStyle(.stack)
        .onAppear {
            viewModel.maxSelectionCount = maxSelectionCount
            viewModel.type = type
        }
        .ss.task {
            await PHPhotoLibrary.requestAuthorization(for: .readWrite)
            await viewModel.loadAllAlbums()
        }
        .onChange(of: viewModel.oneSelectedDone) { value in
            selected = viewModel.selectedAssets
            dismiss()
        }
        .onChange(of: viewModel.selectedAssets) { value in
            if value.count == viewModel.maxSelectionCount{
                showToast.toggle()
            }
        }
        .onChange(of: viewModel.closedGallery) { value in
            dismiss()
        }
        .toast(isPresenting: $showToast){
    
            AlertToast(displayMode: .hud,
                       type: .systemImage("exclamationmark.circle.fill", .alertOrange),
                       title: "最多可选\(viewModel.maxSelectionCount)张照片".localString,
                       style: .style(backgroundColor: .backColor, titleColor: .textColor, titleFont: .f14))
        }

    }
    
    func doneButtonTitle() -> String{
        let title = "完成".localString
        if viewModel.selectedAssets.count != 0{
            return title + "(\(viewModel.selectedAssets.count))"
        }
        return title
    }
}

#Preview {
    GalleryPageView(selected: .constant([]))
}
