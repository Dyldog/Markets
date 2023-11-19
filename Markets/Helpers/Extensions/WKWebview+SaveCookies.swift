//
//  WKWebview+SaveCookies.swift
//  Markets
//
//  Created by Dylan Elliott on 18/11/2023.
//

import WebKit

extension WKWebView {
    func saveCookies() {
        configuration.processPool = .init()
    }
}
