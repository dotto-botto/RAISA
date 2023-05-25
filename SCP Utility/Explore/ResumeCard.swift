//
//  ResumeCard.swift
//  SCP Utility
//
//  Created by Maximus Harding on 4/12/23.
//

import SwiftUI
import Kingfisher

/// ExploreView card that displays The last read article from core data.
struct ResumeCard: View {
    @State var article: Article = placeHolderArticle
    
    init?() {
        guard let url = UserDefaults.standard.url(forKey: "lastReadUrl") else { return nil }
        
        if let entity = PersistenceController.shared.getArticleByURL(url: url) {
            guard let scp = Article(fromEntity: entity) else { return }
            _article = State(initialValue: scp)
        }
    }
    
    @State var showSheet: Bool = false
    var body: some View {
        VStack {
            if article.title != placeHolderArticle.title {
                HStack {
                    Text("RESUME_CARD")
                        .font(.headline)
                        .fontWeight(.bold)
                        .padding(.leading)
                    Spacer()
                }
                Spacer()
                HStack {
                    Text(article.title)
                        .font(.monospaced(.largeTitle)())
                        .lineLimit(2)
                    Image(systemName: "arrow.forward")
                }
            }
        }
        .padding(10)
        .background {
            KFImage(article.thumbnail)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .opacity(0.5)
        }
        .fullScreenCover(isPresented: $showSheet) {
            NavigationStack { ArticleView(scp: article) }
        }
        .onTapGesture {
            showSheet = true
        }
        .onAppear {
            if article.title == placeHolderArticle.title {
                guard let url = UserDefaults.standard.url(forKey: "lastReadUrl") else { return }
                cromAPISearchFromURL(query: url) { scp in
                    guard let scp = scp else { return }
                    article = scp
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
