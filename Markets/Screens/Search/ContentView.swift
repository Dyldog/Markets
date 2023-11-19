//
//  ContentView.swift
//  Markets
//
//  Created by Dylan Elliott on 20/10/2022.
//

import SwiftUI
import Combine
import WebKit
import DylKit
import NavigationSearchBar

struct ContentView: View {
    @ObservedObject var viewModel: ViewModel
    @Environment(\.isSearching) private var isSearching: Bool
    
    var content: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), alignment: .top), count: 3)) {
            ForEach(Array(viewModel.items.enumerated()), id: \.element.id) { (index, item) in
                Button {
                    viewModel.urlToShow = item.marketplaceURL
                } label: {
                    MarketplaceItemView(item: item)
                }
                .buttonStyle(PlainButtonStyle())
                .onAppear {
                    viewModel.getNextPageIfNecessary(encounteredIndex: index)
                }
            }
        }
    }
    var body: some View {
        Self._printChanges()
        return ScrollView {
            if viewModel.items.isEmpty {
                EmptyView(words: viewModel.pastSearches) {
                    viewModel.searchText = $0
                }
            }
            
            content.sheet(isPresented: $viewModel.showLogin, content: {
                WebView(url: .init(string: "https://www.facebook.com")!) {
                    viewModel.loginWebviewLoaded($0)
                }
            })
            .padding(.horizontal)
        }
        .alert($viewModel.alert)
        .navigationTitle("Marketplace")
        .navigationSearchBar(text: $viewModel.searchText, options: [
            .automaticallyShowsSearchBar: true,
            .hidesNavigationBarDuringPresentation: false,
            .hidesSearchBarWhenScrolling: false
        ])
        .toolbar {
            HStack {
                if viewModel.isLoading {
                    ProgressView().progressViewStyle(.circular)
                }
                
                freeButton
            }
        }
        .onAppear {
            viewModel.onAppear()
        }
        .onChange(of: viewModel.searchText) {
            viewModel.search(for: $0, page: nil)
        }
    }
    
    private var freeButton: some View {
        Button {
            viewModel.showFreeTapped()
        } label: {
            ZStack {
                Image(systemName: "dollarsign.circle").font(.title3.bold())
                
                if viewModel.showFreeOnly {
                    Image(systemName: "circle.slash").font(.title3.bold())
                }
            }
        }
    }
}
