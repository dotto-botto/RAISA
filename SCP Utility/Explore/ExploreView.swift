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

        
        return [date1, content1, date2, content2]
    } catch {
        print(error)
        return [nil]
    }
}

struct ExploreView: View {
    var body: some View {
        let news = parseHomePage()
        
        ScrollView {
            VStack {
                // MARK: - Site News
                Text("SITE_NEWS")
                if news[0] != nil && news[1] != nil && news[2] != nil && news[3] != nil  {
                    Text(news[0]!).bold().padding(.trailing)
                    Text(news[1]!).padding(.trailing)
                    Text(news[2]!).bold().padding(.trailing)
                    Text(news[3]!).padding(.trailing)
                }
                
                // MARK: - Spotlights
                Text("FEATURED_SCP").bold()
//                ArticleSpotlight(scp: cromURLSearch(query: ))
                Text("FEATURED_TALE").bold()
                
                Text("FEATURED_GOI").bold()
                
                Text("REVIEWER_SPOTLIGHT").bold()
                
                Text("FEATURED_ART").bold()
                
            }
        }
        .navigationTitle("EXPLORE_TITLE")
    }
}

struct ExploreView_Previews: PreviewProvider {
    static var previews: some View {
        ExploreView()
    }
}
