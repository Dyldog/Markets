//
//  MarketplaceItem.swift
//  Markets
//
//  Created by Dylan Elliott on 18/11/2023.
//

import Foundation

struct MarketplaceItem: Identifiable {
    var id: String { facebookID }
    let facebookID: String
    let title: String
    let price: String
    let imageURL: URL
    
    var marketplaceURL: URL {
        URL(string: "https://www.facebook.com/marketplace/item/\(facebookID)")!
    }
}
