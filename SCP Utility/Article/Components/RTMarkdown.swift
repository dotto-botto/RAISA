//
//  RTMarkdown.swift
//  SCP Utility
//
//  Created by Maximus Harding on 6/25/23.
//

import SwiftUI
import MarkdownUI

/// Struct that handles all text in an article.
struct RTMarkdown: View {
    @State var article: Article
    @State var text: String
    @State private var nextArticle: Article = placeHolderArticle
    @State private var showSheet: Bool = false
    
    @AppStorage("focusedCurrentText") var focusedCurrentText: String = ""
    var body: some View {
        VStack {
            Markdown(parseLink(colorToButton(text: text)))
                .markdownTextStyle(\.text) {
                    if let num = findSize() {
                        FontSize(num * 15)
                    }
                }
                .markdownTextStyle(\.code) {
                    ForegroundColor(findTint() ?? .primary)
                }
                .environment(\.openURL, OpenURLAction { url in
                    guard url.formatted().contains("scp") else { return .systemAction }
                    callAPI(url: url)
                    return .handled
                })
            
            if focusedCurrentText == text && focusedCurrentText != "" {
                HStack {
                    Text("BOOKMARKED")
                    Image(systemName: "bookmark.fill")
                }
                .foregroundColor(article.findTheme()?.themeAccent ?? .accentColor)
                .padding(.vertical, 3)
            }
        }
        .textSelection(.enabled)
        .onTapGesture(count: 2) {
            let newText: String? = focusedCurrentText == text ? nil : text
            article.setScroll(newText)
            if !article.isSaved() { article.saveToDisk() }
            focusedCurrentText = newText ?? ""
        }
        .task { focusedCurrentText = article.currenttext ?? "" }
        .onChange(of: nextArticle.id) { _ in
            showSheet = true
        }
        .fullScreenCover(isPresented: $showSheet) {
            NavigationStack { ArticleView(scp: nextArticle, dismissText: article.title, markLatest: false) }
        }
        .id(text)
    }
}

extension RTMarkdown {
    private func findTint() -> Color? {
        guard let color = self.text.slice(from: "## ##", to: "|") ?? self.text.slice(from: "##", to: "|") else { return nil }
        if color.contains(/^#?([[:xdigit:]]{6}|[[:xdigit:]]{3})$/) {
            return Color(hex: color)
        } else {
            return Color("RT\(color.lowercased())")
        }
    }
    
    private func colorToButton(text markdown: String) -> String {
        var newText = markdown
        for match in matches(for: #"###?[^|#]*\|.*?##"#, in: markdown) {
            let text = match.slice(from: "|", to: "##") ?? match
            newText = newText
                .replacingOccurrences(of: match, with: "`\(text)`")
                .replacingOccurrences(of: "**", with: "")
        }
        
        return try! newText
            .replacing(Regex(#"(\[\[size .*?\]\]|\[\[\/size\]\])"#), with: "")
    }
    
    private func findSize() -> CGFloat? {
        guard self.text.starts(with: /\[\[size.*?\]\]/) else { return nil }
        
        guard let size = matches(for: #"(?<=\[\[size ).*?(?=(%\]\]|\]\]|em\]\]))"#, in: self.text).first else { return nil }
        if !size.contains(".") {
            if let double = Double(size) {
                return CGFloat(double / 100)
            }
        } else {
            guard let double = Double(size) else { return nil }
            return CGFloat(double)
        }
        
        return nil
    }
    
    private func callAPI(url: URL) {
        raisaSearchFromURL(query: url) { article in
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

extension Color {
    // https://stackoverflow.com/a/56874327/11248074
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

struct RTMarkdown_Previews: PreviewProvider {
    static var previews: some View {
        RTMarkdown(article: placeHolderArticle, text: """
Various anomalous phenomena may occur when consistent nomenclature is applied to **##green|the realm of the unnamable##**, its native entities, or its landmarks. These phenomena are still poorly understood, partially due to the prohibition of nomenclative experimentation under Order O5-4000-F26.
""").previewDisplayName("Color")
        
        let text =  """
[[size 0.5em]]TO THE COWARD ELIAS SHAW[[/size]]

BY THE AUTHORITY OF HER SALTIEST MAJESTY

[[size 270%]]✧･ﾟ: *✧･ﾟ:*ELIAS SHAW*:･ﾟ✧*:･ﾟ✧[[/size]]

[[size 125%]]Pirate Queen, Raider of the High Seas, Mad Butterfly of the Rolling Waves,[[/size]]

[[size 120%]]WE DO COMMAND YOU TO APPEAR BEFORE THE PIRATE COUNCIL TO NEGOTIATE THE RELEASE OR BUTT-STABBING AND THEN EXECUTION OF ONE:[[/size]]

[[size 350%]]TROY LAMENT[[/size]]

[[size 150%]]HIS CRIMES ARE NUMEROUS:[[/size]]

[[size 120%]]**Lollygagging**[[/size]]

[[size 120%]]**Saying Hurtful Things**[[/size]]

[[size 120%]]**Criticizing Queen Shaw's Very Good Hat**[[/size]]

[[size 120%]]**Fornication with a DUCK**[[/size]]

[[size 120%]]**I WAS THE DUCK**[[/size]]
@@@@
@@@@
[[size 150%]]**THIS WON'T BE FORGIVEN**[[/size]]

@@@@
@@@@

[[size 200%]](✿˵◕‿◕˵) ##red|APPEAR OR BE BUTT STABBED## (˶◕‿◕˶✿)[[/size]]
"""
        VStack {
            ForEach(text.components(separatedBy: .newlines), id: \.self) { line in
                RTMarkdown(article: placeHolderArticle, text: line)
            }
        }.previewDisplayName("Size")
    }
}
