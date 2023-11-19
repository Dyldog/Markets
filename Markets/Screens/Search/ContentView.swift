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
    @State var urlToShow: URL?
    @StateObject var viewModel: ViewModel = .init()
    @Environment(\.isSearching) private var isSearching: Bool
    
    var content: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), alignment: .top), count: 3)) {
            ForEach(Array(viewModel.items.enumerated()), id: \.element.id) { (index, item) in
                Button {
                    urlToShow = item.marketplaceURL
                } label: {
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
            
            content.sheet(item: $urlToShow, content: { url in
                WebView(url: url) { webview in
                    webview.saveCookies()
                }
            })
            .sheet(isPresented: $viewModel.showLogin, content: {
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



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
