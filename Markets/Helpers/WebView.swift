//
//  WebView.swift
//  Markets
//
//  Created by Dylan Elliott on 18/11/2023.
//

import SwiftUI
import WebKit

extension WKProcessPool {
    static var shared: WKProcessPool = .init()
}

class WebViewDelegator: NSObject, WKNavigationDelegate {
    let onLoad: ((WKWebView) -> Void)?
    
    init(onLoad: ((WKWebView) -> Void)?) {
        self.onLoad = onLoad
    }
    
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        print("DID COMMIT")
    }
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("DID_FAIL!")
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        onLoad?(webView)
    }
}
struct WebView: UIViewRepresentable {
    // 1
    let url: URL
    let delegate: WebViewDelegator
    
    init(url: URL, onLoad: ((WKWebView) -> Void)?) {
        self.url = url
        self.delegate = .init(onLoad: onLoad)
    }

    
    // 2
    func makeUIView(context: Context) -> WKWebView {
//        let config = WKWebViewConfiguration()
//        config.processPool = .shared
        let view = WKWebView()
        view.navigationDelegate = delegate
        return view
    }
    
    // 3
    func updateUIView(_ webView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        webView.customUserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.6.1 Safari/605.1.15"
        webView.load(request)
    }
}
