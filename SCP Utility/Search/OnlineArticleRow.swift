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
    var alternateTitle: String? = nil
    var url: URL
    
    @State var bookmarkStatus: Bool = false
    @State private var checkmarkStatus: Bool = false
    @State var toArticle: Bool = false
    @State var observedBool: Bool = false // solely used to trigger onchange()
    @State var addObservedBool: Bool = false
    @State var currentArticle: Article = placeHolderArticle
    @State var showSheet: Bool = false
    var body: some View {
        HStack {
            Button {
                cromAPISearchFromURL(query: url) { article in
                    guard article != nil else { return }
                    currentArticle = article!
                    observedBool.toggle()
                }
            } label: {
                if let alt = alternateTitle {
                    HStack {
                        Text(.init("\(title) - **\(alt)**"))
                    }
                    .font(.monospaced(.title3)())
                    .lineLimit(2)
                } else {
                    Text(title)
                        .font(.monospaced(.title3)())
                        .lineLimit(2)
                }

                Spacer()
            }
                        
            if checkmarkStatus {
                Image(systemName: "checkmark")
                    .foregroundColor(.accentColor)
            }
            
            Button {
                cromAPISearchFromURL(query: url) { article in
                    guard let article = article else { return }
                    currentArticle = article
                    addObservedBool.toggle()
                }
            } label: {
                Image(systemName: bookmarkStatus ? "bookmark.fill" : "bookmark")
            }
            .onLongPressGesture { showSheet.toggle() }
        }
        .onChange(of: observedBool) { _ in
            toArticle = true
        }
        .onChange(of: addObservedBool) { _ in
            showSheet = true
        }
        .fullScreenCover(isPresented: $toArticle, onDismiss: {
            checkmarkStatus = (UserDefaults.standard.stringArray(forKey: "completedArticles") ?? []).contains(url.formatted())
            bookmarkStatus = PersistenceController.shared.isArticleSaved(url: url)
        }) {
            NavigationStack { ArticleView(scp: currentArticle) }
        }
        .sheet(isPresented: $showSheet, onDismiss: {
            bookmarkStatus = PersistenceController.shared.isArticleSaved(url: url)
        }) {
            ListAdd(isPresented: $showSheet, article: currentArticle)
        }
        .task {
            checkmarkStatus = (UserDefaults.standard.stringArray(forKey: "completedArticles") ?? []).contains(url.formatted())
            bookmarkStatus = PersistenceController.shared.isArticleSaved(url: url)
        }
        .padding(.horizontal, 40)
    }
}

struct OnlineArticleBar_Previews: PreviewProvider {
    static var previews: some View {
        OnlineArticleRow(title: placeHolderArticle.title, alternateTitle: "The Sculpture", url: placeHolderArticle.url)
    }
}
