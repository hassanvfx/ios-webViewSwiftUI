//
//  ContentView.swift
//  DemoApp
//
//  Created by hassan uriostegui on 8/30/22.
//

import Lux
import SwiftUI
import WebViewSwiftUI

struct ContentView: View {
    @StateObject var website = WebViewStore()
    let baseURL=URL(string:"https://www.spree3d.com")!
    
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
