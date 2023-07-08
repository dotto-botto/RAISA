//
//  FootnoteView.swift
//  SCP Utility
//
//  Created by Maximus Harding on 7/8/23.
//

import SwiftUI
import MarkdownUI

struct FootnoteView: View {
    @State var article: Article
    @State var selectedNoteIndex: Int? = 0
    
    @State private var footnotes: [String] = []
    var body: some View {
        NavigationStack {
            VStack {
                if !article.pagesource.contains("[[footnote]]") {
                    Text("FV_NO_FOOTNOTES")
                        .padding(.vertical, 300)
                        .foregroundColor(.secondary)
                } else {
                    ScrollView {
                        ForEach(Array(zip(footnotes, footnotes.indices)), id: \.1) { note, index in
                            HStack {
                                Text("\(index + 1).").foregroundColor(.accentColor)
                                RAISAText(article: article, text: note)
                                Spacer()
                            }
                            Divider()
                        }
                        .padding(.horizontal, 20)
                    }
                }
            }
            .navigationTitle("FOOTNOTE_TITLE")
            .navigationBarTitleDisplayMode(.inline)
            .task {
                for note in matches(for: #"(?<=\[\[footnote]])[\s\S]*?(?=\[\[\/footnote]])"#, in: article.pagesource) {
                    FilterToMarkdown(doc: note) {
                        footnotes.append($0)
                    }
                }
            }
        }
    }
}

struct FootnoteView_Previews: PreviewProvider {
    static var previews: some View {
        FootnoteView(article: placeHolderArticle)
    }
}
