//
//  ContentView.swift
//  SCP Wiki Utility
//
//  Created by Maximus Harding on 12/25/22.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            VStack {
                ExploreView()
                ArticleBar()
            }.tabItem { Label("TABBAR_EXPLORE", systemImage: "globe") }
            VStack {
                ListView()
                ArticleBar()
            }.tabItem { Label("TABBAR_LIST", systemImage: "bookmark")  }
            VStack {
                SearchView()
                ArticleBar()
            }.tabItem { Label("TABBAR_SEARCH", systemImage: "magnifyingglass")  }
            VStack {
                HistoryView()
                ArticleBar()
            }.tabItem { Label("TABBAR_HISTORY", systemImage: "clock")  }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
