//
//  ContentView.swift
//  DemoApp
//
//  Created by hassan uriostegui on 8/30/22.
//

import Lux
import SwiftUI
import WebViewSwiftUI

class ContentViewModel: NSObject, ObservableObject {
    @Published var website = WebViewStore(rootURLString: "https://spree3d.com", linkHandler: ContentViewModel.linkHandler)
    
    static func linkHandler(_ url:URL)-> WebViewStore.LinkReaction{
  
        
        let alert = UIAlertController(title: "Intercepted", message: "allowed nav intent to:\(url)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { _ in
            
        }))
        UIApplication.present(alert)
        
        return .allow
    }
}

struct ContentView: View {
    @StateObject var model = ContentViewModel()
    
    var body: some View {
        VStack{
            NavigatorNavBar(webViewStore: model.website)
            LoaderNavBar(webViewStore: model.website)
            BrowserView(webViewStore: model.website)
                .onAppear {
                    model.website.loadIfNeeded()
                    
                }
            
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

extension UIApplication{
    static var rootVC: UIViewController {
            UIApplication.shared.windows.first!.rootViewController!
    }
    
    static func present(_ controller: UIViewController, animated _: Bool = true, completion: (() -> Void)? = nil) {
        DispatchQueue.main.async {
            guard UIApplication.rootVC.presentedViewController == nil else {
                UIApplication.rootVC.dismiss(animated: true) {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.500) {
                        UIApplication.rootVC.present(controller, animated: true) {
                            completion?()
                        }
                    }
                }
                return
            }
            
            UIApplication.rootVC.present(controller, animated: true) {
                completion?()
            }
        }
    }
}
