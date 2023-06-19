//
//  ContentView.swift
//  SCP Wiki Utility
//
//  Created by Maximus Harding on 12/25/22.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("articleBarIds") var articles = "" // ids separated by whitespace
    @StateObject var networkMonitor = NetworkMonitor()
    @State private var selection: Int = 0
    var body: some View {
        TabView(selection: $selection) {
            VStack {
                ExploreView()
                ArticleBar()
            }.tabItem { Label("TABBAR_EXPLORE", systemImage: "globe") }
                .tag(0)
            VStack {
                ListView()
                ArticleBar()
            }.tabItem { Label("TABBAR_LIST", systemImage: "bookmark")  }
                .tag(1)
            VStack {
                SearchView()
                ArticleBar()
            }.tabItem { Label("TABBAR_SEARCH", systemImage: "magnifyingglass")  }
            VStack {
                HistoryView()
                ArticleBar()
            }.tabItem { Label("TABBAR_HISTORY", systemImage: "clock")  }
        }
        .onAppear {
            selection = networkMonitor.isConnected ? 0 : 1
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
