//
//  WKWebsiteDataStore.swift
//  Markets
//
//  Created by Dylan Elliott on 18/11/2023.
//

import WebKit

struct Cookie {
    let values: [String: String]
    
    var string: String {
        values.map { "\($0.key)=\($0.value)"}.joined(separator: "; ")
    }
}

extension WKWebsiteDataStore {
    func marketPlaceCookie() -> Cookie? {
        let group = DispatchGroup()
        
        var cookie: Cookie?
        group.enter()
        
        DispatchQueue.main.async {
            self.httpCookieStore.getAllCookies { cookies in
                cookie = .init(values: cookies.reduce(into: [:], { partialResult, next in
                    partialResult[next.name] = next.value
                }))
                group.leave()
            }
        }
        
        group.wait()
        
        return cookie
    }
}

extension WKWebView {
    var marketPlaceCookie: Cookie? {
        let group = DispatchGroup()
        
        var cookie: Cookie?
        group.enter()
        
        DispatchQueue.main.async {
            cookie = self.configuration.websiteDataStore.marketPlaceCookie()
        }
        
        group.wait()
        
        return cookie
    }
}
