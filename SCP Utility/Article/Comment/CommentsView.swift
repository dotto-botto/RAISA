//
//  CommentsView.swift
//  SCP Utility
//
//  Created by Maximus Harding on 4/29/23.
//

import SwiftUI

/// View that displays several CommentViews given a list of Comment structs.
struct CommentsView: View {
    @State var article: Article
    @State private var comments: [Comment] = []
    @State private var loading: Bool = true
    @State private var page: Int = 1
    @State private var maxpage: Int = 1
    @State private var error: Error? = nil

    @ViewBuilder
    var pager: some View {
        if maxpage > 1 {
            HStack {
                Spacer()
                
                if page > 2 {
                    Button {
                        page = 1
                    } label: {
                        Image(systemName: "chevron.left.2")
                    }
                    .padding(.trailing, 5)
                }
                
                if page > 1 {
                    Button {
                        page -= 1
                    } label: {
                        Image(systemName: "chevron.left")
                    }
                }
                
                Menu {
                    Text("CV_OLDEST")
                    ForEach(1...maxpage, id: \.self) { pagenum in
                        Button("\(pagenum)") { page = pagenum }
                    }
                    Text("CV_NEWEST")
                } label: {
                    Text("\(page)CV_PAGECOUNT\(maxpage)")
                }
                .padding(.horizontal, 5)
                
                if page < maxpage {
                    Button {
                        page += 1
                    } label: {
                        Image(systemName: "chevron.right")
                    }
                }
                
                if page < maxpage - 1 {
                    Button {
                        page = maxpage
                    } label: {
                        Image(systemName: "chevron.right.2")
                    }
                    .padding(.leading, 5)
                }
                
                Spacer()
            }
            .font(.title3)
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                if loading {
                    VStack {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                } else if error != nil {
                    VStack {
                        Spacer()
                        Text("ERROR_OCCURED")
                            .font(.title)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                    .padding(.horizontal, 30)
                } else if comments.isEmpty && maxpage == 1 {
                    VStack {
                        Spacer()
                        Text("CV_NOCOMMENTS")
                            .font(.title)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                    .padding(.horizontal, 30)
                } else {
                    VStack {
                        pager
                        ForEach(comments, id: \.self) { comment in
                            CommentView(comment: comment).padding(.vertical, 5)
                        }
                        .padding(.horizontal, 20)
                        pager
                    }
                }
            }
            .navigationTitle("CV_TITLE\(article.title)")
            .scrollDisabled(loading)
        }
        .onAppear {
            loading = true
            refresh()
        }
        .onChange(of: page) { _ in
            loading = true
            refresh()
        }
    }
    
    func refresh() {
        RaisaReq.getComments(url: article.url, page: page) { c, maxnum, err in
            if let err {
                error = err
            }
            if let c, let maxnum {
                comments = c
                maxpage = maxnum
            }
            loading = false
        }
    }
}

struct CommentsView_Previews: PreviewProvider {
    static var previews: some View {
        CommentsView(article: placeHolderArticle)
    }
}
