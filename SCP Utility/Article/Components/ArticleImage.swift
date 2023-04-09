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
        // New format
        if content.contains(":scp-wiki:component:image-features-source") {
            let stringURL = articleURL.formatted()
            let stringLast = stringURL.last!.description
            if let tempURL = content.slice(from: "|url=", to: "|") {
                let _ = newURL = "https://scp-wiki.wdfiles.com/local--files/" + stringURL.slice(from: "http://scp-wiki.wikidot.com/", to: stringLast)! + stringLast + "/" + tempURL
            }
            let _ = caption = content.slice(from: "|caption=", to: "|")
            if caption == nil {
                let _ = caption = content.slice(from: "|caption=", to: "]]")
            }
        } else if content.contains(":image-block") {
            // Old Format
            let stringURL = articleURL.formatted()
            let stringLast = stringURL.last!.description
            let _ = newURL = "https://scp-wiki.wdfiles.com/local--files/" + stringURL.slice(from: "http://scp-wiki.wikidot.com/", to: stringLast)! + stringLast + "/" + content.slice(from: "name=", to: "|")!
            let _ = caption = content.slice(from: "caption=", to: "|")
            if caption == nil {
                let _ = caption = content.slice(from: "caption=", to: "]]")
            }
        }
        
        VStack {
            KFImage(URL(string: newURL)!)
                .resizable()
                .scaledToFit()
            Text(caption ?? "")
                .font(.headline)
        }.padding(.vertical)
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
    }
}
