//
//  ViewModel.swift
//  Markets
//
//  Created by Dylan Elliott on 18/11/2023.
//

import Foundation
import Combine
import WebKit
import DylKit

enum DefaultKeys: String, DefaultsKey {
    case pastSearches = "PAST_SEARCHES"
}

class ViewModel: NSObject, ObservableObject {
    
    let client = APIClient()
    var cancellables: Set<AnyCancellable> = .init()
    var searchRequest: AnyCancellable?
    
    var currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        return formatter
    }()
    
    @Published var alert: Alert?
    @Published var showLogin: Bool = false
    @Published private var cookie: String?
    @UserDefaultable(key: DefaultKeys.pastSearches) private(set) var pastSearches: [String] = ["Plants", "Tools"]
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var showFreeOnly: Bool = true
    
    @Published var items: [MarketplaceItem] = []
    @Published private var _searchText: String = ""
    var searchText: String {
        get { _searchText }
        set {
            guard _searchText != newValue else { return }
            _searchText = newValue
        }
    }
    
    var nextPageInfo: MarketplaceSearchResponse.PageInfo?
    
    override init() {
        super.init()
        
//        publisher(for: \.searchText)
//            .throttle(for: 1.0, scheduler: RunLoop.main, latest: true)
////            .receive(on: RunLoop.main)
//            .sink { [weak self] in
//                self?.search(for: $0, page: 0)
//            }.store(in: &cancellables)
    }
    
    func onAppear() {
        let store = WKWebsiteDataStore.default()
        Task {
            let cookie = store.marketPlaceCookie()
            DispatchQueue.main.async {
                self.cookie = cookie
                self.showLogin = self.cookie == nil
            }
        }
    }
    
    func loginWebviewLoaded(_ webView: WKWebView) {
        webView.saveCookies()
        onAppear()
    }
    
    private func addPastSearch(_ query: String) {
        guard query.count > 1 else { return }
        pastSearches = ([query] + pastSearches).unique
    }
    
    func search(for query: String, page: MarketplaceSearchResponse.PageInfo?) {
        guard !query.isEmpty else { items = []; return }
        
        guard let cookie = cookie else { return }
        
        nextPageInfo = page
        searchRequest?.cancel()
        
        isLoading = true
        searchRequest = client.makeRequest(MarketplaceRequest.search(query, page: page, cookie: cookie), for: MarketplaceSearchResponse.self)
            .receive(on: RunLoop.main).sink { completion in
            switch completion {
            case .finished:
                self.addPastSearch(query)
                self.isLoading = false
            case let .failure(error):
                self.alert = .init(title: "Error searching", message: error.localizedDescription)
            }
        } receiveValue: { response in
            let data = response.data.marketplace_search.feed_units
            self.nextPageInfo = data.page_info
            let items: [MarketplaceItem] = data.edges.compactMap {
                $0.node.listing
            }
            .if(self.showFreeOnly) { items in items.filter { $0.listing_price.amount.mapped == 0 }  }
            .sorted { $0.listing_price.amount.mapped < $1.listing_price.amount.mapped }.map {
                .init(
                    facebookID: $0.id,
                    title: $0.marketplace_listing_title,
                    price: self.currencyFormatter.string(from: $0.listing_price.amount.mapped as NSNumber) ?? "ERROR",
                    imageURL: $0.primary_listing_photo.image.uri
                )
            }
            
            let isLastPage = data.edges.contains(where: {
                $0.node.__typename == "MarketplaceSearchFeedEndOfResults"
            })
            
            if items.count == 0, !isLastPage {
                self.loadNextPage()
            } else if page == nil {
                self.items = items
            } else {
                self.items += items
            }
        }
    }
    
    private func loadNextPage() {
        guard let nextPageInfo = nextPageInfo else { return }
        search(for: searchText, page: nextPageInfo)
    }
    
    func getNextPageIfNecessary(encounteredIndex: Int) {
        guard encounteredIndex == items.count - 1 else { return }
        loadNextPage()
    }
    
    func showFreeTapped() {
        showFreeOnly.toggle()
        search(for: searchText, page: nil)
    }
}
