//
//  MarketsApp.swift
//  Markets
//
//  Created by Dylan Elliott on 20/10/2022.
//

import SwiftUI

struct AppView: View {
    @StateObject var viewModel: ViewModel = .init()
    
    var body: some View {
        TabView {
            NavigationView {
                ContentView(viewModel: viewModel)
            }.tabItem {
                Label("Search", systemImage: "magnifyingglass")
            }
            
            NavigationView {
                AlertsView(viewModel: viewModel)
            }.tabItem {
                Label("Alerts", systemImage: "exclamationmark.bubble")
            }
            .badge(viewModel.badgeCount)
        }.sheet(item: $viewModel.urlToShow, content: { url in
            WebView(url: url) { webview in
                webview.saveCookies()
            }
        })
    }
}
@main
struct MarketsApp: App {
    var body: some Scene {
        WindowGroup {
            AppView()
        }
    }
}
