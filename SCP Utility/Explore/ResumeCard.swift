//
//  ResumeCard.swift
//  SCP Utility
//
//  Created by Maximus Harding on 4/12/23.
//

import SwiftUI
import Kingfisher

/// ExploreView card that displays The last read article.
struct ResumeCard: View {
    @State var article: Article?
    
    init() {
        guard let url = UserDefaults.standard.url(forKey: "lastReadUrl") else { self.article = nil; return }
        
        var article: Article? = nil
        guard let item = PersistenceController.shared.getArticleByURL(url: url) else { self.article = nil; return }
        article = Article(fromEntity: item)
        
        self.article = article
    }
    
    @State var showSheet: Bool = false
    var body: some View {
        if let url = UserDefaults.standard.url(forKey: "lastReadUrl") {
            VStack {
                HStack {
                    Text("RESUME_CARD")
                        .font(.headline)
                        .fontWeight(.bold)
                        .padding(.leading)
                    Spacer()
                }
                Spacer()
                if let article {
                    HStack {
                        Text(article.title)
                            .font(.monospaced(.largeTitle)())
                            .lineLimit(2)
                        Image(systemName: "arrow.forward")
                    }
                    .onTapGesture {
                        // refresh article
                        if let url = UserDefaults.standard.url(forKey: "lastReadUrl") {
                            if let entity = PersistenceController.shared.getArticleByURL(url: url) {
                                self.article = Article(fromEntity: entity)
                            }
                        }
                        
                        showSheet = true
                    }
                } else {
                    ProgressView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: 250)
            .padding(10)
            .background {
                if let article {
                    KFImage(article.thumbnail)
                        .resizable()
                        .scaledToFill()
                        .opacity(0.5)
                }
            }
            .clipped()
            .fullScreenCover(isPresented: $showSheet) {
                // article should never be nil, but just in case
                if let article {
                    NavigationStack { ArticleView(scp: article) }
                } else {
                    Spacer()
                        .onAppear {
                            showSheet = false
                        }
                }
            }
            .task {
                if article == nil {
                    RaisaReq.articlefromURL(url: url) { art, _ in
                        article = art
                    }
                }
            }
        }
    }
}

struct ResumeCard_Previews: PreviewProvider {
    static var previews: some View {
        ResumeCard()
    }
}
