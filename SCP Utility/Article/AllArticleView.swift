//
//  AllArticleView.swift
//  SCP Utility
//
//  Created by Maximus Harding on 3/19/23.
//

import SwiftUI

/// View that displays all articles stored in core data.
struct AllArticleView: View {
    @State private var query: String = ""
    @State private var articles: [Article] = []
    // 0 - Default (Every saved article)
    // 1 - Every article that the user has marked as complete.
    // 2 - Every article that the user hasn't marked as complete.
    @State private var mode: Int = 0
    let con = PersistenceController.shared
    var body: some View {
        NavigationStack {
            List {
                ForEach(articles) { article in
                    ArticleRow(passedSCP: article)
                }
            }
            
            VStack {
                if articles.isEmpty {
                    if !query.isEmpty {
                        Text("NO_RESULTS_FOR_\(query)")
                    } else {
                        Text("NO_SAVED_ARTICLES")
                    }
                    Spacer()
                }
            }
            .foregroundColor(.secondary)
        }
        .searchable(text: $query)
        .toolbar {
            ToolbarItemGroup(placement: .secondaryAction) {
                Button {
                    mode = 0
                } label: {
                    HStack {
                        Text("ALL_SAVED_ARTICLES")
                        Spacer()
                        if mode == 0 {
                            Image(systemName: "checkmark")
                        }
                    }
                }
                Button {
                    mode = 1
                } label: {
                    HStack {
                        Text("ALL_READ_ARTICLES")
                        Spacer()
                        if mode == 1 {
                            Image(systemName: "checkmark")
                        }
                    }
                }
                Button {
                    mode = 2
                } label: {
                    HStack {
                        Text("ALL_UNREAD_ARTICLES")
                        Spacer()
                        if mode == 2 {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        }
        .task { updateArticles() }
        .onChange(of: mode) { _ in
            updateArticles()
            self.articles = articles
                .filter {
                    switch mode {
                    case 0: return true
                    case 1: return $0.completed ?? false
                    case 2: return !($0.completed ?? false)
                    default: return true
                    }
                }
        }
        .onChange(of: query) { _ in
            updateArticles()
            self.articles = articles.filter { query.isEmpty ? true : $0.title.lowercased().contains(query.lowercased()) } // search
        }
    }
    
    private func updateArticles() {
        var articlelist: [Article] = []
        for article in con.getAllArticles() ?? [] {
            if let article = Article(fromEntity: article) {
                articlelist.append(article)
            }
        }
        
        self.articles = articlelist
    }
}

struct AllArticleView_Previews: PreviewProvider {
    static var previews: some View {
        AllArticleView()
    }
}
