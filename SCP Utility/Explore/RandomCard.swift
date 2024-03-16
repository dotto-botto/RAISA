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
    @State private var userIntBranch = RAISALanguage(rawValue: UserDefaults.standard.integer(forKey: "chosenRaisaLanguage")) ?? .english
    @State private var badLanguageAlert: Bool = false
    @State private var disabled: Bool = false
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
                            userIntBranch = RAISALanguage(rawValue: UserDefaults.standard.integer(forKey: "chosenRaisaLanguage")) ?? .english
                            
                            guard RAISALanguage.allSupportedCases.contains(userIntBranch) else {
                                badLanguageAlert = true
                                article = Article(title: "...", pagesource: "", url: placeholderURL)
                                disabled = true
                                return
                            }
                                    
                            article = Article(title: "", pagesource: "", url: placeholderURL)
                            cromRandom(language: userIntBranch) { scp in
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
                    if !disabled {
                        Image(systemName: "arrow.forward")
                    }
                } else {
                    ProgressView()
                }
            }
            .onTapGesture {
                if disabled {
                    badLanguageAlert = true
                } else {
                    cromGetSourceFromURL(url: article.url) { source in
                        article.pagesource = source
                        showArticle = true
                    }
                }
            }
        }
        .alert("LANGUAGE_\(userIntBranch.toName())_NOT_SUPPORTED", isPresented: $badLanguageAlert) {
            Text("HOW_TO_CHANGE_LANGUAGE")
            Button("OK", role: .cancel) {
                badLanguageAlert = false
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
            #if targetEnvironment(simulator)
            article = Article(title: "RandomCard disabled in previews", pagesource: "", url: placeholderURL)
            #else
            if !RAISALanguage.allSupportedCases.contains(userIntBranch) {
                article = Article(title: "...", pagesource: "", url: placeholderURL)
                disabled = true
            } else if !beenLoaded {
                cromRandom(language: userIntBranch) { scp in
                    article = scp
                }
                beenLoaded = true
            }
            #endif
        }
    }
}

struct RandomCard_Previews: PreviewProvider {
    static var previews: some View {
        RandomCard()
    }
}
