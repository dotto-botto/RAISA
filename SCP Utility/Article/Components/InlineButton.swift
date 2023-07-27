//
//  InlineButton.swift
//  SCP Utility
//
//  Created by Maximus Harding on 4/19/23.
//

import SwiftUI

/// View that handles links inside text.
struct InlineButton: View {
    @State var article: Article
    @State var content: String
    
    @State private var showDialog: Bool = false
    @State private var links: [String:URL] = [:]
    
    @State private var nextArticle: Article = placeHolderArticle
    @State private var showSheet: Bool = false
    
    var body: some View {
        let body = parseLink(content)
        let list = parseRT(body, stopRecursiveFunction: true)
        ForEach(Array(zip(list, list.indices)), id: \.1) { item, _ in
            item.toCorrespondingView(article: article)
                .environment(\.openURL, OpenURLAction { url in
                    guard url.formatted().contains("scp") else { return .systemAction }
                    callAPI(url: url)
                    return .handled
                })
        }
        .onChange(of: nextArticle.id) { _ in
            showSheet = true
        }
        .fullScreenCover(isPresented: $showSheet) {
            NavigationStack { ArticleView(scp: nextArticle, dismissText: article.title, markLatest: false) }
        }
    }
    
    private func callAPI(url: URL) {
        cromAPISearchFromURL(query: url) { article in
            guard let article = article else { return }
            nextArticle = article
        }
    }
    
    private func parseLink(_ content: String) -> String {
        var doc = try! content.replacing(Regex(#"https?:\*"#), with: "https://")
            .replacingOccurrences(of: "[[[/", with: "[[[") // some articles put a slash in front of the link
        
        let baseURL: String = RAISALanguage(rawValue: UserDefaults.standard.integer(forKey: "chosenRaisaLanguage"))?.toURL().formatted() ?? "https://scp-wiki.wikidot.com/"
        
        for _ in doc.indicesOf(string: "[[[") {
            let element = doc.slice(with: "[[[", and: "]]]")
            if var link = element.slice(from: "[[[", to: "|"), let text = element.slice(from: "|", to: "]]]") {
                link = link
                    .trimmingCharacters(in: .whitespaces)
                    .replacingOccurrences(of: " ", with: "-")
                if link.contains("http") {
                    doc = doc.replacingOccurrences(
                        of: element,
                        with: "[\(text)](\(link))"
                    )
                } else {
                    doc = doc.replacingOccurrences(
                        of: element,
                        with: "[\(text)](\(baseURL)/\(link))"
                    )
                }
            } else if let combined = element.slice(from: "[[[", to: "]]]") {
                doc = doc.replacingOccurrences(
                    of: element,
                    with: "[\(combined)](\(baseURL)/\(combined.replacingOccurrences(of: " ", with: "-")))"
                )
            }
        }

        for match in matches(for: #"\[(\*|)http.*?]"#, in: doc) {
            if let link = match.slice(from: "[", to: " "), let text = doc.slice(from: link + " ", to: "]") {
                doc = doc.replacingOccurrences(
                    of: "[\(link) \(text)]",
                    with: "[\(text)](\(link))"
                )
            }
        }

        doc = doc.replacingOccurrences(of: "\n", with: "")
        doc = doc.replacingOccurrences(of: "*http", with: "http")
        return doc
    }
}

struct InlineButton_Previews: PreviewProvider {
    static var previews: some View {
        InlineButton(
            article: placeHolderArticle,
            content: """
SCP-231-1 through 7 were retrieved from ██████████, ██, following a police raid on a warehouse owned by an organization called the Children of the [[[dust-and-blood|Scarlet King]]] (see article on ██-██-████ in the ████████████ ██████ newspaper, "[[[kte-2013-kapala-mendes|Police Raid Satanic Sex Cult, Save Seven]]]").
[scarlet king](https://scp-wiki.wikidot.com/)
""")
    }
}
