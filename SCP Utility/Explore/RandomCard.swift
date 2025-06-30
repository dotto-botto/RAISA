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
    @State private var article: Article? = nil
    @State private var beenLoaded: Bool = false
    @State private var userIntBranch = RAISALanguage(rawValue: UserDefaults.standard.integer(forKey: "chosenRaisaLanguage")) ?? .english
    @State private var error: Error? = nil
    var body: some View {
        if error != nil {
            HStack(alignment: .center) {
                Text("An error occured. Please try again later.")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        } else {
            VStack {
                HStack {
                    Text("RANDOM_CARD")
                        .font(.headline)
                        .fontWeight(.bold)
                        .padding(.leading)
                    Spacer()
                    // Refresh
                    Image(systemName: "arrow.clockwise")
                        .padding([.top, .trailing], 5)
                        .onTapGesture {
                            if article != nil { // if not already loading
                                article = Article(title: "", pagesource: "", url: placeholderURL)
                                cromRandom(language: userIntBranch) { scp in
//                                    error = err
                                    article = scp
                                }
                            }
                        }
                }
                
                // Main section
                HStack {
                    if article != nil {
                        Text(article!.title)
                            .font(.monospaced(.largeTitle)())
                            .lineLimit(2)
                        Image(systemName: "arrow.forward")
                    } else {
                        ProgressView()
                    }
                }
                .onTapGesture {
                    if article != nil {
                        cromGetSourceFromURL(url: article!.url) { source in
                            article!.pagesource = source
                            showArticle = true
                        }
                    }
                }
            }
            .foregroundColor(.primary)
            .frame(maxWidth: .infinity, maxHeight: 250)
            .padding(10)
            .background {
                if let article {
                    KFImage(article.thumbnail)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .opacity(0.5)
                }
            }
            .clipped()
            .fullScreenCover(isPresented: $showArticle) {
                if article != nil {
                    NavigationStack { ArticleView(scp: article!) }
                } else {
                    Spacer()
                        .onAppear {
                            showArticle = false
                        }
                }
            }
            .onAppear {
                if !beenLoaded {
                    cromRandom(language: userIntBranch) { scp in
//                        error = err
                        article = scp
                    }
                    beenLoaded = true
                }
            }
        }
    }
}

struct RandomCard_Previews: PreviewProvider {
    static var previews: some View {
        RandomCard()
    }
}
