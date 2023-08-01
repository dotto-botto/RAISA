//
//  ArticleBar.swift
//  SCP Utility
//
//  Created by Maximus Harding on 3/25/23.
//

import SwiftUI

/// View that is displayed at the bottom of the main page.
/// Can be opened to quickly traverse between the articles displayed on it.
struct ArticleBar: View {
    @State var articles: [String] = []
    @State private var selectedID = ""
    @State private var toArticle = false
    
    init() {
        loadArticles()
    }
    
    var body: some View {
        HStack {
            Spacer()
            ForEach(articles, id: \.self) { id in
                if let articleItem = PersistenceController.shared.getArticleByID(id: id) {
                    let article = Article(fromEntity: articleItem)!
                    Button {
                        selectedID = id
                        toArticle = true
                    } label: {
                        VStack {
                            Rectangle()
                                .foregroundColor(.accentColor)
                                .frame(height: 2)
                            Text(article.title.replacingOccurrences(of: "SCP-", with: ""))
                                .lineLimit(1)
                                .foregroundColor(.accentColor)
                        }
                        .dynamicTypeSize(.xSmall ... .accessibility1)
                    }
                    .contextMenu {
                        Button {
                            removeArticle(id: id)
                        } label: {
                            Label("REMOVE_FROM_BAR", systemImage: "minus.circle")
                        }
                        
                        Button(role: .destructive) {
                            removeArticle(id: id)
                            PersistenceController.shared.deleteArticleEntity(id: id)
                        } label: {
                            Label("DELETE_FROM_BAR", systemImage: "trash")
                        }
                    }
                }
            }
            Spacer()
        }
        .frame(height: articles.isEmpty ? 0 : 40)
        .fullScreenCover(isPresented: $toArticle) {
            NavigationStack { ArticleTabView() }
        }
        .onAppear {
            loadArticles()
        }
    }
    
    func loadArticles() {
        let data = UserDefaults.standard.object(forKey: "articleBarIds")
        
        if let oldIDS = data as? String {
            self.articles = oldIDS.components(separatedBy: .whitespaces)
        } else if let newIDS = data as? [String] {
            self.articles = newIDS
        }
    }
    
    func removeArticle(id: String) {
        self.articles = self.articles.filter { $0 != id }
        UserDefaults.standard.set(self.articles, forKey: "articleBarIds")
    }
}

func addIDToBar(id: String) {
    let defaults = UserDefaults.standard
    
    var barIds: [String] = {
        let data = defaults.object(forKey: "articleBarIds")
        if let oldIDS = data as? String {
            return oldIDS.components(separatedBy: .whitespaces)
        } else if let newIDS = data as? [String] {
            return newIDS
        } else {
            return []
        }
    }()
    
    guard !barIds.contains(id) else { return }
    
    barIds.append(id)
    defaults.set(barIds, forKey: "articleBarIds")
}

struct ArticleBar_Previews: PreviewProvider {
    static var previews: some View {
        ArticleBar()
    }
}
