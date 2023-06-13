//
//  Collapsible.swift
//  SCP Utility
//
//  Created by Maximus Harding on 4/6/23.
//

import SwiftUI

/// Collapsible text to be displayed inside RAISAText
/// "text" should be the text from "[[collapsible" to "[[/collapsible]]" including those two lines.
struct Collapsible: View {
    var article: Article
    var text: String

    var show: String
    var hide: String
    var content: String
    @State var showed: Bool

    init(article: Article, text: String, openOnLoad open: Bool = false) {
        let content = text.slice(from: "]]", to: "[[/collapsible]]") ?? text.slice(from: "]]", to: "[[/Collapsible]]") ?? "no content"

        let show = text.slice(from: "show=\"", to: "\"") ?? "+ show block"
        let hide = text.slice(from: "hide=\"", to: "\"") ?? "- hide block"

        self.article = article
        self.text = text

        self.show = show
        self.hide = hide
        self.content = content
        
        self._showed = State(initialValue: open)
    }

    var body: some View {
        VStack {
            HStack { // without hstack the button snaps to middle when shown
                Button(showed ? hide : show) {
                    showed.toggle()
                }
                Spacer()
            }
            if showed {
                RAISAText(article: article, text: content)
                
                HStack {
                    Text("BLOCK_END_INDICATOR").foregroundColor(.secondary)
                    Image(systemName: "chevron.right.2").foregroundColor(.secondary)
                    Rectangle()
                        .frame(height: 0.5)
                        .foregroundColor(.secondary)
                    Image(systemName: "chevron.left.2").foregroundColor(.secondary)
                }
            }
        }
    }
}

struct Collapsible_Previews: PreviewProvider {
    static var previews: some View {
        Collapsible(
            article: placeHolderArticle,
            text: """
[[collapsible show="+ Open" hide="- Close"]]
This text is in a collapsible.
[[/collapsible]]
"""
        )
        
        Collapsible(
            article: placeHolderArticle,
            text: """
[[collapsible hide="SECURITY MEMETIC: WE DID NOT FAIL THEM" show="Incident Report 2001-19██-A: LEVEL 4 CLEARANCE REQUIRED" hideLocation=both]]
This text is also in a collapsible.
[[/collapsible]]
""", openOnLoad: true
        )
    }
}
