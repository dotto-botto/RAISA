//
//  ArticleInfoView.swift
//  SCP Utility
//
//  Created by Maximus Harding on 4/3/23.
//

import SwiftUI

/// Struct that presents an ArticleInfo struct to the user, along with licensing information about the article.
struct ArticleInfoView: View {
    @State var article: Article
    @State var info: ArticleInfo = ArticleInfo(rating: 0, tags: [], createdAt: "", createdBy: "", userRank: 0, userTotalRating: 0, userMeanRating: 0, userPageCount: 0)
    @State private var loading: Bool = true
    var body: some View {
        let Guide = {
            Rectangle()
                .frame(height: 0.5)
                .foregroundColor(.secondary)
        }
        VStack {
            if loading {
                ProgressView()
            } else {
                HStack {
                    Text("RATING")
                    Guide()
                    Text(String(info.rating)).foregroundColor(.green)
                }
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(info.tags, id: \.self) { tag in
                            Text(tag).font(.caption2)
                        }
                    }
                }
                Text(info.createdBy)
                    .fontWeight(.heavy)
                    .padding(.top)
                HStack {
                    Text("RANK")
                    Guide()
                    Text(String(info.userRank)).foregroundColor(.green)
                }
                HStack {
                    Text("PAGES_CREATED")
                    Guide()
                    Text(String(info.userPageCount)).foregroundColor(.green)
                }
                HStack {
                    Text("TOTAL_VOTES")
                    Guide()
                    Text(String(info.userTotalRating)).foregroundColor(.green)
                }
                .padding(.bottom, 10)
                
                // Licensing
                Group {
                    Text("\(article.title)AIV_CITATION\(info.createdBy)")
                    Link("AIV_VIEW_SOURCE", destination: article.url)
                    Text("AIV_LICENSE")
                }
                .font(.subheadline)
            }
        }
        .frame(width: 300)
        .onAppear {
            cromInfo(url: article.url) { scp in
                info = scp
                loading = false
            }
        }
    }
}

struct ArticleInfoView_Previews: PreviewProvider {
    static var previews: some View {
        ArticleInfoView(article: placeHolderArticle)
    }
}
