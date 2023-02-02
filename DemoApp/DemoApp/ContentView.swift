//
//  ContentView.swift
//  DemoApp
//
//  Created by hassan uriostegui on 8/30/22.
//

//import Lux
import SwiftUI
import WebViewSwiftUI

class ContentViewModel: NSObject, ObservableObject {
    @Published var website = WebViewStore(rootURLString: "https://google.com")
    
}

struct ContentView: View {
    @StateObject var model = ContentViewModel()
    
    var body: some View {
        VStack{
            WebNavigatorNavBar(webViewStore: model.website)
            WebLoaderBar(webViewStore: model.website)
            WebBrowserView(webViewStore: model.website)
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
