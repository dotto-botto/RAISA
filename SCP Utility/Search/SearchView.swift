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
    @State private var tokens: [RAISALanguage] = [.english]
    @State private var showGrid: Bool = true
    
    var body: some View {
        NavigationStack {
            VStack {
                ForEach(articles) { article in
                    OnlineArticleRow(article: article)
                }
                Spacer()
                
                if showGrid {
                    List {
                        ForEach(RAISALanguage.allCases.filter { $0 != .english }) { lang in
                            Button {
                                tokens = [lang]
                            } label: {
                                HStack {
                                    Image(lang.toImage())
                                        .resizable()
                                        .scaledToFit()
                                    Text(lang.toName())
                                        .foregroundColor(.primary)
                                        .font(.title)
                                }
                            }
                            .frame(height: 50)
                        }
                    }
                    .listStyle(.plain)
                }
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
        .onChange(of: query) { _ in showGrid = false }
        .onAppear { showGrid = true }
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
    }
}
