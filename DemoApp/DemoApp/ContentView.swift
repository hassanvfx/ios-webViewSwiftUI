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
