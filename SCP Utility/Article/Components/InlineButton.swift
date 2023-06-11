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
    var body: some View {
        let body = parseLink(content)
        let list = parseRT(body, stopRecursiveFunction: true)
        ForEach(Array(zip(list, list.indices)), id: \.1) { item, _ in
            item.toCorrespondingView(article: article)
        }
        
    }
}

fileprivate func findLinks(_ doc: String) -> [String:URL] {
    var content = doc
    var returnDict: [String:URL] = [:]
    for _ in content.indicesOf(string: "http") {
        let urlString = "http" + (content.slice(from: "(http", to: ")") ?? "")
        let title = content.slice(from: "[", to: "](http") ?? ""
        
        content.removeText(from: "[\(title)", to: "\(urlString)]")
        
        returnDict[title] = URL(string: urlString)
    }
    
    return returnDict
}

fileprivate func parseLink(_ content: String) -> String {
    var doc = try! content.replacing(Regex(#"htt(p|ps):\*"#), with: "https://")
    for _ in doc.indicesOf(string: "[[[") {
        let element = doc.slice(with: "[[[", and: "]]]")
        if let link = element.slice(from: "[[[", to: "|"), let text = element.slice(from: "|", to: "]]]") {
            if link.contains("http") {
                doc = doc.replacingOccurrences(
                    of: element,
                    with: "[\(text)](\(link.replacingOccurrences(of: " ", with: "-")))"
                )
            } else {
                doc = doc.replacingOccurrences(
                    of: element,
                    with: "[\(text)](https://scp-wiki.wikidot.com/\(link.replacingOccurrences(of: " ", with: "-")))"
                )
            }
        } else if let combined = element.slice(from: "[[[", to: "]]]") {
            doc = doc.replacingOccurrences(
                of: element,
                with: "[\(combined)](https://scp-wiki.wikidot.com/\(combined.replacingOccurrences(of: " ", with: "-")))"
            )
        }
    }
    
    for _ in doc.indicesOf(string: "[http") {
        if let link = doc.slice(from: "[http", to: " "), let text = doc.slice(from: link + " ", to: "]") {
            doc = doc.replacingOccurrences(
                of: "[http" + link + " " + text + "]",
                with: "[\(text)](http\(link))"
            )
        }
    }

    doc = doc.replacingOccurrences(of: "\n", with: "")
    return doc
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
