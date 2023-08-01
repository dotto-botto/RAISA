//
//  ContentView.swift
//  SCP Wiki Utility
//
//  Created by Maximus Harding on 12/25/22.
//

import SwiftUI

struct ContentView: View {
    private let bar = ArticleBar()
    var body: some View {
        TabView {
            VStack {
                ExploreView()
                bar
            }.tabItem { Label("TABBAR_EXPLORE", systemImage: "globe") }
            VStack {
                ListView()
                bar
            }.tabItem { Label("TABBAR_LIST", systemImage: "bookmark")  }
            VStack {
                SearchView()
                bar
            }.tabItem { Label("TABBAR_SEARCH", systemImage: "magnifyingglass")  }
            VStack {
                HistoryView()
                bar
            }.tabItem { Label("TABBAR_HISTORY", systemImage: "clock")  }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
