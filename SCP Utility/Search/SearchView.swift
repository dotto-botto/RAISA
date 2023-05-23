//
//  SearchView.swift
//  SCP Wiki Utility
//
//  Created by Maximus Harding on 12/25/22.
//

import SwiftUI
import Foundation


struct SearchView: View {
    @State var query: String = ""
    @State var articles: [Article] = []
    @State private var tokens: [RAISALanguage] = [
        RAISALanguage(rawValue: UserDefaults.standard.integer(forKey: "chosenRaisaLanguage")) ?? .english
    ]
    
    var body: some View {
        NavigationStack {
            VStack {
                ForEach(articles) { article in
                    OnlineArticleRow(article: article)
                }
                Spacer()
            }
            .navigationTitle("SEARCH_TITLE")
        }
        .searchable(text: $query, tokens: $tokens, prompt: "SEARCH_PROMPT", token: { token in
            Text(token.toName())
        })
        .onSubmit(of: .search) {
            cromAPISearch(query: query, language: tokens.first ?? .english) { scp in
                articles = scp
            }
        }
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
    }
}
