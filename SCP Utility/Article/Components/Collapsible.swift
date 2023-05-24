//
//  Collapsible.swift
//  SCP Utility
//
//  Created by Maximus Harding on 4/6/23.
//

import SwiftUI
#if os(iOS)
import MarkdownUI
#endif

/// Collapsible text to be displayed inside RAISAText
/// "text" should be the text from "[[collapsible" to "[[/collapsible]]" including those two lines.
struct Collapsible: View {
    @State var article: Article
    @State var text: String
    @State var showed: Bool = false
    var body: some View {
        if text.contains("[[collapsible") && text.contains("[[/collapsible]]") {
            let show = text.slice(from: " show=\"", to: "\"")
            let hide = text.slice(from: " hide=\"", to: "\"")
            let content = text.slice(from: "]]", to: "[[/collapsible]]")

            if show != nil && hide != nil {
                VStack {
                    HStack { // without hstack the button snaps to middle when shown
                        Button {
                            showed.toggle()
                        } label: {
                            Text(showed ? hide! : show!).foregroundColor(.accentColor)
                        }
                        Spacer()
                    }
                    if showed {
                        RAISAText(article: article, text: content)
                    }
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
"""
        )
    }
}
