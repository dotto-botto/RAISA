//
//  SearchView.swift
//  SCP Wiki Utility
//
//  Created by Maximus Harding on 12/25/22.
//

import SwiftUI

/// Search menu that searches the crom api for articles based on the selected language.
struct SearchView: View {
    @State var query: String = ""
    @State var articles: [Article] = []
    @AppStorage("chosenRaisaLanguage") var token = RAISALanguage.english.rawValue
    @State var recentSearches: [String] = []
    
    var body: some View {
        let defaults = UserDefaults.standard
        NavigationStack {
            if articles.isEmpty && !recentSearches.isEmpty {
                VStack(alignment: .leading) {
                    HStack {
                        Image(systemName: "clock.arrow.circlepath")
                        Text("RECENT_SEARCHES").bold()
                        Spacer()
                        Button {
                            defaults.set([], forKey: "recentSearches")
                            recentSearches = []
                        } label: {
                            Image(systemName: "xmark")
                        }
                    }
                    
                    ForEach(recentSearches.reversed(), id: \.self) { search in
                        Button(search) {
                            query = search
                        }
                    }
                    .padding(.horizontal, 10)
                    
                    Spacer()
                }
                .foregroundColor(.secondary)
                .padding(.horizontal, 50)
            }
            
            VStack {
                ForEach(articles) { article in
                    OnlineArticleRow(article: article)
                        .padding(.vertical, 1)
                }
                Spacer()
            }
            .navigationTitle("SEARCH_TITLE")
            .toolbar {
                Menu {
                    ForEach(RAISALanguage.allCases) { lang in
                        Button {
                            token = lang.rawValue
                        } label: {
                            HStack {
                                Text(lang.toName())
                                Spacer()
                                if token == lang.rawValue {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                } label: {
                    Image(systemName: "globe")
                }
            }
        }
        .searchable(text: $query, prompt: "SEARCH_PROMPT")
        .onSubmit(of: .search) {
            cromAPISearch(query: query, language: RAISALanguage(rawValue: token) ?? .english) { scp in
                articles = scp
            
                if !recentSearches.contains(query) && defaults.bool(forKey: "trackSearchHistory") {
                    recentSearches.append(query)
                    if recentSearches.count > 5 {
                        recentSearches.remove(at: 0)
                    }
                    
                    defaults.set(recentSearches, forKey: "recentSearches")
                }
            }
        }
        .onAppear {
            recentSearches = defaults.stringArray(forKey: "recentSearches") ?? []
        }
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
    }
}
