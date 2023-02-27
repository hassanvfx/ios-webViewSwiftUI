//
//  MainMenu.swift
//  Styling
//
//  Created by Mark C. Maxwell on The New Lux
//  Copyright © 2020. All rights reserved.
//

import Lux
import SwiftUI

public struct BrowserBackView: View {
    @ObservedObject var browser: WebViewStore
    
    public init(browser: WebViewStore) {
        self.browser = browser
    }
    
    public var body: some View {
        lux.draw.surfaceComposition
        .overlay(
                Column {
                    ActivityIndicator()
                        .frame(width: 66, height: 66)
                }
            )
            .onTapGesture {
                self.browser.reload()
            }
    }
}

public struct BrowserView: View {
    @ObservedObject var webViewStore: WebViewStore

    public init(webViewStore: WebViewStore) {
        self.webViewStore = webViewStore
    }
    public var body: some View {
        WebView(webView: self.webViewStore.webView)
            .opacity(self.webViewStore.webView.isLoading ? 0.8 : 1.0)
            .animation(.easeInOut,value:true)
            .background(BrowserBackView(browser: self.webViewStore))
    }
}

public struct LoaderNavBar: View {
    @ObservedObject var webViewStore: WebViewStore
    
    public init(webViewStore: WebViewStore) {
    self.webViewStore = webViewStore
    }
    
    public var body: some View {
        Row {
            Spacer()
        }
        .frame(height: 2)
        .background(
            Rectangle()
                .fill(self.lux.spec.surface.active)
                .allowsHitTesting(false)
                .disabled(true)
                .scaleEffect(self.webViewStore.progress)
        )
        .frame(height: 2)
        .clipped()
    }
}

public struct NavigatorNavBar: View {
    @ObservedObject var webViewStore: WebViewStore

    public init(webViewStore: WebViewStore) {
    self.webViewStore = webViewStore
    }
    
    var title: String {
        (webViewStore.webView.title ?? "Lux News").replacingOccurrences(of: "– Medium", with: "").replacingOccurrences(of: "- Medium", with: "").replacingOccurrences(of: "Medium", with: "")
    }

    public var body: some View {
        Row {
            Button(action: { self.webViewStore.webView.goBack() }) {
                Image(systemName: "chevron.left")
                    .lux
                    .style(.iconLarge)
                    .unless(self.webViewStore.webView.canGoBack) { $0.feature(.invisible) }
                    .feature(.rectangularContentShape)
                    .view
            }

            Text(self.title)
                .bold()
                .lineLimit(1)
                .modifier(FitFontToWidth(font: self.lux.spec.font.active, minSize: self.lux.spec.font.captionSize, maxSize: self.lux.spec.font.bodySize))
                .truncationMode(.middle)
                .lux
                .feature(.flexibleWidth)
                .tweak(.captionLayout)
                .style(.paragraphBlock)
                .view
                .animation(.none)

            Button(action: { self.webViewStore.webView.goForward() }) {
                Image(systemName: "chevron.right")
                    .lux
                    .style(.iconLarge)
                    .unless(self.webViewStore.webView.canGoForward) { $0.feature(.invisible) }
                    .feature(.rectangularContentShape)
                    .view
            }
        }
    }
}
