//
//  TopCard.swift
//  SCP Utility
//
//  Created by Maximus Harding on 4/29/23.
//

import SwiftUI
import SwiftSoup

/// ExploreView card that displays the top articles parsed from the home page.
struct TopCard: View {
    @State private var titles: [String] = []
    @State private var showArticle: Bool = false
    
    let defaults = UserDefaults.standard
    var body: some View {
        var article = placeHolderArticle
        VStack {
            HStack {
                Text("TOP_CARD")
                    .font(.headline)
                    .fontWeight(.bold)
                    .padding(.leading)
                Spacer()
                Image(systemName: "arrow.clockwise")
                    .padding([.top, .trailing], 5)
                    .onTapGesture { getParse() }
            }
            .padding(.bottom, 1)
            
            HStack {
                ForEach([titles.filter { $0.contains("SCP-") }, titles.filter { !$0.contains("SCP-") }], id: \.self) { list in
                    VStack {
                        ForEach(list, id: \.self) { title in
                            Button {
                                let userIntBranch = RAISALanguage(rawValue: defaults.integer(forKey: "chosenRaisaLanguage")) ?? .english
                                
                                raisaGetArticleFromTitle(title: title, language: userIntBranch) {
                                    guard let art = $0 else { return }
                                    article = art
                                    showArticle = true
                                }
                            } label: {
                                Text(title).font(.monospaced(.body)())
                            }
                            Divider()
                        }
                        Spacer()
                    }
                }
            }
        }
        .padding(10)
        .fullScreenCover(isPresented: $showArticle) {
            NavigationStack { ArticleView(scp: article) }
        }
        .onAppear {
            let timeOfLastParse = Date(timeIntervalSince1970: defaults.double(forKey: "timeOfLastParse")).timeIntervalSinceNow
            if timeOfLastParse < -604800 {
                getParse()
            } else {
                titles = defaults.stringArray(forKey: "topTitles") ?? []
            }
        }
    }
    
    func getParse() {
        parseTopRatedPage() {
            titles = $0
            defaults.set(titles, forKey: "topTitles")
            defaults.set(Date().timeIntervalSince1970, forKey: "timeOfLastParse")
        }
    }
}

func parseTopRatedPage(completion: @escaping ([String]) -> Void) {
    let url = URL(string: "https://scp-wiki.wikidot.com/top-rated-pages-this-month")!
    let task = URLSession.shared.dataTask(with: url) { data, response, error in
        guard let data = data else { return }
        do {
            let articledoc = try SwiftSoup.parse(String(data: data, encoding: .utf8) ?? "")
            
            var returnArray: [String] = []

            if let table = try articledoc.getElementsByClass("wiki-content-table").first() {
                for ele in try table.select("a") {
                    returnArray.append(try ele.text())
                }
            }
            
            if let taleTable = try articledoc.getElementsByClass("content-box tale").select("table").first() {
                for ele in try taleTable.select("a") {
                    returnArray.append(try ele.text())
                }
            }
            completion(returnArray)
        } catch {
            print(error)
        }
    }
    task.resume()
}

struct TopCard_Previews: PreviewProvider {
    static var previews: some View {
        TopCard()
    }
}
