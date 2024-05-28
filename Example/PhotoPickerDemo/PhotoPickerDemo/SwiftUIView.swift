//
//  SwiftUIView.swift
//  PhotoPickerDemo
//
//  Created by FunWidget on 2024/5/24.
//

import SwiftUI
import BrickKit
struct SwiftUIView: View {

    let columns: [GridItem] = [GridItem](repeating: GridItem(.fixed(100), spacing: 5, alignment: .center), count: 4)
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 5) {
                

                    ForEach(0..<1000000000, id: \.self) { index in
                        
                        Image(systemName: "xmark")
                    }
                
                
            }
            .padding(.horizontal , 5)
        }
    }
}

#Preview {
    SwiftUIView()
}
