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
    
    var storedImage: UIImage? = nil
    var subtitle: String? = nil
    
    init(article: Article, content: String) {
        self.article = article
        self.content = content
        
        if article.isSaved() {
            let parsed = parseArticleImage(content, articleURL: article.url).first
            self.storedImage = {
                let file = article.getStoredImages()?
                    .filter { $0.lastPathComponent == parsed?.value?.lastPathComponent }
                    .first?
                    .formatted()
                    .replacingOccurrences(of: "file:/", with: "") ?? ""
                
                return  UIImage(contentsOfFile: file)
            }()
            self.subtitle = FilterToPure(doc: parsed?.key ?? "")
        }
    }
    
    var body: some View {
        if storedImage != nil {
            VStack {
                Image(uiImage: storedImage!)
                    .resizable()
                    .scaledToFit()
                    .background {
                        Rectangle()
                            .cornerRadius(8)
                            .foregroundColor(.white)
                            .opacity(0.6)
                    }
                    .contextMenu {
                        Menu {
                            Label("IMAGE_STORED_ON_DISK", systemImage: "checkmark")
                        } label: {
                            Label("IMAGE_INFO", systemImage: "ladybug")
                        }
                    }
                Text(subtitle ?? "")
                    .font(.headline)
            }
            .padding(.vertical)
        } else {
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
                .background {
                    Rectangle()
                        .cornerRadius(8)
                        .foregroundColor(.white)
                        .opacity(0.6)
                }
                .contextMenu {
                    Menu {
                        Label("IMAGE_STORED_ON_DISK", systemImage: "xmark")
                        
                        if let url = parsed?.value {
                            Link(destination: url) {
                                Text(url.formatted())
                            }
                        } else {
                            Text("error finding url")
                        }
                    } label: {
                        Label("IMAGE_INFO", systemImage: "ladybug")
                    }
                    .frame(maxWidth: .infinity)
                }
                Text(FilterToPure(doc: parsed?.key ?? ""))
                    .font(.headline)
            }
            .padding(.vertical)
        }
    }
}

func parseArticleImage(_ source: String, articleURL: URL) -> [String?:URL?] {
    var newURL = ""
    var caption: String? = ""
    // New Format
    let content = try! source.replacing(Regex(#"htt(p|ps):(\/\/|\*)"#), with: "https://")
    let stringArticleURL = try! articleURL.formatted().replacing(Regex(#"htt(p|ps):"#), with: "https:")
    
    if content.contains(":scp-wiki:component:image-features-source") {
        guard let tempURL = matches(for: #"(?<=[^-]url=).*?(?=(]]|\n|\|))"#, in: content).first else { return [nil:nil] }
        
        if content.contains("http") {
            newURL = tempURL
        } else {
            newURL = "https://scp-wiki.wdfiles.com/local--files/" + (stringArticleURL.slice(from: "scp-wiki.wikidot.com/") ?? "") + "/" + tempURL
        }
    
        caption = matches(for: #"(?<=[^-]caption=).*?(?=(]]|\n|\|))"#, in: content).first
    } else if content.contains(":image-block") {
        // Old Format
        guard var name = matches(for: #"(?<=name=).*?(?=(\n|\|))"#, in: content).first else { return [nil:nil] }
        name = name.replacingOccurrences(of: " ", with: "")
 
        if name.contains("http") {
            newURL = name
        } else {
            newURL = "https://scp-wiki.wdfiles.com/local--files/" + (stringArticleURL.slice(from: "scp-wiki.wikidot.com/") ?? "") + "/" + name
        }
        caption = content.slice(from: "caption=", to: "|") ?? content.slice(from: "caption=", to: "]]")
        
    } else if content.contains("[[") && content.contains("image ") {
        if content.contains("http") {
            newURL = (content.slice(from: "image ", to: " ") ?? content.slice(from: "image ", to: "]]") ?? "")
        } else {
            newURL = "https://scp-wiki.wdfiles.com/local--files/" + (stringArticleURL.slice(from: "scp-wiki.wikidot.com/") ?? "") + "/" + (content.slice(from: "image ", to: " ") ?? content.slice(from: "image ", to: "]]") ?? "")
        }
    }
    
    return [caption : URL(string: newURL
        .replacingOccurrences(of: "http://", with: "https://")
        .replacingOccurrences(of: "local~~", with: "local--")
        .trimmingCharacters(in: .whitespaces)
    )]
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
