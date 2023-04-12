//
//  RandomCard.swift
//  SCP Utility
//
//  Created by Maximus Harding on 4/1/23.
//

import SwiftUI

struct RandomCard: View {
    @State var showArticle: Bool = false
    @State var article = Article(title: "", pagesource: "", url: placeholderURL)
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
                        Text(article.title).font(.monospaced(.largeTitle)())
                        Image(systemName: "arrow.forward")
                    } else {
                        ProgressView()
                    }
                }
            }
        }
        .foregroundColor(.secondary)
        .cornerRadius(15)
        .frame(maxWidth: .infinity, maxHeight: 250)
        .fullScreenCover(isPresented: $showArticle) {
            NavigationView { ArticleView(scp: article) }
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
