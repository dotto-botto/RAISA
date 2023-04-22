//
//  RandomCard.swift
//  SCP Utility
//
//  Created by Maximus Harding on 4/1/23.
//

import SwiftUI

struct RandomCard: View {
    @State private var showArticle: Bool = false
    @State private var article = Article(title: "", pagesource: "", url: placeholderURL)
    var body: some View {
        Button {
            showArticle = true
        } label: {
            VStack {
                HStack {
                    Text("RANDOM_CARD")
                        .font(.headline)
                        .fontWeight(.bold)
                        .padding(.leading)
                    Spacer()
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
            }
        }
        .foregroundColor(.primary)
        .frame(maxWidth: .infinity, maxHeight: 250)
        .fullScreenCover(isPresented: $showArticle) {
            NavigationStack { ArticleView(scp: article) }
        }
        .onAppear {
            let _ = cromRandom { scp in
                article = scp
            }
        }
    }
}

struct RandomCard_Previews: PreviewProvider {
    static var previews: some View {
        RandomCard()
    }
}
