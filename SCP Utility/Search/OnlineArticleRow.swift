//
//  OnlineArticleRow.swift
//  SCP Utility
//
//  Created by Maximus Harding on 5/21/23.
//

import SwiftUI

/// View that displays articles that arent saved in core data.
/// Used for search results as well as in SeriesView.
struct OnlineArticleRow: View {
    var title: String
    var url: URL
    @State var bookmarkStatus: Bool
    @State private var checkmarkStatus: Bool
    
    @State var toArticle: Bool = false
    @State var observedBool: Bool = false // solely used to trigger onchange()
    @State var currentArticle: Article = placeHolderArticle
    @State var showSheet: Bool = false
    
    init(title: String, url: URL) {
        self.title = title
        self.url = url
        
        _bookmarkStatus = State(initialValue: PersistenceController.shared.isArticleSaved(url: url))
        _checkmarkStatus = State(initialValue: (UserDefaults.standard.stringArray(forKey: "completedArticles") ?? []).contains(url.formatted()))
    }
    
    init(article: Article) {
        self.title = article.title
        self.url = article.url
        
        _bookmarkStatus = State(initialValue: article.isSaved())
        _checkmarkStatus = State(initialValue: (UserDefaults.standard.stringArray(forKey: "completedArticles") ?? []).contains(url.formatted()))
    }
    
    var body: some View {
        let con = PersistenceController.shared
        HStack {
            Button {
                cromAPISearchFromURL(query: url) { article in
                    guard article != nil else { return }
                    currentArticle = article!
                    observedBool.toggle()
                }
            } label: {
                Text(title)
                    .font(.monospaced(.title3)())
                    .lineLimit(2)
                Spacer()
            }
            
            if checkmarkStatus {
                Image(systemName: "checkmark")
            }
            
            Button {
                if !bookmarkStatus {
                    cromAPISearchFromURL(query: url) { article in
                        guard let article = article else { return }
                        con.createArticleEntity(article: article)
                    }
                    
                    bookmarkStatus.toggle()
                } else {
                    showSheet.toggle()
                }
            } label: {
                Image(systemName: bookmarkStatus ? "bookmark.fill" : "bookmark")
            }
            .onLongPressGesture { showSheet.toggle() }
        }
        .onChange(of: observedBool) { _ in
            toArticle = true
        }
        .fullScreenCover(isPresented: $toArticle, onDismiss: {
            checkmarkStatus = (UserDefaults.standard.stringArray(forKey: "completedArticles") ?? []).contains(url.formatted())
            bookmarkStatus = PersistenceController.shared.isArticleSaved(url: url)
        }) {
            NavigationStack { ArticleView(scp: currentArticle) }
        }
        .sheet(isPresented: $showSheet) {
            ListAdd(isPresented: $showSheet, article: currentArticle)
        }
        .onAppear {
            if con.isArticleSaved(url: url) {
                bookmarkStatus = true
            }
        }
        .padding(.horizontal, 40)
    }
}

struct OnlineArticleBar_Previews: PreviewProvider {
    static var previews: some View {
        OnlineArticleRow(article: placeHolderArticle)
    }
}
