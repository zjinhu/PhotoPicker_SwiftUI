//
//  SwiftUIView.swift
//  
//
//  Created by FunWidget on 2024/4/29.
//

import SwiftUI

struct RadioButton: View {
    @State var isChosen: Bool = true
    let label: String
    let action: (Bool) -> Void

    var body: some View {
        Button{ 
            self.isChosen.toggle()
            self.action(self.isChosen)
        }label: {
            HStack(alignment: .center, spacing: 10) {
                Image(systemName: self.isChosen ? "checkmark.circle.fill" : "circle")
                    .resizable()
                    .frame(width: 20, height: 20)
                Text(label)
                    .foregroundColor(.primary)
            }
        }
        .foregroundColor(.primary)
    }
}

#Preview {
    RadioButton(label: "123") { bool in
        
    }
}
