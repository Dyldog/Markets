//
//  AlertsView.swift
//  Markets
//
//  Created by Dylan Elliott on 19/11/2023.
//

import SwiftUI
import CardStack
import DylKit

struct AlertsView: View {
    @ObservedObject var viewModel: ViewModel
    @State var showSettings: Bool = false
    
    func icon(for direction: LeftRight?) -> AnyView? {
        func view(name: String, color: Color) -> AnyView {
            AnyView(ZStack {
                RoundedRectangle(cornerRadius: 8).foregroundStyle(color).opacity(0.4)
                Image(systemName: name).resizable().frame(width: 200, height: 200).foregroundStyle(color).any
            })
        }
        switch direction {
        case .left: return view(name: "hand.thumbsdown.fill", color: .red)
        case .right: return view(name: "hand.thumbsup.fill", color: .green)
        case .none: return nil
        }
    }
    
    var body: some View {
        VStack {
            Spacer()
            CardStack(
                direction: LeftRight.direction,
                data: viewModel.alertItems,
                onSwipe: { item, direction in
                    viewModel.alertSwiped(item, direction: direction)
                },
                content: { item, direction, _ in
                    ZStack {
                        MarketplaceItemView(item: item)
                            .padding()
                            .roundedBackground(radius: 20, color: .white)
                        icon(for: direction)
                    }
                }
            )
            .environment(\.cardStackConfiguration, CardStackConfiguration(
//                  maxVisibleCards: 10,
              swipeThreshold: 0.1,
//                  cardOffset: 40,
              cardScale: 0.05
//                  animation: .linear
            ))
            .padding()
            .scaledToFit()
            Spacer()
        }
        .sheet(isPresented: $viewModel.showAlertConfig, onDismiss: {
            viewModel.getAlertItems()
        }, content: {
            AlertConfigView()
        })
        .toolbar {
            HStack {
                Button {
                    viewModel.getAlertItems()
                } label: {
                    Image(systemName: "arrow.counterclockwise")
                }
                
                Button {
                    viewModel.showAlertConfig = true
                } label: {
                    Image(systemName: "list.star")
                }
                
                Button {
                    showSettings = true
                } label: {
                    Image(systemName: "gear")
                }
            }

        }
        .navigationTitle("Alerts")
        .sheet(isPresented: $showSettings) {
            NavigationView { SettingsView(properties: Secrets.allCases) }
        }
    }
}

