//
//  CommentsView.swift
//  SCP Utility
//
//  Created by Maximus Harding on 4/29/23.
//

import SwiftUI

struct CommentsView: View {
    @State var article: Article
    @State private var comments: [Comment] = []
    var body: some View {
        NavigationStack {
            ScrollView {
                ForEach(comments, id: \.self) { comment in
                    CommentView(comment: comment).padding(.vertical, 5)
                }
            }
            .navigationTitle("Discuss: \(article.title)")
            .frame(width: 400)
        }
        .onAppear {
            parseComments(articleURL: article.url) { com in
                comments = com
            }
        }
    }
}

struct CommentsView_Previews: PreviewProvider {
    static var previews: some View {
        CommentsView(article: placeHolderArticle)
    }
}