# WebViewSwiftUI

WebViewSwiftUI is an innovative SwiftUI wrapper for `WKWebView`, designed to seamlessly integrate web content within your SwiftUI applications. This framework allows for easy webpage loading, sophisticated navigation controls, and enhanced web interactions, all within the SwiftUI paradigm.

## Features

- **Simplified WebView Integration**: Integrate web views into SwiftUI with minimal boilerplate code.
- **Navigation Control**: Navigate forward and backward through web pages with easy-to-use SwiftUI views.
- **Progress Display**: Visually represent page load progress within your app.
- **Dynamic Loading**: Conditionally load or reload web pages based on app logic.
- **Custom Link Handling**: Intercept link navigation to implement custom logic, such as opening links externally or showing alerts.

## Usage
Here's a quick start guide to embed a web view into your SwiftUI view:

```swift
import Lux
import SwiftUI
import WebViewSwiftUI

struct ContentView: View {
    @StateObject var website = WebViewStore()
    let baseURL = URL(string: "https://www.google.com")!
    
    var body: some View {
        VStack {
            NavigatorNavBar(webViewStore: website)
            LoaderNavBar(webViewStore: website)
            BrowserView(webViewStore: website)
                .onAppear {
                    configWebsite()
                }
        }
    }
    
    func configWebsite() {
        website.setLinkHandler { url in
            let alert = UIAlertController(title: "Intercepted", message: "Allowed nav intent to:\(url)", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default))
            UIApplication.shared.present(alert, animated: true)
            
            return .allow
        }
        DispatchQueue.main.async {
            self.website.loadIfNeeded(url: baseURL)
        }
    }
}
```

## Advanced Customizations

The framework provides several SwiftUI views for specific purposes, such as BrowserBackView for a custom back navigation view, and LoaderNavBar for displaying loading progress. It also supports advanced web view manipulations like JavaScript injection and HTML content retrieval.



