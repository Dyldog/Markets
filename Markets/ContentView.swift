//
//  ContentView.swift
//  Markets
//
//  Created by Dylan Elliott on 20/10/2022.
//

import SwiftUI
import AQBoksMoks
import Combine

protocol StringMappable {
    init?(_ string: String)
}

extension Float: StringMappable { }

struct StringMapped<T: StringMappable>: Decodable {
    let unmapped: String // unmapped
    var mapped: T { T.init(unmapped)! }
    
    init(string: String) {
        unmapped = string
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self = StringMapped(string: try container.decode(String.self))
    }
}

struct MarketplaceSearchResponse: Decodable {
    let data: SearchData
}

extension MarketplaceSearchResponse {
    struct SearchData: Decodable {
        let marketplace_search: MarketplaceSearch
    }
}

extension MarketplaceSearchResponse {
    struct MarketplaceSearch: Decodable {
        let feed_units: FeedUnits
    }
}

extension MarketplaceSearchResponse {
    struct FeedUnits: Decodable {
        let edges: [Edge]
    }
}

extension MarketplaceSearchResponse {
    struct Edge: Decodable {
        let node: Node
    }
}

extension MarketplaceSearchResponse {
    struct Node: Decodable {
        let __typename: String
        let listing: Listing?
    }
}

extension MarketplaceSearchResponse {
    struct Listing: Decodable {
        let id: String
        let marketplace_listing_title: String
        let listing_price: ListingPrice
        let primary_listing_photo: ListingPhoto
    }
}

extension MarketplaceSearchResponse {
    struct ListingPhoto: Decodable {
        let image: ListingPhotoImage
    }
}

extension MarketplaceSearchResponse {
    struct ListingPhotoImage: Decodable {
        let uri: URL
    }
}

extension MarketplaceSearchResponse {
    struct ListingPrice: Decodable {
        let amount: StringMapped<Float>
    }
}
enum MarketplaceRequest: APIRequest {
    var baseURL: URL { .init(string: "https://www.facebook.com/api")! }
    
    var headers: [String : String] { [
        "Content-Type": "application/x-www-form-urlencoded",
        "Accept": "*/*",
        "Accept-Language": "en-AU,en;q=0.9",
        "Accept-Encoding": "gzip, deflate, br",
        "Host": "www.facebook.com",
        "Origin": "https://www.facebook.com",
        "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.5 Safari/605.1.15",
        "Referer": "https://www.facebook.com/marketplace/melbourne/search/?query=SEARCHES",
        "Content-Length": "2538",
        "Connection": "keep-alive",
        "Cookie": "wd=1440x295; presence=C%7B%22t3%22%3A%5B%7B%22i%22%3A%22g.5141063269329258%22%7D%2C%7B%22i%22%3A%22g.5408676519231262%22%7D%5D%2C%22utc3%22%3A1666230455408%2C%22v%22%3A1%7D; c_user=1653765454; fr=0JXTpS7qKgQ0V70nx.AWXMPa52b3ZbAll_d6rL0pWfapw.BjUKQx.gJ.AAA.0.0.BjUKib.AWUIQFz-jMs; sb=3fmmYTJf9RKL2tfFvBWJQb6D; xs=41%3AEfpdk1PFA6ugZQ%3A2%3A1666230427%3A-1%3A2815; locale=en_US; usida=eyJ2ZXIiOjEsImlkIjoiQXJrMTJyNWM1dmphYyIsInRpbWUiOjE2NjYyMjk1MjV9; dpr=2; m_pixel_ratio=2; datr=4vmmYdeob_E9f9AOVIesC0xb",
        "X-FB-LSD": "kC04_k6MfLJdCKHMnh39YV",
        "X-FB-Friendly-Name": "CometMarketplaceSearchContentContainerQuery",
        "Priority": "u=3, i",
    ] }
    
    var path: String {
        switch self {
        case .search: return "graphql"
        }
    }
    
