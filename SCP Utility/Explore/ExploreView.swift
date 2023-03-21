//
//  ExploreView.swift
//  SCP Utility
//
//  Created by Maximus Harding on 3/9/23.
//

import SwiftUI
import SwiftSoup

private func parseHomePage() -> [String?] {
    do {
        let html = try String(contentsOf: URL(string: "https://scp-wiki.wikidot.com/")!)
        let doc: Document = try SwiftSoup.parse(html)
        let body: Element? = try doc.getElementsByClass("box newsbox").first()
        
        let issue1: Element? = try body?.getElementsByClass("news").first()
        let date1: String? = try issue1?.getElementById("toc0")?.text()
        let content1: String? = try issue1!.getElementsByTag("p").first()?.text()
        
        let issue2: Element? = try body?.getElementsByClass("news")[1]
        let date2: String? = try issue2?.getElementById("toc1")?.text()
        let content2: String? = try issue2!.getElementsByTag("p").first()?.text()
        
        let url1: String? = try body?.getElementById("toc2")?.select("a").first()?.attr("href")
        let url2: String? = try body?.getElementById("toc3")?.select("a").first()?.attr("href")
        let url3: String? = try body?.getElementById("toc4")?.select("a").first()?.attr("href")
        let url4: String? = try body?.getElementById("toc5")?.select("a").first()?.attr("href")

        return [
            date1,    // 0
            content1, // 1
            date2,    // 2
            content2, // 3
            url1,     // 4
            url2,     // 5
            url3,     // 6
            url4      // 7
        ]
    } catch {
        print(error)
        return [nil]
    }
}

struct ExploreView: View {
    @State var article1 = Article(title: "", pagesource: "")
    @State var article2 = Article(title: "", pagesource: "")
    @State var article3 = Article(title: "", pagesource: "")
    @State var article4 = Article(title: "", pagesource: "")
    var body: some View {
        let news = parseHomePage()
        
        ScrollView {
            VStack {
                // MARK: - Site News
                if news[0] != nil && news[1] != nil && news[2] != nil && news[3] != nil  {
                    Text(news[0]!).bold().padding(.trailing)
                    Text(news[1]!).padding(.trailing)
                    Text(news[2]!).bold().padding(.trailing)
                    Text(news[3]!).padding(.trailing)
                }
                
                // MARK: - Spotlights
                if news[4] != nil {
                    Text("FEATURED_SCP").bold()
                    let _ = cromAPISearchFromURL(query: news[4]!) { article in
                        article1 = article
                    }
                    ArticleSpotlight(scp: article1)
                }
                Text("FEATURED_TALE").bold()
                
                Text("FEATURED_GOI").bold()
                
                Text("REVIEWER_SPOTLIGHT").bold()
                
                Text("FEATURED_ART").bold()
                
            }
            .navigationTitle("SITE_NEWS")
        }
    }
}

struct ExploreView_Previews: PreviewProvider {
    static var previews: some View {
        ExploreView()
    }
}
