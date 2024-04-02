# SwiftUI WebView


Sample Implementation:

```swift
import SwiftUI
import WebViewSwiftUI

struct ContentView: View {
    @StateObject var website = WebViewStore()
    let baseURL=URL(string:"https://www.google.com")!
    
    var body: some View {
        VStack{
            NavigatorNavBar(webViewStore: website)
            LoaderNavBar(webViewStore: website)
            BrowserView(webViewStore: website)
                .onAppear {
                    configWebsite()
                }
            
        }
    }
    
    func configWebsite(){
        website.setLinkHandler{ url in
            let alert = UIAlertController(title: "Intercepted", message: "allowed nav intent to:\(url)", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { _ in
                
            }))
            UIApplication.present(alert)
            
            return .allow
        }
        DispatchQueue.main.async {
            self.website.loadIfNeeded(url:baseURL)
        }
        
    }
}
```

