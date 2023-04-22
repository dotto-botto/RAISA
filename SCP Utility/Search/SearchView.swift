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
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(articles) { article in
                    ArticleRow(passedSCP: article, localArticle: false)
                }
            }
            .navigationTitle("SEARCH_TITLE")
        }
        .searchable(text: $query, prompt: "SEARCH_PROMPT")
        .onSubmit(of: .search) {
            cromAPISearch(query: query) { scp in
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
