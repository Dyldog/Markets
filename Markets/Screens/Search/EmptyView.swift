//
//  EmptyView.swift
//  Markets
//
//  Created by Dylan Elliott on 19/11/2023.
//

import SwiftUI
import WrappingHStack

struct EmptyView: View {
    let words: [String]
    let onSelect: (String) -> Void
    
    var body: some View {
        WrappingHStack(words, alignment: .center) { word in
            Button {
                onSelect(word)
            } label: {
                Text(word)
                    .fixedSize(horizontal: true, vertical: false)
                    .padding(6)
                    .background {
                        RoundedRectangle(cornerRadius: 8)
                            .foregroundStyle(Color.accentColor)
                            .brightness(0.5)
                    }
            }
            .buttonStyle(.plain)
            .padding(4)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
    }
}
