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
    var body: some View {
//        let news = parseHomePage()
        NavigationView {
            ScrollView {
                VStack {
                    Grid(horizontalSpacing: 12, verticalSpacing: 12) {
                        RandomCard()
                    }
                    .padding([.horizontal, .bottom], 16)
                    .cornerRadius(15)
                }
                .background(Color(uiColor: .systemGroupedBackground))
                .navigationTitle("SITE_NEWS")
            }
        }
    }
}

struct ExploreView_Previews: PreviewProvider {
    static var previews: some View {
        ExploreView()
    }
}
