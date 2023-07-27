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
    @State var subtitle: String? = nil
    @State var info: ArticleInfo = ArticleInfo(rating: 0, tags: [], createdAt: Date(), createdBy: "", userRank: 0, userTotalRating: 0, userMeanRating: 0, userPageCount: 0)
    @State private var loading: Bool = true
    
    @State private var trigger: Bool = false
    @State private var showUserSheet: Bool = false
    @State private var user: User = User()
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
                Group {
                    Text(article.title)
                        .font(.title)
                        .bold()
                        .padding(.bottom, 3)
                    
                    if subtitle != nil {
                        Text(subtitle!)
                            .font(.system(size: 12))
                            .padding(.horizontal, 10)
                            .padding(.bottom, 3)
                    }
                    
                    HStack {
                        Text("RATING")
                        Guide()
                        Text(String(info.rating)).foregroundColor(.green)
                    }
                    
                    if let date = info.createdAt {
                        HStack {
                            Text("CREATED_ON")
                            Guide()
                            Text(date.formatted(date: .long, time: .omitted))
                                .font(.system(size: 14))
                                .foregroundColor(.green)
                        }
                    }
                    
                    HStack {
                        Text("WORD_COUNT")
                        Guide()
                        let wordCount = FilterToPure(doc: article.pagesource)
                            .components(separatedBy: .whitespaces)
                            .filter { !$0.isEmpty }
                            .count
                        
                        Text("\(wordCount)").foregroundColor(.green)
                    }
                }
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(info.tags, id: \.self) { tag in
                            Text(tag).font(.caption2)
                        }
                    }
                }
                
                Button(info.createdBy) {
                    parseUserPage(username: info.createdBy) {
                        user = $0
                        trigger.toggle()
                    }
                }
                    .fontWeight(.heavy)
                    .padding(.top, 40)
                
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
                .font(.system(size: 12))
                .padding(.horizontal, 10)
            }
        }
        .frame(width: 300)
        .onChange(of: trigger) { _ in
            showUserSheet.toggle()
        }
        .sheet(isPresented: $showUserSheet) {
            UserView(user: user)
        }
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
        ArticleInfoView(article: placeHolderArticle, subtitle: "The best subtitle in the world! This subtitle also happens to be very long :(")
    }
}
