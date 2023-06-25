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
    
    var body: some View {
        Markdown(colorToButton(text: text))
            .markdownTextStyle(\.code) {
                ForegroundColor(findTint() ?? .accentColor)
            }
            .id(text)
            .contextMenu {
                Button {
                    article.setScroll(text)
                } label: {
                    Label("SAVE_POSITION_PROMPT", systemImage: "bookmark")
                }
            }
    }
    
    private func findTint() -> Color? {
        guard let color = self.text.slice(from: "##", to: "|") else { return nil }
        if color.contains(/[0-9]/) {
            return Color(hex: color)
        } else {
            return Color("RT\(color.lowercased())")
        }
    }
    
    private func colorToButton(text markdown: String) -> String {
        var newText = markdown
        for match in matches(for: #"##[^|]*\|(.*?)##"#, in: markdown) {
            let text = match.slice(from: "|", to: "##") ?? match
            newText = newText.replacingOccurrences(of: match, with: "`\(text)`")
        }
        
        return FilterToPure(doc: newText)
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
""")
    }
}
