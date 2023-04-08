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
    let con = PersistenceController.shared
    var body: some View {
        let articles = con.getAllArticles()
        if !articles!.isEmpty {
            List {
                if mode == 0 {
                    ForEach(articles!) { article in
                        ArticleRow(passedSCP: Article(fromEntity: article)!, localArticle: true)
                    }
                } else if mode == 1 {
                    ForEach(articles!) { article in
                        if con.completionStatus(article: Article(fromEntity: article) ?? Article(title: "", pagesource: "")) {
                            ArticleRow(passedSCP: Article(fromEntity: article)!, localArticle: true)
                        }
                    }
                } else if mode == 2 {
                    ForEach(articles!) { article in
                        if !con.completionStatus(article: Article(fromEntity: article) ?? Article(title: "", pagesource: "")) {
                            ArticleRow(passedSCP: Article(fromEntity: article)!, localArticle: true)
                        }
                    }
                }
            }
        } else {
            #if os(iOS)
            Text("NO_SAVED_ARTICLES")
            #elseif os(watchOS)
            Text("NO_SAVED_ARTICLES_WATCH")
            #endif
        }
    }
}

struct AllArticleView_Previews: PreviewProvider {
    static var previews: some View {
        AllArticleView()
    }
}
