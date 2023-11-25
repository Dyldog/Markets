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
            "Host": "www.facebook.com",
            "Accept": "*/*",
            "X-FB-LSD": "_CTdkG1o7COruGY2kyhemQ",
            "X-ASBD-ID": "129477",
            "X-FB-Friendly-Name": "CometMarketplaceSearchContentContainerQuery",
            "Sec-Fetch-Site": "same-origin",
            "Accept-Language": "en-AU,en;q=0.9",
            "Accept-Encoding": "gzip, deflate, br",
            "Sec-Fetch-Mode": "cors",
            "Content-Type": "application/x-www-form-urlencoded",
            "Origin": "https://www.facebook.com",
            "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.6 Safari/605.1.15",
            "Referer": "https://www.facebook.com/marketplace/melbourne/search?query=BOOP",
            "Content-Length": "2466",
            "Connection": "keep-alive",
            "Sec-Fetch-Dest": "empty",
            "Cookie": "\(cookie.string)"
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
            __csr=\(Secrets.csr.value)
            fb_dtsg=\(Secrets.fb_dtsg.value)
            """
            .replacingOccurrences(of: "\n", with: "&")
        }
        
    }
    
    case search(String, page: MarketplaceSearchResponse.PageInfo?, cookie: Cookie, route: String)
    case routeDefinitions(cookie: Cookie)
}
