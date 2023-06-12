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
    @AppStorage("articleBarIds") var articles = "" // ids separated by whitespace
    @State private var toArticle = false
    let con = PersistenceController.shared
    var body: some View {
        var selectedID = ""
        HStack {
            Spacer()
            if !articles.isEmpty {
                ForEach(articles.components(separatedBy: .whitespaces), id: \.self) { id in
                    if let articleItem = con.getArticleByID(id: id) {
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
                                articles = articles.replacingOccurrences(of: " " + id, with: "")
                                articles = articles.replacingOccurrences(of: id, with: "")
                            } label: {
                                Label("REMOVE_FROM_BAR", systemImage: "minus.circle")
                            }
                            Button(role: .destructive) {
                                articles = articles.replacingOccurrences(of: " " + id, with: "")
                                articles = articles.replacingOccurrences(of: id, with: "")
                                con.deleteArticleEntity(id: id)
                            } label: {
                                Label("DELETE_FROM_BAR", systemImage: "trash")
                            }
                        }
                    }
                }
                Spacer()
            }
        }
        .frame(height: articles.isEmpty ? 0 : 40)
        .fullScreenCover(isPresented: $toArticle) {
            NavigationStack { ArticleTabView(selectedID: selectedID) }
        }
    }
}

@discardableResult
func addIDToBar(id: String) -> Bool {
    let defaults = UserDefaults.standard
    guard let barIds = defaults.string(forKey: "articleBarIds") else { return false }
    guard !barIds.contains(id) else { return false }
    
    if barIds.isEmpty {
        defaults.set(id, forKey: "articleBarIds")
    } else {
        defaults.set(barIds + " " + id, forKey: "articleBarIds")
    }
    
    return true
}

struct ArticleBar_Previews: PreviewProvider {
    static var previews: some View {
        ArticleBar()
    }
}
