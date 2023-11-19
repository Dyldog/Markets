//
//  URL+Identifiable.swift
//  Markets
//
//  Created by Dylan Elliott on 18/11/2023.
//

import Foundation

extension URL: Identifiable {
    public var id: String { absoluteString }
}
