//
//  WebViewUI.swift
//  Styling
//
//  Created by Mark C. Maxwell on The New Lux
//  Copyright © 2020. All rights reserved.


import Combine
import SwiftUI
import WebKit

public class WebViewStore: NSObject, ObservableObject {
    var rootURLString: String
    var initialLoad = false
    var onExternalURL: ((URL) -> Void)?
    var allowedPrefixes: [String] = []

    @Published public var webView: WKWebView {
        didSet {
            setupObservers()
        }
    }

    public init(rootURLString: String, webView: WKWebView = WKWebView()) {
        self.webView = webView
        self.rootURLString = rootURLString
        super.init()
        self.webView.allowsBackForwardNavigationGestures = true
        setupObservers()
    }

    private func setupObservers() {
        func subscriber<Value>(for keyPath: KeyPath<WKWebView, Value>) -> NSKeyValueObservation {
            return webView.observe(keyPath, options: [.prior]) { _, change in
                if change.isPrior {
                    self.objectWillChange.send()
                }
            }
        }
        // Setup observers for all KVO compliant properties
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
    }

    private var observers: [NSKeyValueObservation] = []

    deinit {
        observers.forEach {
            // Not even sure if this is required?
            // Probably wont be needed in future betas?
            $0.invalidate()
        }
    }

    open var allowedURLPrefixes: [String] {
        allowedPrefixes +
            [
                "https://",
            ]
    }

    open var rootURL: URL {
        URL.optional(from: rootURLString)!
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
    @objc open func load(url: URL) {
        if let scheme = url.scheme {
            allowedPrefixes.append(scheme)
        }

        DispatchQueue.main.async {
            self.webView.load(URLRequest(url: url))
        }
    }

    @objc open func reload() {
        DispatchQueue.main.async {
            self.webView.load(URLRequest(url: self.rootURL))
        }
    }

    @objc open func loadIfNeeded() {
        loadIfDisposed()

        guard initialLoad == false else { return }
        initialLoad = true

        reload()
    }

    @objc open func loadIfDisposed() {
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

extension WebViewStore {
    func getHTML(completion: @escaping (String?) -> Void) {
        webView.evaluateJavaScript("document.documentElement.outerHTML.toString()",
                                   completionHandler: { (html: Any?, _: Error?) in
                                       completion(html as? String)
        })
    }
}

extension WebViewStore {
    func JSselectorComposableString(tag: String, value: String?, partial: Bool = true, caseInsensitive: Bool = true) -> String {
        let operation = partial ? "*=" : "="
        let caseConcern = caseInsensitive ? "i" : ""
        let selector = value == nil ? tag : "[\(tag)\(operation)\(value!) \(caseConcern)]"
        let script = "var result = document.querySelectorAll('\(selector)')"

        return script
    }
}

extension WebViewStore {
    func JSsearchFor(tag: String, value: String? = nil, partial: Bool = true, caseInsensitive: Bool = true, completion: @escaping (Bool) -> Void) {
        let selector = JSselectorComposableString(tag: tag, value: value, partial: partial, caseInsensitive: caseInsensitive)
        let result = "result.length > 0;"
        JSperformScript(script: selector, result) { completion($0 as! Bool) }
    }
}

extension WebViewStore {
    static let JSRemoveScriptSufix = ".forEach(e => e.parentNode.removeChild(e));"
    func JSremove(tag: String, value: String? = nil, partial: Bool = true, caseInsensitive: Bool = true, completion: @escaping (Bool) -> Void) {
        let remove = { [weak self] in

            guard let this = self else { return }

            let selector = this.JSselectorComposableString(tag: tag, value: value, partial: partial, caseInsensitive: caseInsensitive)
            let result = Self.JSRemoveScriptSufix
            let script = "\(selector)\(result)"

            this.JSperformScript(script: script) { _ in completion(true) }
        }

        JSsearchFor(tag: tag, value: value, partial: partial, caseInsensitive: caseInsensitive) { result in
            if result == false {
                assert(false, "Not found \(tag) or \(String(describing: value))")
                completion(false)
                return
            } else {
                remove()
            }
        }
    }
}

extension WebViewStore {
    typealias Completion = (Any?) -> Void
    func JSperformScript(script: String..., completion: Completion? = nil) {
        let singleScript = script.joined(separator: ";")
        webView
            .evaluateJavaScript(singleScript,
                                completionHandler: { (result: Any?, error: Error?) in
                                    assert(error == nil, "Script failed: '\(singleScript)'")
                                    completion?(result)
            })
    }
}

extension WebViewStore {
    func JSmakeScript(interval: CGFloat = 100, script: String) -> String {
        """
        var watcher = setInterval(function(){
        \(script)
        },\(interval));
        """
    }
}

extension WebViewStore {
    struct RemoveInfo {
        var tag: String
        var value: String?
    }
}

extension WebViewStore {
    open func resolve(navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let urlString = navigationAction.request.url?.absoluteString else {
            decisionHandler(.cancel)
            return
        }

        let match = allowedURLPrefixes.map { urlString.contains($0) }.reduce(true) { $0 && $1 }
        match ?
            decisionHandler(.allow)
            :
            decisionHandler(.cancel)

        if match == false,
            navigationAction.navigationType == .formSubmitted || navigationAction.navigationType == .linkActivated {
            openExternal(urlString: navigationAction.request.url?.absoluteString)
        }
    }

    func openExternal(urlString: String?) {
        guard
            let urlString = urlString,
            let url = URL.optional(from: urlString) else { return }

        onExternalURL?(url)
    }

    func openInShare() {
        guard let url = webView.url else { return }
        UIApplication.shared.open(url)
    }
}
