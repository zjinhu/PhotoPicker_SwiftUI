//
//  SwiftUIView.swift
//  
//
//  Created by FunWidget on 2024/4/25.
//

import SwiftUI
import PagerTabStripView

private class TitleTheme: ObservableObject {
    @Published var textColor = Color.gray
}

struct PageTitleView: View {
    let title: String
    @ObservedObject fileprivate var theme = TitleTheme()
    
    var body: some View {
        VStack {
            Text(title)
                .foregroundColor(theme.textColor)
                .font(.subheadline)
        }
        .background(Color.clear)
    }
    
    func setState(state: PagerTabViewState) {
        switch state {
        case .selected:
            self.theme.textColor = .blue
        case .highlighted:
            self.theme.textColor = .red
        default:
            self.theme.textColor = .gray
        }
    }
}

#Preview {
    PageTitleView(title: "123")
}
