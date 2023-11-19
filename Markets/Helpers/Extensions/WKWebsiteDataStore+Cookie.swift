//
//  WKWebsiteDataStore.swift
//  Markets
//
//  Created by Dylan Elliott on 18/11/2023.
//

import WebKit

extension WKWebsiteDataStore {
    func marketPlaceCookie() -> String? {
        let group = DispatchGroup()
        
        var cookie: String?
        group.enter()
        
        DispatchQueue.main.async {
            self.httpCookieStore.getAllCookies { cookies in
                cookie = cookies.map { "\($0.name)=\($0.value)"}.joined(separator: "; ")
                group.leave()
            }
        }
        
        group.wait()
        
        return cookie
    }
}

extension WKWebView {
    var marketPlaceCookie: String? {
        let group = DispatchGroup()
        
        var cookie: String?
        group.enter()
        
        DispatchQueue.main.async {
            cookie = self.configuration.websiteDataStore.marketPlaceCookie()
        }
        
        group.wait()
        
        return cookie
    }
}
