//
//  FeaturedCard.swift
//  SCP Utility
//
//  Created by Maximus Harding on 4/8/26.
//

import SwiftUI
import SwiftSoup

struct FeaturedCard: View {
    @State private var author: String? = nil
    @State private var blurb: String? = nil
    @State private var article: Article? = nil
    @State private var showArticle: Bool = false
    
    @EnvironmentObject var subtitlesStore: SubtitlesStore
    var body: some View {
        VStack {
            HStack {
                Text("FEATURED_SCP")
                    .font(.headline)
                    .fontWeight(.bold)
                    .padding(.leading)
                Spacer()
            }
            
            if let article {
                VStack {
                    HStack {
                        Text(article.title)
                            .font(.monospaced(.title2)())
                            .lineLimit(1)
                        Text("—")
                        Text(RaisaReq.getAlternateTitle(url: article.url, store: subtitlesStore) ?? "")
                            .font(.monospaced(.title2)())
                            .lineLimit(1)
                            
                        Image(systemName: "arrow.forward")
                    }
                    
                    if let author {
                        Text("FEATURED_CARD_BY_\(author)")
                            .font(.monospaced(.caption2)())
                            .padding(.horizontal, 10)
                    }
                    
                    if let blurb {
                        Text(blurb)
                            .font(.monospaced(.caption)())
                            .padding(.horizontal, 10)
                    }
                }
            } else {
                ProgressView()
            }
        }
        .onTapGesture {
            if article != nil {
                showArticle = true
            }
        }
        .fullScreenCover(isPresented: $showArticle) { 
            if let article {
                NavigationStack { ArticleView(scp: article) }
            }
        }
        .task {
            parseFeaturedSCP {
                author = $1
                blurb = $2
                
                if let u = $0 {
                    RaisaReq.articlefromURL(url: u) { art, _ in
                        article = art
                    }
                }
            }
        }
    }
}

// Returns: url to article, author, blurb
func parseFeaturedSCP(completion: @escaping (URL?, String?, String?) -> Void) {
    let url = URL(string: "https://scp-wiki.wikidot.com/")!
    let task = URLSession.shared.dataTask(with: url) { data, response, error in
        guard let data = data else { return }
        do {
            let articledoc = try SwiftSoup.parse(String(data: data, encoding: .utf8) ?? "")
            
            var returnURL: URL? = nil
            var returnAuthor: String? = nil
            var returnBlurb: String? = nil
            
            if let box = try articledoc.getElementsByClass("box feature1box").first() {
                for ele in try box.select("a") {
                    returnURL = try URL(string: ele.attr("href"))
                }
                
                if let author = try box.getElementsByClass("feature-subtitle").first() {
                    returnAuthor = try author.text().slice(from: " ")
                }
                
                if let blurb = try box.getElementsByClass("feature-blurb").first() {
                    returnBlurb = try blurb.text()
                }
            }

            completion(returnURL, returnAuthor, returnBlurb)
        } catch {
            print(error)
        }
    }
    task.resume()
}

#Preview {
    FeaturedCard()
}
