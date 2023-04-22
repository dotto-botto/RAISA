//
//  ContentView.swift
//  SCP Wiki Utility
//
//  Created by Maximus Harding on 12/25/22.
//

import SwiftUI

struct ContentView: View {
    @State private var toArticle: Bool = false
    @State private var resumeReading: Bool = false
    
    let con = PersistenceController.shared
    let defaults = UserDefaults.standard
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
        }
        .fullScreenCover(isPresented: $resumeReading) {
            if let history = con.getLatestHistory() {
                if let article = con.getArticleByTitle(title: history.articletitle ?? "") {
                    NavigationStack { ArticleView(scp: Article(fromEntity: article)!) }
                }
            }
        }
        .onAppear {
            if let history = con.getLatestHistory() {
                if defaults.bool(forKey: "autoOpen") && (con.getArticleByTitle(title: history.articletitle ?? "") != nil) {
                    resumeReading = true
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
