//
//  AllArticleView.swift
//  SCP Utility
//
//  Created by Maximus Harding on 3/19/23.
//

import SwiftUI

struct AllArticleView: View {
    var body: some View {
        let articles = PersistenceController.shared.getAllArticles()
        List {
            if articles != nil {
                ForEach(articles!) { article in
                    ArticleRow(passedSCP: Article(fromEntity: article)!, localArticle: true)
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
}

struct AllArticleView_Previews: PreviewProvider {
    static var previews: some View {
        AllArticleView()
    }
}