    var method: HTTPMethod { .post }
    
    var body: Encodable? {
        switch self {
        case let .search(query, page): return "av=1653765454&__user=1653765454&__a=1&__dyn=7AzHJ16U9ob8ng5K8G6EjBWo2nDwAxu13wvoJ3odE98K360CEboG4E762S1DwUx60GE3Qwb-q7oc81xoswMwto886C11xmfz81sbzoaEnxO0Bo7O2l2Utwqo31wiEjwZwlo5qfK6E7e58jwGzE7W7oqBwJK2W5olwUwgojUlDw-wUwxwjFovUaU3VBwJCwLyESE2KwkQq0xoc84K2e3u362-2B0oobo&__csr=glTv9b9RiWplVt8yvi4neJQF7bkLQiyt9-nsG9tPsBaOd7vsWFaRiHvL8GZARteXDBTDTqgx3Hyeb9GlZXyVa-Vp9Uyjy6V9Ey9ABh48gx5zayUV2HyqBwzUG9y8jxm68iCxei4UlxyieK598K5UC1vz8nyodU7G5pUbElwgU2ny89oowUwbS0Ko6m5E7Ci2a1BwByorz40li1mJ0Twci0CEhw2rE09EU02-7w1a-0P83Cxu07no0EO05s80o7WwhU5e9w0Huw0Jtw1Ce0bbwDw&__req=1f&__hs=19285.HYP%3Acomet_pkg.2.1.0.2.1&dpr=2&__ccg=EXCELLENT&__rev=1006426792&__s=wj38lb%3A76fe7c%3Agohq1s&__hsi=7156438079762160840&__comet_req=15&fb_dtsg=NAcMX8Y5sITTO8BQBkazwSeLtYLNyFvLVbUGUew1_pj82xvW5fgExDA%3A41%3A1666230427&jazoest=25510&lsd=zuOMSh8n8H26VoQm7TnrBR&__aaid=42733444&__spin_r=1006426792&__spin_b=trunk&__spin_t=1666238084&fb_api_caller_class=RelayModern&fb_api_req_friendly_name=CometMarketplaceSearchContentContainerQuery&variables=%7B%22buyLocation%22%3A%7B%22latitude%22%3A-37.769%2C%22longitude%22%3A144.9956%7D%2C%22contextual_data%22%3Anull%2C%22count%22%3A24%2C%22cursor%22%3Anull%2C%22flashSaleEventID%22%3A%22%22%2C%22hasFlashSaleEventID%22%3Afalse%2C%22marketplaceSearchMetadataCardEnabled%22%3Afalse%2C%22params%22%3A%7B%22bqf%22%3A%7B%22callsite%22%3A%22COMMERCE_MKTPLACE_WWW%22%2C%22query%22%3A%22\(query)%22%7D%2C%22browse_request_params%22%3A%7B%22commerce_enable_local_pickup%22%3Atrue%2C%22commerce_enable_shipping%22%3Atrue%2C%22commerce_search_and_rp_available%22%3Atrue%2C%22commerce_search_and_rp_category_id%22%3A%5B%5D%2C%22commerce_search_and_rp_condition%22%3Anull%2C%22commerce_search_and_rp_ctime_days%22%3Anull%2C%22filter_location_latitude%22%3A-37.769%2C%22filter_location_longitude%22%3A144.9956%2C%22filter_price_lower_bound%22%3A0%2C%22filter_price_upper_bound%22%3A214748364700%2C%22filter_radius_km%22%3A2%7D%2C%22custom_request_params%22%3A%7B%22browse_context%22%3Anull%2C%22contextual_filters%22%3A%5B%5D%2C%22referral_code%22%3Anull%2C%22saved_search_strid%22%3Anull%2C%22search_vertical%22%3A%22C2C%22%2C%22seo_url%22%3Anull%2C%22surface%22%3A%22SEARCH%22%2C%22virtual_contextual_filters%22%3A%5B%5D%7D%7D%2C%22savedSearchID%22%3Anull%2C%22savedSearchQuery%22%3A%22\(query)%22%2C%22scale%22%3A2%2C%22shouldIncludePopularSearches%22%3Afalse%2C%22topicPageParams%22%3A%7B%22location_id%22%3A%22melbourne%22%2C%22url%22%3Anull%7D%2C%22vehicleParams%22%3A%22%22%7D&server_timestamps=true&doc_id=5851968321514267"
        }
        
    }
    
