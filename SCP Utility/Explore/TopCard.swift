//
//  TopCard.swift
//  SCP Utility
//
//  Created by Maximus Harding on 4/29/23.
//

import SwiftUI
import SwiftSoup

struct TopCard: View {
    @State private var titles: [String] = []
    @State private var showArticle: Bool = false
    var body: some View {
        var article = placeHolderArticle
        VStack {
            HStack {
                Text("Popular Articles")
                    .font(.headline)
                    .fontWeight(.bold)
                    .padding(.leading)
                Spacer()
            }
            .padding(.bottom, 1)
            
            ForEach(titles, id: \.self) { title in
                Button {
                    cromGetSourceFromTitle(title: title) { art in
                        article = art
                        showArticle = true
                    }
                } label: {
                    Text(title).font(.monospaced(.body)())
                }
                Divider()
                
            }
        }
        .padding(10)
        .fullScreenCover(isPresented: $showArticle) {
            NavigationStack { ArticleView(scp: article) }
        }
        .onAppear {
            parseTopRatedPage() { strs in
                titles = strs
            }
        }
    }
}

/// Returns the top 5 articles
func parseTopRatedPage(completion: @escaping ([String]) -> Void) {
    DispatchQueue.main.async {
        do {
            let articledoc = try SwiftSoup.parse(String(contentsOf: URL(string: "https://scp-wiki.wikidot.com/top-rated-pages-this-month")!))
            
            var returnArray: [String] = []

            if let table = try articledoc.getElementsByClass("wiki-content-table").first() {
                for ele in try table.select("a") {
                    returnArray.append(try ele.text())
                }
            }
            completion(returnArray)
        } catch {
            print(error)
        }
    }
}

struct TopCard_Previews: PreviewProvider {
    static var previews: some View {
        TopCard()
    }
}
