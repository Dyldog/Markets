//
//  MarketplaceRoutes.swift
//  Markets
//
//  Created by Dylan Elliott on 23/11/2023.
//

import Foundation

struct FailableDecodable<Base : Decodable> : Decodable {

    let base: Base?

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.base = try? container.decode(Base.self)
    }
}

struct MarketplacePreloader: Decodable {
    let queryID: String
}

struct MarketplaceRoute: Decodable {
    let preloaders: [FailableDecodable<MarketplacePreloader>]
}

struct MarketplaceRoutes: Decodable {
    enum CodingKeys {
        case preloaders
    }
    
    let route: String
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let routes = try container.decode([FailableDecodable<MarketplaceRoute>].self)
        let ids = routes.compactMap { $0.base }.flatMap { $0.preloaders }.compactMap { $0.base?.queryID }
        guard let value = ids.last else {
            throw DecodingError.valueNotFound(
                MarketplacePreloader.self, .init(codingPath: [], debugDescription: "")
            )
        }
        
        route = value
    }
}
