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
    @State var selectedNoteIndex: Int? = nil
    
    @State private var footnotes: [String] = []
    var body: some View {
        NavigationStack {
            VStack {
                if !article.pagesource.contains("[[footnote]]") {
                    Text("FV_NO_FOOTNOTES")
                        .padding(.vertical, 300)
                        .foregroundColor(.secondary)
                } else {
                    ScrollViewReader { proxy in
                        ScrollView {
                            ForEach(Array(zip(footnotes, footnotes.indices)), id: \.1) { note, index in
                                HStack {
                                    VStack {
                                        Text(verbatim: "\(index + 1).").foregroundColor(.accentColor)
                                        Spacer()
                                    }
                                    .padding(.bottom)
                                    RAISAText(article: article, text: note)
                                    Spacer()
                                }
                                Divider()
                            }
                            .padding(.horizontal, 20)
//                            .onAppear {
//                                if selectedNoteIndex != nil {
//                                    withAnimation {
//                                        proxy.scrollTo(selectedNoteIndex!)
//                                    }
//                                }
//                            }
                        }
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
        FootnoteView(article: Article(title: "Footnote test", pagesource: 
"""
,,{{//Due to the nature of EE-00059, classification as a proper SCP is unnecessary.[[footnote]]{{As of 04/24/2020, EE-00059 and all related documents are to be associated with SCP-001 as a primer for recently-declassified information.}}[[/footnote]] Knowledge of EE-00059's existence has been successfully distorted via a number of large-scale disinformation campaigns, therefore, no containment measures are required at this time. Any credible information regarding activity arising from EE-00059's vicinity should first be traced to its original source, then delegitimized by any means necessary. These tactics are to be carried out by embedded agents stationed in various observatories, places of academia, and media outlets such as television studios and radio stations.//}},,

**Event Description:**  Extranormal Event 00059 was observed on June 14th, 2006, in a region of space roughly 1.6 billion light years from Earth,[[footnote]]Therefore indicating its origin to be ~1.6 billion years in the past.[[/footnote]] located in the constellation Indus. It was detected via the Neil Gehrels //Swift// Observatory telescope system as a prolonged gamma ray burst designated [https://en.wikipedia.org/wiki/GRB_060614 GRB 060614].

EE-00059-1 is an emergent Class-E "Momentary Lapse of Reason" Wormhole (S-CSMWAUC2T)[[footnote]]Spatial, Cycling Stability, Stationary, Manifested, Wide-Area, Uncertain, Conditional Two-Way, Transient. See: //[/classifications-guides-and-icons-by-billith A Discourse on the Unification of Technological Canon, Vis-à-vis the Classification of Extradimensional Portals (i.e. Wormholes)]// and other [[[scp-3989|similar case files]]] for more information.[[/footnote]] that was observed for 102.0 seconds, during which it exhibited atypical behavior that contradicted all known theoretical and applied models of spacetime folds.
""",
                                      url: placeholderURL), selectedNoteIndex: 4)
    }
}
