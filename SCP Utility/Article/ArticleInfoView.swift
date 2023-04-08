//
//  ArticleInfoView.swift
//  SCP Utility
//
//  Created by Maximus Harding on 4/3/23.
//

import SwiftUI

struct ArticleInfoView: View {
    @State var url: URL
    @State var info: ArticleInfo = ArticleInfo(rating: 0, tags: [], createdAt: "", createdBy: "", userRank: 0, userTotalRating: 0, userMeanRating: 0, userPageCount: 0)
    var body: some View {
        let Guide = {
            Rectangle()
                .frame(height: 0.5)
                .foregroundColor(.secondary)
        }
        VStack {
            HStack {
                Text("RATING")
                Guide()
                Text(String(info.rating)).foregroundColor(.green)
            }
            HStack {
                ForEach(info.tags, id: \.self) { tag in
                    Text(tag).font(.caption2)
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
        }
        .frame(width: 300)
        .onAppear {
            cromInfo(url: url) { scp in
                info = scp
            }
        }
    }
}

struct ArticleInfoView_Previews: PreviewProvider {
    static var previews: some View {
        ArticleInfoView(url: URL(string: "https://scp-wiki.wikidot.com/scp-5004")!)
    }
}
