//
//  ArticleView.swift
//  SCP Wiki Utility
//
//  Created by Maximus Harding on 12/25/22.
//

import SwiftUI
import Foundation
#if os(iOS)
import Kingfisher
import MarkdownUI
#endif
    
// MARK: - View
struct ArticleView: View {
    @State var scp: Article
    @State var presentSheet: Bool = false
    @State var showSafari: Bool = false
    @Environment(\.dismiss) var dismiss
    
    let defaults = UserDefaults.standard
    let con = PersistenceController.shared
    var body: some View {
        let document = scp.pagesource
        
        let mode: Int = defaults.integer(forKey: "articleViewSetting")
        #if os(iOS)
        let _ = PersistenceController.shared.createHistory(from: History(title: scp.title, thumbnail: scp.thumbnail))
        #endif
        
        ScrollView {
            #if os(iOS)
            if scp.thumbnail != nil && defaults.bool(forKey: "showImages") && mode != 2 {
                KFImage(scp.thumbnail)
                    .resizable()
                    .scaledToFit()
                
            }
            #endif
    
            VStack(alignment: .leading) {
                if mode == 0 { // Default
                    Markdown(FilterToMarkdown(doc: document))
                } else if mode == 1 { // Raw
                   Text(document)
                } else if mode == 2 { // Safari
                    if scp.url != nil {
                        Text("LOADING_SAFARI")
                        /*
                         For some reason, if i just put showSafari.toggle()
                         or showSafari = true, then the app never builds.
                         this is a workaround
                         */
                        Text("").onAppear { showSafari = true }
                    } else {
                        Text("NO_ARTICLE_LINK")
                            .font(.largeTitle)
                            .foregroundColor(.gray)
                    }
                }
            }
            .navigationTitle(scp.title)
        }
        .frame(width: 400)
        .sheet(isPresented: $presentSheet) {
            ListAdd(isPresented: $presentSheet, article: scp)
        }
        .fullScreenCover(isPresented: $showSafari) {
            SFSafariViewWrapper(url: scp.url!)
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button(action: {
                    dismiss()
                }, label: {
                    Text("Back")
                })
            }
            ToolbarItem(placement: .primaryAction) {
                Button(action: {
                    presentSheet.toggle()
                }, label: {
                    Image(systemName: "bookmark")
                })
            }
            ToolbarItem {
                if scp.url != nil {
                    Button(action: {
                        showSafari.toggle()
                    }, label: {
                        Image(systemName: "safari")
                    })
                }
            }
        }
    }
}

func FilterToMarkdown(doc: String) -> String {
    var text = doc
    
    // Basic Divs
    for _ in text.indicesOf(string: "[[include") {
        text.removeText(from: "[[include", to: "]]")
    }
    text.removeText(from: "[[div", to: "]]")
    text.removeText(from: "[[/div", to: "]]")
    text.removeText(from: "[[size", to: "]]")
    text.removeText(from: "[[/size", to: "]]")
    text.removeText(from: "[[module", to: "[[/module]]")
    text.removeText(from: "[[>", to: "]]")
    text.removeText(from: "[[/>", to: "]]")
    text.removeText(from: "[[=", to: "/=]]")
    text.removeText(from: "[!--", to: "--]")
    
    // Tables
    for _ in text.indicesOf(string: "[[table") {
        text.removeText(from: "[[table", to: "[[/table]]")
    }

    // Footnotes
    for _ in text.indicesOf(string: "[[footnote") {
        text = text.replacingOccurrences(of: "[[footnote]]", with: " (")
        text = text.replacingOccurrences(of: "[[/footnote]]", with: ")")
    }

    // Links
    for _ in text.indicesOf(string: "[[[") { // Only used for links if i am correct
        if var slicedElement = text.slice(from: "[[[", to: "]]]") {
            if slicedElement.contains("|") {
                slicedElement = "[[[" + slicedElement + "]]]"
                
                if let rawtext = slicedElement.slice(from: "|", to: "]]]") {
                    text = text.replacingOccurrences(of: slicedElement, with: rawtext)
                }
            }
        }
    }
    
    text = text.replacingOccurrences(of: "------", with: "---")
    text = text.replacingOccurrences(of: "@@@@", with: "")
    text = text.replacingOccurrences(of: "//", with: "*")
    text = text.replacingOccurrences(of: " --", with: " ~~")
    text = text.replacingOccurrences(of: "-- ", with: "~~ ")
    text = text.replacingOccurrences(of: "||", with: "|")

    return text
}


