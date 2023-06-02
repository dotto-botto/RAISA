//
//  ArticleImage.swift
//  SCP Utility
//
//  Created by Maximus Harding on 4/7/23.
//

import SwiftUI
import Kingfisher

/// Image view to be displayed inside ArticleView.
struct ArticleImage: View {
    var article: Article
    var content: String
    
    init(article: Article, content: String) {
        self.article = article
        self.content = content
    }
    
    var body: some View {
        let parsed = parseArticleImage(content, articleURL: article.url).first
        VStack {
            AsyncImage(url: parsed?.value) { image in
                image
                .resizable()
                .scaledToFit()
            } placeholder: {
                    Image("image-placeholder")
                        .resizable()
                        .scaledToFit()
                }
            Text(parsed?.key ?? "")
                .font(.headline)
        }
        .padding(.vertical)
    }
}

fileprivate func parseArticleImage(_ content: String, articleURL: URL) -> [String?:URL?] {
    var newURL = ""
    var caption: String? = ""
    // New Format
    if content.contains(":scp-wiki:component:image-features-source") {
        let stringURL = articleURL.formatted()
        guard let tempURL = content.slice(from: "url=", to: "|")  else { return [nil:nil] }
        
        if content.contains("http") {
            newURL = tempURL
                .replacingOccurrences(of: "*", with: "//") // Text filtering replaces "//" with "*"
                .replacingOccurrences(of: "http:", with: "https:")
        } else {
            newURL = "https://scp-wiki.wdfiles.com/local--files/" + (stringURL.slice(from: "scp-wiki.wikidot.com/") ?? "") + "/" + tempURL
        }
    
        if content.contains("add-caption") {
            caption = content.slice(from: "| caption=", to: "|") ?? content.slice(from: "| caption=", to: "]]")
        } else {
            caption = content.slice(from: "caption=", to: "|") ?? content.slice(from: "caption=", to: "]]")
        }
    } else if content.contains(":image-block") {
        // Old Format
        let stringURL = articleURL.formatted()
        let name = (content.slice(from: "name=", to: " |") ?? content.slice(from: "name=", to: "|") ?? "")
            .replacingOccurrences(of: "= ", with: "")
            .replacingOccurrences(of: "\n", with: "")
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: " http", with: "http")
        if name.contains("http") {
            newURL = name
                .replacingOccurrences(of: "*", with: "//") // Text filtering replaces "//" with "*"
                .replacingOccurrences(of: "http:", with: "https:")
        } else {
            newURL = "https://scp-wiki.wdfiles.com/local--files/" + (stringURL.slice(from: "scp-wiki.wikidot.com/") ?? "") + "/" + name
        }
        caption = content.slice(from: "caption=", to: "|") ?? content.slice(from: "caption=", to: "]]")
    } else if content.contains("[[") && content.contains("image ") {
        if content.contains("http") {
            newURL = (content.slice(from: "image ", to: " ") ?? content.slice(from: "image ", to: "]]") ?? "")
                .replacingOccurrences(of: "*", with: "//")
                .replacingOccurrences(of: "http:", with: "https:")
        } else {
            let stringURL = articleURL.formatted()
            newURL = "https://scp-wiki.wdfiles.com/local--files/" + (stringURL.slice(from: "scp-wiki.wikidot.com/") ?? "") + "/" + (content.slice(from: "image ", to: " ") ?? "")
        }
    }
    
    return [caption : URL(string: newURL)]
}

//struct ArticleImage_Previews: PreviewProvider {
//    static var previews: some View {
//        ArticleImage(
//            article: placeHolderArticle,
//            content: "[[include component:image-block name=hughes.jpg|align=right|width=35%|caption=United States Supreme Court Justice Charles Evans Hughes.]]"
//        ).previewDisplayName("Old Format")
//
//        ArticleImage(
//            article: placeHolderArticle,
//            content: """
//                    [[include :scp-wiki:component:image-features-source |hover-enlarge=--]
//                    |enlarge-amount=6
//                    |speed=250
//                    |float=true
//                    |align=right
//                    |width=400px
//                    |url=049xray.jpg|add-caption=true
//                    |caption=X-Ray imaging of SCP-049's facial structure.
//                    ]]
//                    """
//        ).previewDisplayName("New Format")
//
//        ArticleImage(
//            article: placeHolderArticle,
//            content: "[[image SCPArchiveLogo.png width=\"140px\"]]"
//        ).previewDisplayName("Compact Format")
//    }
//}
