//
//  ResumeCard.swift
//  SCP Utility
//
//  Created by Maximus Harding on 4/12/23.
//

import SwiftUI
import Kingfisher

struct ResumeCard: View {
    @State private var showSheet: Bool = false
    let con = PersistenceController.shared
    var body: some View {
        if let history = con.getLatestHistory() {
            VStack {
                HStack {
                    Text("Continue Reading")
                        .font(.headline)
                        .fontWeight(.bold)
                        .padding(.leading)
                    Spacer()
                }
                Spacer()
                HStack {
                    Text(history.articletitle!)
                        .font(.monospaced(.largeTitle)())
                        .lineLimit(2)
                    Image(systemName: "arrow.forward")
                }
            }
            .padding(10)
            .background {
                KFImage(history.thumbnail)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .opacity(0.5)
            }
            .fullScreenCover(isPresented: $showSheet) {
                if let title = history.articletitle {
                    if let article = con.getArticleByTitle(title: title) {
                        NavigationView { ArticleView(scp: Article(fromEntity: article)!) }
                    }
                }
            }
            .onTapGesture {
                showSheet = true
            }
        }
    }
}

struct ResumeCard_Previews: PreviewProvider {
    static var previews: some View {
        ResumeCard()
    }
}
