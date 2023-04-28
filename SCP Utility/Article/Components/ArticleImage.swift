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
    @State var articleURL: URL
    @State var content: String
    var body: some View {
        var newURL = ""
        var caption: String? = ""
        // New Format
        if content.contains(":scp-wiki:component:image-features-source") {
            let stringURL = articleURL.formatted()
            if let tempURL = content.slice(from: "|url=", to: "|") {
                let _ = newURL = "https://scp-wiki.wdfiles.com/local--files/" + (stringURL.slice(from: "scp-wiki.wikidot.com/") ?? "") + "/" + tempURL
            }
            let _ = caption = content.slice(from: "|caption=", to: "|") ?? content.slice(from: "|caption=", to: "]]")
        } else if content.contains(":image-block") {
            // Old Format
            let stringURL = articleURL.formatted()
            let name = content.slice(from: "name=", to: "|") ?? ""
            if name.contains("http") {
                let _ = newURL = name
                    .replacingOccurrences(of: "*", with: "//") // Text filtering replaces "//" with "*"
                    .replacingOccurrences(of: "http", with: "https")
            } else {
                let _ = newURL = "https://scp-wiki.wdfiles.com/local--files/" + (stringURL.slice(from: "scp-wiki.wikidot.com/") ?? "") + "/" + name
            }
            let _ = caption = content.slice(from: "caption=", to: "|") ?? content.slice(from: "caption=", to: "]]")
        } else if content.contains("[[image") {
            if content.contains("http") { let _ = newURL = content.slice(with: "http", and: " ") }
            else {
                let stringURL = articleURL.formatted()
                let _ = newURL = "https://scp-wiki.wdfiles.com/local--files/" + (stringURL.slice(from: "scp-wiki.wikidot.com/") ?? "") + (content.slice(from: " ", to: " ") ?? "")
            }
        }
        
        if UserDefaults.standard.bool(forKey: "showImages") {
            VStack {
                KFImage(URL(string: newURL))
                    .resizable()
                    .scaledToFit()
                Text(caption ?? "")
                    .font(.headline)
            }
            .padding(.vertical)
        }
    }
}

struct ArticleImage_Previews: PreviewProvider {
    static var previews: some View {
        ArticleImage(
            articleURL: URL(string: "http://scp-wiki.wikidot.com/scp-5004")!,
            content: "[[include component:image-block name=hughes.jpg|align=right|width=35%|caption=United States Supreme Court Justice Charles Evans Hughes.]]"
        ).previewDisplayName("Old Format")
        ArticleImage(
            articleURL: URL(string: "http://scp-wiki.wikidot.com/scp-049")!,
            content: """
                    [[include :scp-wiki:component:image-features-source |hover-enlarge=--]
                    |enlarge-amount=6
                    |speed=250
                    |float=true
                    |align=right
                    |width=400px
                    |url=049xray.jpg|add-caption=true
                    |caption=X-Ray imaging of SCP-049's facial structure.
                    ]]
                    """
        ).previewDisplayName("New Format")
        ArticleImage(
            articleURL: URL(string: "https://scp-wiki.wikidot.com/scp-179")!,
            content: "[[image SCPArchiveLogo.png width=\"140px\"]]"
        ).previewDisplayName("Compact Format")
    }
}
