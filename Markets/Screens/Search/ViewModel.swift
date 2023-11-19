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
import CardStack

enum DefaultKeys: String, DefaultsKey {
    case pastSearches = "PAST_SEARCHES"
    case alerts = "MARKETPLACE_ALERTS"
    case seenAlerts = "SEEN_ALERTS"
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
    
    
    @Published var urlToShow: URL?
    @Published var alert: Alert?
    @Published var showLogin: Bool = false
    @Published private var cookie: String?
    @UserDefaultable(key: DefaultKeys.pastSearches) private(set) var pastSearches: [String] = ["Plants", "Tools"]
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var showFreeOnly: Bool = true
    
    @Published var items: [MarketplaceItem] = []
    @Published private var _searchText: String = ""
    
    @Published var showAlertConfig: Bool = false
    @Published var alertItems: [MarketplaceItem] = []
    private(set) var alertCancellables: Set<AnyCancellable> = .init()
    @UserDefaultable(key: DefaultKeys.alerts) private(set) var alerts: [MarketplaceAlert] = []
    @UserDefaultable(key: DefaultKeys.seenAlerts) private var seenAlerts: [String] = []
    var badgeCount: Int { alertItems.filter { !seenAlerts.contains($0.id) }.count }
    
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
    }
    
    func getAlertItems() {
        self.alertItems = []
        onBG {
            self.alerts.forEach {
                self.getItems(for: $0.query, freeOnly: $0.onlyFree, page: nil)?
                    .sink(receiveCompletion: { completion in
                        switch completion {
                        case .failure(let error): print("ERROR:", error.localizedDescription)
                        case .finished: break
                        }
                    }, receiveValue: { (items, _) in
                        let newAlerts: [MarketplaceItem] = items.filter {
                            guard let id = $0.listing?.id else { return false }
                            return !self.seenAlerts.contains(id)
                        }.compactMap {
                            guard let listing = $0.listing else { return nil }
                            return self.item(from: listing)
                        }
                        
                        onMain {
                            self.alertItems = (self.alertItems + newAlerts).unique
                        }
                    })
                    .store(in: &self.alertCancellables)
            }
        }
    }
    
    func onAppear() {
        let store = WKWebsiteDataStore.default()
        Task {
            let cookie = store.marketPlaceCookie()
            DispatchQueue.main.async {
                self.cookie = cookie
                self.showLogin = self.cookie == nil
                self.getAlertItems()
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
    
    private func item(from listing: MarketplaceSearchResponse.Listing) -> MarketplaceItem {
        return .init(
            facebookID: listing.id,
            title: listing.marketplace_listing_title,
            price: self.currencyFormatter.string(from: listing.listing_price.amount.mapped as NSNumber) ?? "ERROR",
            imageURL: listing.primary_listing_photo.image.uri
        )
    }
    
    func search(for query: String, page: MarketplaceSearchResponse.PageInfo?) {
        guard !query.isEmpty else { items = []; return }
        
        nextPageInfo = page
        searchRequest?.cancel()
        isLoading = true
        
        searchRequest = getItems(for: query, freeOnly: showFreeOnly, page: page)?
            .receive(on: RunLoop.main).sink { completion in
            switch completion {
            case .finished:
                self.addPastSearch(query)
                self.isLoading = false
            case let .failure(error):
                self.alert = .init(title: "Error searching", message: error.localizedDescription)
            }
        } receiveValue: { response in
            self.nextPageInfo = response.1
            let items: [MarketplaceItem] = response.0
                .compactMap { $0.listing }
                .if(self.showFreeOnly) { items in items.filter { $0.listing_price.amount.mapped == 0 }  }
                .sorted { $0.listing_price.amount.mapped < $1.listing_price.amount.mapped }.map {
                    self.item(from: $0)
                }
            
            let isLastPage = response.0.contains(where: {
                $0.__typename == "MarketplaceSearchFeedEndOfResults"
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
    
    private func getItems(for query: String, freeOnly: Bool, page: MarketplaceSearchResponse.PageInfo?) -> AnyPublisher<([MarketplaceSearchResponse.Node], MarketplaceSearchResponse.PageInfo), APIError>? {
        guard let cookie = cookie else { return nil }
        
        return client.makeRequest(
            MarketplaceRequest.search(query, page: page, cookie: cookie), for: MarketplaceSearchResponse.self
        ).map {
            (
                $0.data.marketplace_search.feed_units.edges.map { $0.node },
                $0.data.marketplace_search.feed_units.page_info
            )
        }.map {
            if freeOnly {
                ($0.0.filter { i in i.listing?.listing_price.amount.mapped == 0 }, $0.1)
            } else {
                $0
            }
        }.eraseToAnyPublisher()
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
    
    func alertSwiped(_ alert: MarketplaceItem, direction: LeftRight) {
        objectWillChange.send()
        seenAlerts.append(alert.id)
        
        switch direction {
        case .left: 
            break
        case .right:
            urlToShow = alert.marketplaceURL
        }
    }
}
