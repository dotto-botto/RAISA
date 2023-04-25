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
    let url = UserDefaults.standard.url(forKey: "lastReadUrl")
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
            if let articleItem = con.getArticleByURL(url: url!) {
                NavigationStack { ArticleView(scp: Article(fromEntity: articleItem)!) }
            }
        }
        .onAppear {
            if url != nil {
                if defaults.bool(forKey: "autoOpen") && (con.isArticleSaved(url: url!) ?? false) {
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
