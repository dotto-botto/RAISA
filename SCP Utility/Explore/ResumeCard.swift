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
    var article: Article
    
    init?() {
        guard let url = UserDefaults.standard.url(forKey: "lastReadUrl") else { return nil }
        
        var article: Article? = nil
        raisaSearchFromURL(query: url) {
            guard let scp = $0 else { return }
            article = scp
        }
        
        guard article != nil else { return nil }
        self.article = article!
    }
    
    @State var showSheet: Bool = false
    var body: some View {
        VStack {
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
            .onTapGesture {
                showSheet = true
            }
        }
        .frame(maxWidth: .infinity, maxHeight: 250)
        .padding(10)
        .background {
            KFImage(article.thumbnail)
                .resizable()
                .scaledToFill()
                .opacity(0.5)
        }
        .clipped()
        .fullScreenCover(isPresented: $showSheet) {
            NavigationStack { ArticleView(scp: article) }
        }
    }
}

struct ResumeCard_Previews: PreviewProvider {
    static var previews: some View {
        ResumeCard()
    }
}
