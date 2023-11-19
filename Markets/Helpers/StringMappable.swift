//
//  StringMappable.swift
//  Markets
//
//  Created by Dylan Elliott on 18/11/2023.
//

import Foundation

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
