//
//  MarketplaceView.swift
//  Markets
//
//  Created by Dylan Elliott on 19/11/2023.
//

import SwiftUI
import DylKit

struct MarketplaceItemView: View {
    let item: MarketplaceItem
    
    var body: some View {
        VStack {
            ZStack {
                URLImage(url: item.imageURL.absoluteString)
                    .cornerRadius(8)
                CornerStack(corner: .bottomRight) {
                    Text(item.price.replacingWholeMatch("$0.00", with: "FREE"))
                        .font(.footnote.bold())
                        .foregroundStyle(.white)
                        .padding(2)
                        .roundedBackground(
                            radius: 8,
                            color: item.price == "$0.00" ? .green : .red
                        )
                }
            }
            Text(item.title)
                .font(.system(size: 12, weight: .bold))
                .multilineTextAlignment(.center)
            Spacer()
        }
    }
}
