//
//  FailableDecodable.swift
//  Markets
//
//  Created by Dylan Elliott on 25/11/2023.
//

import Foundation

struct FailableDecodable<Base : Decodable> : Decodable {

    let base: Base?

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.base = try? container.decode(Base.self)
    }
}
