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
    @State var articles: [(Article, String, String?)] = [] // Article, id, alt
    @State var recentSearches: [String] = []
    @State private var showPrompt: Bool = false
    @State private var connected: Bool = true

    @AppStorage("chosenRaisaLanguage") var token = RAISALanguage.english.rawValue
    @EnvironmentObject var networkMonitor: NetworkMonitor
    var body: some View {
        let defaults = UserDefaults.standard
        NavigationStack {
            if showPrompt {
                Text("NO_RESULTS_FOR_\(query)")
                    .bold()
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 10)
            }
            
            if !connected {
                VStack {
                    Image(systemName: "wifi.slash")
                    Text("USER_OFFLINE")
                }
                .padding(.vertical, 300)
                .foregroundColor(.secondary)
            }
            
            if articles.isEmpty && !recentSearches.isEmpty && !showPrompt && connected {
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
                        .lineLimit(2)
                    }
                    .padding(.horizontal, 10)
                    
                    Spacer()
                }
                .foregroundColor(.secondary)
                .padding(.horizontal, 50)
            }
            
            VStack {
                ForEach(articles, id: \.1) { article, _, alt in
                    OnlineArticleRow(title: article.title, alternateTitle: alt, url: article.url)
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
            cromAPISearch(query: query, language: RAISALanguage(rawValue: token) ?? .english) { scp, alt in
                articles = []
                for (article, name) in zip(scp, alt) {
                    articles.append((
                        article,
                        article.id,
                        name
                    ))
                }
                
                showPrompt = scp.isEmpty
            
                if !recentSearches.contains(query) && defaults.bool(forKey: "trackSearchHistory") {
                    recentSearches.append(query)
                    if recentSearches.count > 5 {
                        recentSearches.remove(at: 0)
                    }
                    
                    defaults.set(recentSearches, forKey: "recentSearches")
                }
            }
        }
        .onChange(of: networkMonitor.isConnected) { connected = $0 }
        .onChange(of: query) { _ in showPrompt = false }
        .onAppear {
            connected = networkMonitor.isConnected
            recentSearches = defaults.stringArray(forKey: "recentSearches") ?? []
        }
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
    }
}
