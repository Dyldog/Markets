//
//  Facebook.swift
//  Markets
//
//  Created by Dylan Elliott on 18/11/2023.
//

import Foundation

enum Facebook {
    static func sanitise(_ text: String) -> String {
        text.addingPercentEncoding(
            withAllowedCharacters: .alphanumerics
                .union(NSCharacterSet(charactersIn: "_.") as CharacterSet)
        )!
    }
    
    private static func variables(_ query: String, with page: MarketplaceSearchResponse.PageInfo?) -> String {
       if let page = page {
            return sanitise(Secrets.Facebook.marketplaceVariablesOtherPages(
                page.end_cursor.replacingOccurrences(of: "\"", with: "\\\""),
                query
            ))
        } else {
            return sanitise(Secrets.Facebook.marketplaceVariablesPageOne(query))
        }
    }
        
    static func marketplaceQuery(_ query: String, page: MarketplaceSearchResponse.PageInfo?) -> String {
        return Secrets.Facebook.marketplaceQuery(variables(query, with: page))
//                .replacingOccurrences(of: "\n", with: "&")
    }
}
