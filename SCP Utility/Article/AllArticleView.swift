//
//  AllArticleView.swift
//  SCP Utility
//
//  Created by Maximus Harding on 3/19/23.
//

import SwiftUI

/// View that displays all articles stored in core data.
/// 0 - Default (Every saved article)
/// 1 - Every article that the user has marked as complete.
/// 2 - Every article that the user hasn't marked as complete.
struct AllArticleView: View {
    @State var mode: Int? = 0
    // 0 = default
    // 1 = all read
    // 2 = all unread
    @State private var query: String = ""
    let con = PersistenceController.shared
    var body: some View {
        let articles = con.getAllArticles()?.filter{ query.isEmpty ? true: $0.title?.lowercased().contains(query.lowercased()) ?? false }
        NavigationStack {
            List {
                if mode == 0 {
                    ForEach(articles!) { article in
                        ArticleRow(passedSCP: Article(fromEntity: article)!)
                    }
                } else if mode == 1 {
                    ForEach(articles!) { article in
                        if con.completionStatus(article: Article(fromEntity: article)!) {
                            ArticleRow(passedSCP: Article(fromEntity: article)!)
                        }
                    }
                } else if mode == 2 {
                    ForEach(articles!) { article in
                        if !con.completionStatus(article: Article(fromEntity: article)!) {
                            ArticleRow(passedSCP: Article(fromEntity: article)!)
                        }
                    }
                }
            }
            
            VStack {
                if (articles ?? []).isEmpty {
                    if !query.isEmpty {
                        Text("NO_RESULTS_FOR_\(query)")
                    } else {
                        Text("NO_SAVED_ARTICLES")
                    }
                }
                Spacer()
            }
            .foregroundColor(.secondary)
        }
        .searchable(text: $query)
    }
}

struct AllArticleView_Previews: PreviewProvider {
    static var previews: some View {
        AllArticleView()
    }
}