    case search(String, page: Int)
}

struct MarketplaceItem: Identifiable {
    let id: String = UUID().uuidString
    let facebookID: String
    let title: String
    let price: String
    let imageURL: URL
    
    var marketplaceURL: URL {
        URL(string: "https://www.facebook.com/marketplace/item/\(facebookID)")!
    }
}

class ViewModel: NSObject, ObservableObject {
    
    let client = APIClient()
    var cancellables: Set<AnyCancellable> = .init()
    
    var currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        return formatter
    }()
    
    @Published var items: [MarketplaceItem] = []
    @objc dynamic var searchText: String = ""
    var currentPage: Int = 0
    
    override init() {
        super.init()
        search(for: "CHAIRS")
        
        publisher(for: \.searchText)
            .compactMap { $0 }
            .throttle(for: 1.0, scheduler: RunLoop.main, latest: true)
            .sink { [weak self] in
                self?.search(for: $0, page: 0)
            }.store(in: &cancellables)
    }
    
    func search(for query: String, page: Int = 0) {
        currentPage = page
        
        client.makeRequest(MarketplaceRequest.search(query, page: page), for: MarketplaceSearchResponse.self)
            .receive(on: RunLoop.main).sink { completion in
            switch completion {
            case .finished: break
            case let .failure(error): print("ERROR: \(error.localizedDescription)")
            }
        } receiveValue: { response in
            let items: [MarketplaceItem] = response.data.marketplace_search.feed_units.edges.compactMap {
                $0.node.listing
            }.sorted { $0.listing_price.amount.mapped < $1.listing_price.amount.mapped }.map {
                .init(
                    facebookID: $0.id,
                    title: $0.marketplace_listing_title,
                    price: self.currencyFormatter.string(from: $0.listing_price.amount.mapped as NSNumber) ?? "ERROR",
                    imageURL: $0.primary_listing_photo.image.uri
                )
            }
            
            if page == 0 {
                self.items = items
            } else {
                self.items += items
            }
        }
        .store(in: &cancellables)
    }
    
    private func loadNextPage() {
        search(for: searchText, page: currentPage + 1)
    }
    
    func itemAppeared(_ item: MarketplaceItem) {
        guard let idx = items.firstIndex(where: { $0.id == item.id }) else { return }
        
        if (items.count - 1) <= idx {
            loadNextPage()
        }
    }
}

extension URL: Identifiable {
    public var id: String { absoluteString }
}

import WKView

struct ContentView: View {
    @State var urlToShow: URL?
    @StateObject var viewModel: ViewModel = .init()
    var body: some View {
        ScrollView {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), alignment: .top), count: 3)) {
                ForEach(viewModel.items) { item in
                    Button {
                        urlToShow = item.marketplaceURL
                    } label: {
                        VStack {
                            URLImage(url: item.imageURL.absoluteString)
                                .cornerRadius(8)
                            Text(item.title)
                                .font(.system(size: 12, weight: .regular))
                            Text(item.price)
                                .font(.system(size: 12, weight: .regular))
                            Spacer()
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .sheet(item: $urlToShow, content: { url in
                NavigationView {
                    WebView(url: url.absoluteString, hidesBackButton: true)
                }
            })
            .padding(.horizontal)
            .searchable(text: $viewModel.searchText)
        }
        .navigationTitle("Marketplace")
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
