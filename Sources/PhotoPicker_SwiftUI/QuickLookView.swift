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
    
    var body: some View {
        GeometryReader { proxy in
            
            VStack{
                
                TabView(selection: $selectedTab) {
                    ForEach(Array(viewModel.selectedPictures.enumerated()), id: \.element) {index, picture in
                        picture.toImage(size: proxy.size, mode: .aspectFill)
                            .resizable()
                            .scaledToFill()
                            .frame(width: proxy.size.width)
                            .clipped()
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .maxHeight(.infinity)
                
                ScrollViewReader { value in
                    HScrollStack(spacing: 10) {
                        ForEach(Array(viewModel.selectedPictures.enumerated()), id: \.element) {index, picture in
                            picture.toImage(size: CGSize(width: 90, height: 90), mode: .aspectFill)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 90, height: 90)
                                .clipShape(Rectangle())
                                .cornerRadius(5)
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
                    .fullScreenCover(isPresented: $isPresentedEdit) {
                        EditView()
                    }
                    
                    Spacer()
                    
                    Button {
                        dismiss()
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
                Text("\(selectedTab + 1)/\(viewModel.selectedPictures.count)")
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
        
    }
}

#Preview {
    QuickLookView()
}
