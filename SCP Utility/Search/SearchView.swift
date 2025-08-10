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
    @State var articles: [Article] = [] // Articles without a source
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
                ForEach(articles) { article in
                    OnlineArticleRow(article)
                        .padding(.vertical, 1)
                }
                Spacer()
            }
            .navigationTitle("SEARCH_TITLE")
            .toolbar {
                Menu {
                    ForEach(RAISALanguage.allSupportedCases) { lang in
                        Button {
                            token = lang.rawValue
                        } label: {
                            HStack {
                                Text("\(lang.emoji()) \(lang.toName())")
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
        .onChange(of: networkMonitor.isConnected) {
            connected = $0
            articles = []
        }
        .onChange(of: query) { _ in showPrompt = false }
        .onAppear {
            connected = networkMonitor.isConnected
            recentSearches = defaults.stringArray(forKey: "recentSearches") ?? []
        }
    }
}

struct SearchView_Previews: PreviewProvider {
    static let networkMonitor = NetworkMonitor()
    static var previews: some View {
        SearchView().environmentObject(networkMonitor)
    }
}
