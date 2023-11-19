//
//  MarketplaceRequest.swift
//  Markets
//
//  Created by Dylan Elliott on 18/11/2023.
//

import Foundation

enum MarketplaceRequest: APIRequest {
    var baseURL: URL { .init(string: "https://www.facebook.com/api")! }
    
    var headers: [String : String]? {
        switch self {
        case let .search(_, _, cookie): return [
        "Cookie": cookie
        ] }
    }
    
    var path: String {
        switch self {
        case .search: return "graphql"
        }
    }
    
    var method: HTTPMethod { .post }
    
    var body: Encodable? {
        switch self {
        case let .search(query, page, _): 
            let b = Facebook.marketplaceQuery(
                query.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!, page: page
            )
            return b
        }
        
    }
    
    case search(String, page: MarketplaceSearchResponse.PageInfo?, cookie: String)
}