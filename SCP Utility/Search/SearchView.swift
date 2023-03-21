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
    @State var callApi: Bool = false
    @State var articles: [Article] = []
    @State var presentSheet: Bool = false
    @State var selectedArticle: Article = Article(title: "", pagesource: "")
    
    var body: some View {
        NavigationView {
            List {
                ForEach(articles) { article in
                    NavigationLink(destination: ArticleView(scp: article)) {
                        HStack {
                            Text(article.title)
                            Spacer()
                            Image(systemName: "bookmark")
                                .onTapGesture {
                                    presentSheet = true
                                    selectedArticle = article
                                }

                        }
                    }
                }
            }
            .navigationTitle("SEARCH_TITLE")
        }
        .sheet(isPresented: $presentSheet) {
        } content: {
            ListAdd(isPresented: $presentSheet, article: selectedArticle)
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
