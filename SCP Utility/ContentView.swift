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
        var offlineArticle: Article? = nil
        TabView {
            VStack {
                ExploreView()
                Spacer()
                ArticleBar()
            }.tabItem { Label("TABBAR_EXPLORE", systemImage: "globe") }
            VStack {
                ListView()
                Spacer()
                ArticleBar()
            }.tabItem { Label("TABBAR_LIST", systemImage: "bookmark")  }
            VStack {
                SearchView()
                Spacer()
                ArticleBar()
            }.tabItem { Label("TABBAR_SEARCH", systemImage: "magnifyingglass")  }
            VStack {
                HistoryView()
                Spacer()
                ArticleBar()
            }.tabItem { Label("TABBAR_HISTORY", systemImage: "clock")  }
        }
        .onAppear {
            if url != nil && defaults.bool(forKey: "autoOpen") {
                if con.isArticleSaved(url: url!) {
                    resumeReading = true
                } else {
                    cromAPISearchFromURL(query: url!) { article in
                        if article != nil {
                            offlineArticle = article
                            resumeReading = true
                        }
                    }
                }
            }
        }
        .fullScreenCover(isPresented: $resumeReading) {
            if let articleItem = con.getArticleByURL(url: url!) {
                NavigationStack { ArticleView(scp: Article(fromEntity: articleItem)!) }
            } else {
                NavigationStack { ArticleView(scp: offlineArticle!) }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
