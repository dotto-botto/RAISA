//
//  ContentView.swift
//  SCP Wiki Utility
//
//  Created by Maximus Harding on 12/25/22.
//

import SwiftUI

struct ContentView: View {
    @State var toArticle = false
    var body: some View {
        TabView {
            VStack {
                ExploreView()
                Spacer()
                ArticleBar().frame(height: 45)
            }.tabItem { Label("TABBAR_EXPLORE", systemImage: "globe") }
            VStack {
                ListView()
                Spacer()
                ArticleBar().frame(height: 45)
            }.tabItem { Label("TABBAR_LIST", systemImage: "bookmark")  }
            VStack {
                SearchView()
                Spacer()
                ArticleBar().frame(height: 45)
            }.tabItem { Label("TABBAR_SEARCH", systemImage: "magnifyingglass")  }
            VStack {
                HistoryView()
                Spacer()
                ArticleBar().frame(height: 45)
            }.tabItem { Label("TABBAR_HISTORY", systemImage: "clock")  }
            VStack {
                SettingsView()
                Spacer()
                ArticleBar().frame(height: 45)
            }.tabItem { Label("TABBAR_SETTINGS", systemImage: "gearshape")}
        }
//        .sheet(isPresented: $toArticle) {
//            NavigationView {
//                ArticleView(scp: Article(title: "Hello", pagesource: "content"))
//            }
//        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