// MARK: - Collapsable
struct Collapsable: View {
    @State var show: String
    @State var hide: String
    @State var content: String
    
    @State var showed: Bool = false
    
    var body: some View {
        Button(show) {
            showed = true
        }.disabled(!showed)
        
        Button(hide) {
            showed = false
        }.disabled(showed)
        
        if showed {
            Text(content)
        }
    }
}

// MARK: - Extensions
// https://stackoverflow.com/a/31727051
extension String {
    func slice(from: String, to: String) -> String? {
        return (range(of: from)?.upperBound).flatMap { substringFrom in
            (range(of: to, range: substringFrom..<endIndex)?.lowerBound).map { substringTo in
                String(self[substringFrom..<substringTo])
            }
        }
    }
    
    mutating func removeText(from: String, to: String) {
        let toSlice = self.slice(from: from, to: to)
        if toSlice != nil {
              self = self.replacingOccurrences(of: toSlice!, with: "")
              self = self.replacingOccurrences(of: from + to, with: "")
        }
    }
    
    // https://stackoverflow.com/a/40413665/11248074
    func indicesOf(string: String) -> [Int] {
            var indices = [Int]()
            var searchStartIndex = self.startIndex

            while searchStartIndex < self.endIndex,
                let range = self.range(of: string, range: searchStartIndex..<self.endIndex),
                !range.isEmpty
            {
                let index = distance(from: self.startIndex, to: range.lowerBound)
                indices.append(index)
                searchStartIndex = range.upperBound
            }

            return indices
        }
}


struct ArticleView_Previews: PreviewProvider {
    static var previews: some View {
        let example = """
[[>]]
[[module Rate]]
[[/>]]

[[module CSS]]
some css...
css that should not be visible...
[[/module]]

[[include :scp-wiki:component:anomaly-class-bar-source
|item-number=5004
|clearance=5
|container-class=esoteric
|secondary-class=thaumiel
|secondary-icon=http://scp-wiki.wikidot.com/local--files/component:anomaly-class-bar/thaumiel-icon.svg
|disruption-class=ekhi
|risk-class=notice
]]

[[include theme:black-highlighter-theme]]
[[include component:pride-highlighter inc-lgbt= --]]]
[[include info:start]]
**SCP-001: CODE NAME - Tufto:** The Scarlet King
**Author:** [[*user Tufto]]. This work was originally posted as part of the Doomsday Contest for Team "End-of-the-Contest Scenario". More of Tufto's work can be found [[[tufto-personnel-file|here]]].
[[include info:end]]

**Item #:** SCP-001

**Object Class:** --Keter-- Safe

------

**Description:** SCP-001 is an entity ordinarily referred to as the [[[scp-231|Scarlet King]]]. SCP-001 is currently located in several alternate dimensions simultaneously, and is unable to enter into the prime dimension. However, it is believed to have been repeatedly attempting entry for a period of --several thousand-- under 300 years. SCP-001's physical, mental and conceptual properties are unknown to the Foundation; nevertheless, it continues to assert a strong influence on a number of individuals and events within the prime dimension.
"""
        
        ArticleView(scp: Article(title: "Tufto's Proposal", pagesource: example, thumbnail: URL(string: "https://scp-wiki.wdfiles.com/local--files/scp-7606/SCPded.jpg")))
    }
}
