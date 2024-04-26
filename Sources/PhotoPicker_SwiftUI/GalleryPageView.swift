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

public struct GalleryPageView: View {
    @Environment(\.dismiss) private var dismiss
    @State var selection = 0
    let maxSelectionCount: Int
    @StateObject var viewModel = GalleryModel()
    
    @Binding var isPresented: Bool
    @Binding var selected: [Picture]
    
    public init(isPresented: Binding<Bool>,
                maxSelectionCount: Int = 0,
                selected: Binding<[Picture]>) {
        _isPresented = isPresented
        _selected = selected
        self.maxSelectionCount = maxSelectionCount
    }
    
    public var body: some View {
        NavigationView {
            VStack{
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
                                               indicatorBarColor: Color(light: .black, dark: .white),
                                               padding: EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 0),
                                               tabItemSpacing: 30,
                                               tabItemHeight: 24,
                                               placedInToolbar: true))
                
                HStack{
                    
                    NavigationLink {
                        QuickLookView()
                            .environmentObject(viewModel)
                    } label: {
                        Text("预览")
                            .font(.system(size: 15))
                            .foregroundColor(.primary)
                            .padding(.horizontal , 10)
                            .padding(.vertical, 10)
                    }
                    .disabled(viewModel.selectedPictures.count == 0)
                    
                    Spacer()
                    
                    Button {
                        selected = viewModel.selectedPictures
                        dismiss()
                    } label: {
                        Text(downButtonTitle())
                            .font(.system(size: 15))
                            .foregroundColor(.white)
                            .padding(.horizontal , 10)
                            .padding(.vertical, 10)
                            .background(viewModel.selectedPictures.count == 0 ? .gray : .black)
                            .cornerRadius(8)
                    }
                    .disabled(viewModel.selectedPictures.count == 0)
                }
                .padding(.horizontal, 20)
                .frame(height: 50)
                .background(Color(light: .white, dark: .black))
                .shadow(color: .gray.opacity(0.2), radius: 0.5, y: -0.8)
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .foregroundColor(Color(light: .black, dark: .white))
                    }
                }
            }
        }
        .navigationViewStyle(.stack)
        .onAppear {
            viewModel.maxSelectionCount = maxSelectionCount
        }
        .ss.task {
            await PHPhotoLibrary.requestAuthorization(for: .readWrite)
            await viewModel.loadAllAlbums()
        }
        .onChange(of: viewModel.oneSelectedDone) { value in
            selected = viewModel.selectedPictures
            dismiss()
        }

    }
    
    func downButtonTitle() -> String{
        let title = "完成"
        if viewModel.selectedPictures.count != 0{
            return title + "(\(viewModel.selectedPictures.count))"
        }
        return title
    }
}

#Preview {
    GalleryPageView(isPresented: .constant(true), selected: .constant([]))
}
