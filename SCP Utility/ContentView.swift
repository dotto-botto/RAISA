//
//  ContentView.swift
//  SCP Wiki Utility
//
//  Created by Maximus Harding on 12/25/22.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        let ids = UserDefaults.standard.string(forKey: "articleBarIds") ?? ""
        let frameSize: CGFloat = ids.isEmpty ? 0 : 40
        
        TabView {
            VStack {
                ExploreView()
                ArticleBar().frame(height: frameSize)
            }.tabItem { Label("TABBAR_EXPLORE", systemImage: "globe") }
            VStack {
                ListView()
                ArticleBar().frame(height: frameSize)
            }.tabItem { Label("TABBAR_LIST", systemImage: "bookmark")  }
            VStack {
                SearchView()
                ArticleBar().frame(height: frameSize)
            }.tabItem { Label("TABBAR_SEARCH", systemImage: "magnifyingglass")  }
            VStack {
                HistoryView()
                ArticleBar().frame(height: frameSize)
            }.tabItem { Label("TABBAR_HISTORY", systemImage: "clock")  }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
