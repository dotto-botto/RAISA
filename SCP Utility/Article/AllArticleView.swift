//
//  AllArticleView.swift
//  SCP Utility
//
//  Created by Maximus Harding on 3/19/23.
//

import SwiftUI

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
        }
        .searchable(text: $query)
    }
}

struct AllArticleView_Previews: PreviewProvider {
    static var previews: some View {
        AllArticleView()
    }
}
