//
//  RandomCard.swift
//  SCP Utility
//
//  Created by Maximus Harding on 4/1/23.
//

import SwiftUI

struct RandomCard: View {
    @State var showArticle: Bool = false
    var body: some View {
        var article = Article(title: "", pagesource: "")
        let _ = cromRandom { scp in
            article = scp
        }
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
                Image(systemName: "dice.fill")
                    .resizable()
                    .scaledToFit()
            }
        }
        .foregroundColor(.secondary)
        .cornerRadius(15)
        .frame(maxWidth: .infinity, maxHeight: 250)
        .fullScreenCover(isPresented: $showArticle) {
            NavigationView { ArticleView(scp: article) }
        }
        
    }
}

struct RandomCard_Previews: PreviewProvider {
    static var previews: some View {
        RandomCard()
    }
}
