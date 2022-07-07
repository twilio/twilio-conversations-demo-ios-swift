//
//  WebView.swift
//  ConversationsApp
//
//  Created by Robert Ziehl on 2022-05-26.
//  Copyright © 2022 Twilio, Inc. All rights reserved.
//

// From: https://www.appcoda.com/swiftui-wkwebview/

import SwiftUI
import WebKit
 
struct WebView: UIViewRepresentable {
    var url: URL
 
    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }
 
    func updateUIView(_ webView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        webView.load(request)
    }
}
