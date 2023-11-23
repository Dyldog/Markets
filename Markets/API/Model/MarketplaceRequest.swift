//
//  MarketplaceRequest.swift
//  Markets
//
//  Created by Dylan Elliott on 18/11/2023.
//

import Foundation

enum MarketplaceRequest: APIRequest {
    var baseURL: URL { .init(string: "https://www.facebook.com")! }
    
    var headers: [String : String]? {
        switch self {
        case let .search(_, _, cookie, _), let .routeDefinitions(cookie): return [
            "Cookie": cookie.string
        ] }
    }
    
    var path: String {
        switch self {
        case .search: return "api/graphql"
        case .routeDefinitions: return "ajax/route-definition"
        }
    }
    
    var method: HTTPMethod { .post }
    
    var body: Encodable? {
        switch self {
        case let .search(query, page, cookie, route):
            let b = Facebook.marketplaceQuery(
                query.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!, 
                cookie: cookie, 
                page: page,
                route: route
            )
            return b
        case let .routeDefinitions(cookie):
            return """
            client_previous_actor_id=\(cookie.values["c_user"]!)
            route_url=\(Facebook.sanitise("/marketplace/melbourne/search/?query=stuff"))
            routing_namespace=fb_comet
            trace_policy=comet.marketplace.item
            __user=\(cookie.values["c_user"]!)
            __a=1
            __req=j
            __csr=\(Secrets.Facebook.csr)
            fb_dtsg=\(Secrets.Facebook.fb_dtsg)
            """
            .replacingOccurrences(of: "\n", with: "&")
        }
        
    }
    
    case search(String, page: MarketplaceSearchResponse.PageInfo?, cookie: Cookie, route: String)
    case routeDefinitions(cookie: Cookie)
}
