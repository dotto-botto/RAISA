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
        VStack {
            Text("Rating: \(String(info.rating))")
            HStack {
                ForEach(info.tags, id: \.self) { tag in
                    Text(tag)
                }
            }
            Text("Author Info")
                .fontWeight(.heavy)
                .padding(.top)
            Text(info.createdBy)
            Text("Rank ---- \(info.userRank)")
            Text("Pages Made ---- \(info.userPageCount)")
            Text("Total Votes ---- \(info.userTotalRating)")
        }
        .onAppear {
            cromInfo(url: url) { scp in
                info = scp
            }
        }
    }
}

struct ArticleInfoView_Previews: PreviewProvider {
    static var previews: some View {
        ArticleInfoView(url: URL(string: "https://scp-wiki.wikidot.com/zyn-kaiju-butterfly-ninja-master")!)
    }
}
