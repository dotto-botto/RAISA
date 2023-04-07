//
//  Collapsible.swift
//  SCP Utility
//
//  Created by Maximus Harding on 4/6/23.
//

import SwiftUI
import MarkdownUI

struct Collapsible: View {
    @State var articleID: String
    @State var text: String
    @State var showed: Bool = false
    @State private var tooltip: Bool = false
    var body: some View {
        VStack {
            if text.contains("[[collapsible") && text.contains("[[/collapsible]]") {
                let show = text.slice(from: "[[collapsible show=\"", to: "\" hide=")
                let hide = text.slice(from: "hide=\"", to: "\"]]")
                
                let content = text.slice(from: "\"]]", to: "[[/collapsible]]")
                if show != nil && hide != nil {
                    Button {
                        showed.toggle()
                    } label: {
                        let prompt = showed ? hide! : show!
                        Text(prompt).foregroundColor(.accentColor)
                    }
                    if showed {
                        let list = content!.components(separatedBy: .newlines)
                        ForEach(list, id: \.self) { item in
                            Markdown(FilterToMarkdown(doc: item))
                                .padding(.bottom, 1)
                                .id(item)
                                .onTapGesture {
                                    tooltip = true
                                    PersistenceController.shared.setScroll(text: item, articleid: articleID)
                                }
                        }
                    }
                }
            } else {
                Text(text)
            }
        }
        .alert("PLACE_SAVED", isPresented: $tooltip) {
            Button("OK") {
                tooltip = false
            }
        } message: {
            Text("HOW_TO_SAVE")
        }
    }
}

struct Collapsible_Previews: PreviewProvider {
    static var previews: some View {
        Collapsible(
            articleID: "",
            text: """
[[collapsible show="+ Open" hide="- Close"]]
This text is in a collapsible.
[[/collapsible]]
"""
        )
    }
}
