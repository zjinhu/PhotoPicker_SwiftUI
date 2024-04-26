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
    
    @StateObject var viewModel = GalleryModel()
    
    @Binding var isPresented: Bool
    @Binding var selected: [Picture]
    
    public init(isPresented: Binding<Bool>,
                selected: Binding<[Picture]>) {
        _isPresented = isPresented
        _selected = selected
    }
    
    public var body: some View {
        NavigationView {
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
            .pagerTabStripViewStyle(.liner())
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(.white)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        selected = viewModel.selectedPictures
                        dismiss()
                    } label: {
                        Image(systemName: "checkmark")
                            .foregroundColor(.white)
                    }
                }
            }
        }
        .navigationViewStyle(.stack)
        .preferredColorScheme(.dark)
        .ss.task {
            await viewModel.loadAllAlbums()
        }
    }
}

#Preview {
    GalleryPageView(isPresented: .constant(true), selected: .constant([]))
}
