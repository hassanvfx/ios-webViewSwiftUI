//
//  WebViewUI.swift
//  Styling
//
//  Created by Mark C. Maxwell on The New Lux
//  Copyright © 2020. All rights reserved.


import Combine
import SwiftUI
import WebKit

public class WebViewStore: NSObject, ObservableObject,WKNavigationDelegate {
    public enum LinkReaction{
        case allow
        case openExternal
        case deny
    }
    var rootURLString: String
    var initialLoad = false
    var linkHandler: ((URL) -> LinkReaction)?
    var allowedPrefixes: [String] = []
    private var observers: [NSKeyValueObservation] = []

    deinit {
        invalidateObservers()
    }
    
    public init(rootURLString: String, linkHandler:((URL) -> LinkReaction)? = nil, webView: WKWebView? = nil) {
        self.webView = webView ?? WKWebView()
        self.linkHandler = linkHandler
        self.rootURLString = rootURLString
        super.init()
        self.webView.allowsBackForwardNavigationGestures = true
        setupObservers()
    }
    
    @Published public var webView: WKWebView {
        didSet {
            setupObservers()
        }
    }
}

extension WebViewStore{
    private func invalidateObservers(){
        observers.forEach {
            $0.invalidate()
        }
    }
    private func setupObservers() {
        func subscriber<Value>(for keyPath: KeyPath<WKWebView, Value>) -> NSKeyValueObservation {
            return webView.observe(keyPath, options: [.prior]) { _, change in
                if change.isPrior {
                    self.objectWillChange.send()
                }
            }
        }
        invalidateObservers()
        observers = [
            subscriber(for: \.title),
            subscriber(for: \.url),
            subscriber(for: \.isLoading),
            subscriber(for: \.estimatedProgress),
            subscriber(for: \.hasOnlySecureContent),
            subscriber(for: \.serverTrust),
            subscriber(for: \.canGoBack),
            subscriber(for: \.canGoForward),
        ]
        
        webView.navigationDelegate = self
    }


}

/// A container for using a WKWebView in SwiftUI
public struct WebView: View, UIViewRepresentable {
    /// The WKWebView to display
    public let webView: WKWebView

    public typealias UIViewType = UIViewContainerView<WKWebView>

    public init(webView: WKWebView) {
        self.webView = webView
    }

    public func makeUIView(context _: UIViewRepresentableContext<WebView>) -> WebView.UIViewType {
        return UIViewContainerView()
    }

    public func updateUIView(_ uiView: WebView.UIViewType, context _: UIViewRepresentableContext<WebView>) {
        // If its the same content view we don't need to update.
        if uiView.contentView !== webView {
            uiView.contentView = webView

            webView.backgroundColor = .clear
            uiView.backgroundColor = .clear
        }
    }
}

/// A UIView which simply adds some view to its view hierarchy
public class UIViewContainerView<ContentView: UIView>: UIView {
    var contentView: ContentView? {
        willSet {
            contentView?.removeFromSuperview()
        }
        didSet {
            if let contentView = contentView {
                addSubview(contentView)
                contentView.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
                    contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
                    contentView.topAnchor.constraint(equalTo: topAnchor),
                    contentView.bottomAnchor.constraint(equalTo: bottomAnchor),
                ])
            }
        }
    }
}

extension WebViewStore {
    private var rootURL: URL {
        URL.optional(from: rootURLString)!
    }
    
    @objc public func load(url: URL) {
        if let scheme = url.scheme {
            allowedPrefixes.append(scheme)
        }

        DispatchQueue.main.async {
            self.webView.load(URLRequest(url: url))
        }
    }

    @objc public func reload() {
        DispatchQueue.main.async {
            self.webView.load(URLRequest(url: self.rootURL))
        }
    }

    @objc public func loadIfNeeded() {
        loadIfDisposed()

        guard initialLoad == false else { return }
        initialLoad = true

        reload()
    }

    @objc public func loadIfDisposed() {
        DispatchQueue.main.async {
            self.webView.evaluateJavaScript("document.querySelector('body').innerHTML") { [weak self] _, error in
                if error != nil {
                    self?.reload()
                }
            }
        }
    }

    var progress: CGFloat {
        1.0 - webView.estimatedProgress.cgFloat
    }
}


