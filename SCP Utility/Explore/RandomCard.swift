//
//  RandomCard.swift
//  SCP Utility
//
//  Created by Maximus Harding on 4/1/23.
//

import SwiftUI
import Kingfisher

/// ExploreView card that displays a random article from the Crom API.
struct RandomCard: View {
    @State private var showArticle: Bool = false
    @State private var article = Article(title: "", pagesource: "", url: placeholderURL)
    @State private var beenLoaded: Bool = false
    var body: some View {
        VStack {
            HStack {
                Text("RANDOM_CARD")
                    .font(.headline)
                    .fontWeight(.bold)
                    .padding(.leading)
                Spacer()
                Image(systemName: "arrow.clockwise")
                    .padding([.top, .trailing], 5)
                    .onTapGesture {
                        if article.title != "" { // if not already loading
                            article = Article(title: "", pagesource: "", url: placeholderURL)
                            cromRandom { scp in
                                article = scp
                            }
                        }
                    }
            }
            HStack {
                if article.title != "" {
                    Text(article.title)
                        .font(.monospaced(.largeTitle)())
                        .lineLimit(2)
                    Image(systemName: "arrow.forward")
                } else {
                    ProgressView()
                }
            }
            .onTapGesture {
                cromGetSourceFromURL(url: article.url) { source in
                    article.pagesource = source
                    showArticle = true
                }
            }
        }
        .foregroundColor(.primary)
        .frame(maxWidth: .infinity, maxHeight: 250)
        .padding(10)
        .background {
            if article.title != "" {
                KFImage(article.thumbnail)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .opacity(0.5)
            }
        }
        .clipped()
        .fullScreenCover(isPresented: $showArticle) {
            NavigationStack { ArticleView(scp: article) }
        }
        .onAppear {
            #if !targetEnvironment(simulator)
            if !beenLoaded {
                cromRandom { scp in
                    article = scp
                }
                beenLoaded = true
            }
            #else
            article = Article(title: "RandomCard disabled in previews", pagesource: "", url: placeholderURL)
            #endif
        }
    }
    
    mutating func refreshRandom() {
        
    }
}

struct RandomCard_Previews: PreviewProvider {
    static var previews: some View {
        RandomCard()
    }
}
