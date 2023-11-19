//
//  MarketplaceSearchResponse.swift
//  Markets
//
//  Created by Dylan Elliott on 18/11/2023.
//

import Foundation

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
        let page_info: PageInfo
    }
}

extension MarketplaceSearchResponse {
    struct PageInfo: Decodable {
        let end_cursor: String
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
