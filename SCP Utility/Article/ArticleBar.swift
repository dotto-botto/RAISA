//
//  ArticleBar.swift
//  SCP Utility
//
//  Created by Maximus Harding on 3/25/23.
//

import SwiftUI

struct ArticleBar: View {
    @AppStorage("articleBarIds") var articles = "" // ids separated by whitespace
    @State private var toArticle = false
    
    var body: some View {
        let con = PersistenceController.shared
        
        if !articles.isEmpty {
            HStack {
                Spacer()
                ForEach(articles.components(separatedBy: .whitespaces), id: \.self) { id in
                    let articleItem = con.getArticleByID(id: id)
                    if articleItem != nil {
                        let article = Article(fromEntity: articleItem!)!
                        VStack {
                            Rectangle()
                                .foregroundColor(.accentColor)
                                .frame(height: 2)
                            Text(article.title)
                                .lineLimit(1)
                                .foregroundColor(.accentColor)
                        }
                        .onTapGesture {
                            toArticle = true
                        }
                        .contextMenu {
                            Button {
                                let _ = articles = articles.replacingOccurrences(of: " " + id, with: "")
                                let _ = articles = articles.replacingOccurrences(of: id, with: "")
                            } label: {
                                Label("REMOVE_FROM_BAR", systemImage: "minus.circle")
                            }
                            Button(role: .destructive) {
                                con.deleteArticleEntity(id: id)
                            } label: {
                                Label("DELETE_FROM_BAR", systemImage: "trash")
                            }
                        }
                    } else {
                        let _ = articles = articles.replacingOccurrences(of: " " + id, with: "")
                        let _ = articles = articles.replacingOccurrences(of: id, with: "")
                    }
                }
                Spacer()
            }
            .fullScreenCover(isPresented: $toArticle) {
                NavigationStack { ArticleTabView() }
            }
        }
    }
}

struct ArticleBar_Previews: PreviewProvider {
    static var previews: some View {
        ArticleBar()
    }
}
