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
    @State private var showInfo: Bool = false
    @State private var resume: Bool = false
    @State private var tooltip: Bool = false
    @State private var filtered: String = ""
    @State private var bookmarkStatus: Bool = false
    @Environment(\.dismiss) var dismiss
    
    let defaults = UserDefaults.standard
    let con = PersistenceController.shared
    var body: some View {
        let document = scp.pagesource
        
        let mode: Int = defaults.integer(forKey: "articleViewSetting")
        #if os(iOS)
        let _ = PersistenceController.shared.createHistory(from: History(title: scp.title, thumbnail: scp.thumbnail))
        #endif
        ScrollViewReader { value in
            ScrollView {
                #if os(iOS)
                if scp.thumbnail != nil && defaults.bool(forKey: "showImages") && mode != 2 {
                    KFImage(scp.thumbnail)
                        .resizable()
                        .scaledToFit()
                    
                }
                #endif
                if filtered == "" { ProgressView() }
                
                VStack(alignment: .leading) {
                    var forbiddenLines: String = ""
                    if mode == 0 && filtered == "" {
                        let _ = FilterToMarkdown(doc: document) { str in
                            filtered = str
                        }
                    }
                    if !(filtered == "") && mode == 0 { // Default
                        let list = filtered.components(separatedBy: .newlines)
                        ForEach(list, id: \.self) { item in
                            // Collapsible
                            if item.contains("[[collapsible") {
                                let sliced = item + (
                                    filtered.slice(
                                    from: item,
                                    to: "[[/collapsible]]"
                                    ) ?? "collapsible incorrect syntax") + "[[/collapsible]]"
                                
                                Collapsible(
                                    articleID: scp.id,
                                    text: sliced
                                )

                                let _ = forbiddenLines += sliced
                            }
                            
                            // Image
                            #if os(iOS)
                            if item.contains(":scp-wiki:component:image-features-source") {
                                ArticleImage(articleURL: scp.url, content: item)
                                let _ = filtered = filtered.replacingOccurrences(of: item, with: "")
                                let _ = forbiddenLines += item
                            } else if item.contains(":image-block") {
                                ArticleImage(articleURL: scp.url, content: filtered.slice(with: item, and: "]]")
                                )
                                let _ = filtered = filtered.replacingOccurrences(of: item, with: "")
                                let _ = forbiddenLines += item
                            }
                            #endif
                            
                            // Table
                            if item.contains("[[table") {
                                let tableSlice = filtered.slice(with: "[[table", and: "[[/table]]")
                                let _ = print(tableSlice)
                                ArticleTable(doc: tableSlice)
                                let _ = filtered = filtered.replacingOccurrences(of: tableSlice, with: "")
                            }
                        
                            // Text
                            if !forbiddenLines.contains(item) {
                                #if os(iOS)
                                Markdown(item)
                                    .padding(.bottom, 1)
                                    .id(item)
                                    .onTapGesture {
                                        tooltip = true
                                        con.setScroll(text: item, articleid: scp.id)
                                    }
                                #else
                                Text(item)
                                    .padding(.bottom, 1)
                                    .id(item)
                                    .onTapGesture {
                                        tooltip = true
                                        con.setScroll(text: item, articleid: scp.id)
                                    }
                                #endif
                            }
                        }
                    } else if mode == 1 { // Raw
                        let list = document.components(separatedBy: .newlines)
                        ForEach(list, id: \.self) { item in
                            Text(item)
                                .padding(.bottom, 1)
                                .id(item)
                                .onTapGesture {
                                    tooltip = true
                                    con.setScroll(text: item, articleid: scp.id)
                                }
                        }
                    } else if mode == 2 { // Safari
                        Text("LOADING_SAFARI")
                        let _ = showSafari = true
                    }
                    
                    if scp.currenttext != nil {
                        let _ = resume = true
                    }
                }
                .navigationTitle(scp.title)
            }
            .alert("RESUME_READING", isPresented: $resume) {
                Button("YES") {
                    value.scrollTo(scp.currenttext!)
                    resume = false
                }
                Button("NO", role: .cancel) {
                    resume = false
                }
            } message: {
                if scp.currenttext != nil {
                    Text(scp.currenttext!)
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
        .frame(width: 400)
        .sheet(isPresented: $presentSheet) {
            ListAdd(isPresented: $presentSheet, article: scp)
        }
        #if os(iOS)
        .sheet(isPresented: $showInfo) {
            ArticleInfoView(url: scp.url)
        }
        .fullScreenCover(isPresented: $showSafari) {
            SFSafariViewWrapper(url: scp.url)
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.backward")
                }
            }
            ToolbarItem {
                Button {
                    con.complete(status: !(scp.completed ?? false), article: scp)
                    scp.completed = !(scp.completed ?? false)
                } label: {
                    if scp.completed == true {
                        Image(systemName: "checkmark")
                    } else {
                        Image(systemName: "checkmark")
                            .foregroundColor(.secondary)
                            .opacity(0.5)
                    }
                }
            }
            // Bottom
            ToolbarItemGroup(placement: .bottomBar) {
                Button {} label: {
                    if scp.isSaved() || bookmarkStatus == true {
                        Image(systemName: "bookmark.fill")
                            .onTapGesture { presentSheet.toggle() }
                            .onLongPressGesture { presentSheet.toggle() }
                    } else {
                        Image(systemName: "bookmark")
                            .onTapGesture {
                                con.createArticleEntity(article: scp)
                                bookmarkStatus = true
                            }
                            .onLongPressGesture { presentSheet.toggle() }
                    }
                }
                
                Spacer()
                Button {
                    showInfo.toggle()
                } label: {
                    Image(systemName: "info.circle")
                }
                Spacer()
                
                Menu {
                    Button {
                        
                    } label: {
                        Label("DOWNVOTE", systemImage: "arrow.down")
                    }
                    
                    Button {
                        
                    } label: {
                        Label("UPVOTE", systemImage: "arrow.up")
                    }
                } label: {
                    Image(systemName: "arrow.up.arrow.down")
                }
                
                Spacer()
                Button {
                    showSafari.toggle()
                } label: {
                    Image(systemName: "safari")
                }
            }
        }
        #endif
    }
}

func FilterToMarkdown(doc: String, completion: @escaping (String) -> Void) {
    DispatchQueue.main.async {
        var text = doc
        
        // Basic Divs
        text.removeText(from: "[[include :scp-wiki:component:info-ayers", to: "]]")
        text.removeText(from: "[[include :scp-wiki:component:anomaly-class-bar-source", to: "]]")
        text.removeText(from: "[[include :scp-wiki:component:license-box", to: "license-box-end]]")
        text.removeText(from: "[[module Rate", to: "]]")
        text.removeText(from: "[[div", to: "]]")
        text.removeText(from: "[[/div", to: "]]")
        text.removeText(from: "[[size", to: "]]")
        text.removeText(from: "[[/size", to: "]]")
        text.removeText(from: "[[>", to: "]]")
        text.removeText(from: "[[/>", to: "]]")
        text.removeText(from: "[[=", to: "]]")
        text.removeText(from: "[[/=", to: "]]")
        text.removeText(from: "[!--", to: "--]")
        
        for _ in text.indicesOf(string: "[[module") {
            text.removeText(from: "[[module", to: "[[/module]]")
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
                } else {
                    text = text.replacingOccurrences(of: "[[[" + slicedElement + "]]]", with: slicedElement)
                }
            }
        }
        
        text = text.replacingOccurrences(of: "------", with: "---")
        text = text.replacingOccurrences(of: "@@@@", with: "\n")
        text = text.replacingOccurrences(of: "@@ @@", with: "\n")
        text = text.replacingOccurrences(of: "//", with: "*")
        text = text.replacingOccurrences(of: " --", with: " ~~")
        text = text.replacingOccurrences(of: "-- ", with: "~~ ")
        text = text.replacingOccurrences(of: "[[footnoteblock]]", with: "")
        text = text.replacingOccurrences(of: "++++++ ", with: "###### ")
        text = text.replacingOccurrences(of: "+++++ ", with: "##### ")
        text = text.replacingOccurrences(of: "++++ ", with: "#### ")
        text = text.replacingOccurrences(of: "+++ ", with: "### ")
        text = text.replacingOccurrences(of: "++ ", with: "## ")
        
        completion(text)
    }
}

// MARK: - Extensions
// https://stackoverflow.com/a/31727051
extension String {
    /// Slices from "from" string to first occurance of "to" string.
    func slice(from: String, to: String) -> String? {
        return (range(of: from)?.upperBound).flatMap { substringFrom in
            (range(of: to, range: substringFrom..<endIndex)?.lowerBound).map { substringTo in
                String(self[substringFrom..<substringTo])
            }
        }
    }
    
    /// Slices from "from" string to end of string.
    func slice(from: String) -> String? {
        return (range(of: from)?.upperBound).flatMap { substringFrom in
            String(self[substringFrom..<endIndex])
        }
    }
    
    /// Slices from "with" string to first occurance of "and" string and returns sliced text including the strings.
    func slice(with from: String, and to: String) -> String {
        return from + ((range(of: from)?.upperBound).flatMap { substringFrom in
            (range(of: to, range: substringFrom..<endIndex)?.lowerBound).map { substringTo in
                String(self[substringFrom..<substringTo])
            }
        } ?? "") + to
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

[[collapsible show="+ Open" hide="- Close"]]
This text is in a collapsible.
------
2
------
3
------
4
[[/collapsible]]

[[include component:image-block name=hughes.jpg|align=right|width=35%|caption=United States Supreme Court Justice Charles Evans Hughes.]]

[[collapsible show="+ Open2" hide="- Close2"]]
This text is also in a collapsible.
@@ @@
@@ @@
@@ @@
Hello
[[/collapsible]]

[[table style="width: 100%;"]]
[[row]]
[[cell style="border-bottom: 1px solid #AAA; border-right: 1px solid #AAA; text-align: center; width: 25%;"]]
[[size 90%]]**Assigned Site**[[/size]
[[/cell]]
[[cell style="border-bottom: 1px solid #AAA; border-right: 1px solid #AAA; text-align: center; width: 25%;"]]
[[size 90%]]**Site Director**[[/size]]
[[/cell]]
[[cell style="border-bottom: 1px solid #AAA; border-right: 1px solid #AAA; text-align: center; width: 25%;"]]
[[size 90%]]**Research Head**[[/size]]
[[/cell]]
[[cell style="border-bottom: 1px solid #AAA; text-align: center; width: 25%;"]]
[[size 90%]]**Assigned Task Force**[[/size]]
[[/cell]]
[[/row]]
[[row]]
[[cell style="border-right: 1px solid #AAA; text-align: center; width: 25%;"]]
[[size 80%]]USMILA Site-19[[/size]]
[[/cell]]
[[cell style="border-right: 1px solid #AAA; text-align: center; width: 25%;"]]
[[size 80%]]Tilda Moose[[/size]]
[[/cell]]
[[cell style="border-right: 1px solid #AAA; text-align: center; width: 25%;"]]
[[size 80%]]Everett Mann, M.D.[[/size]]
[[/cell]]
[[cell style="text-align: center; width: 25%;"]]
[[size 80%]]MTF A-14 "Dishwashers"[[/size]]
[[/cell]]
[[/row]]
[[/table]]
end
"""
        NavigationStack {
            ArticleView(scp: Article(
                title: "Tufto's Proposal",
                pagesource: example,
                url: placeholderURL,
                thumbnail: URL(string: "https://scp-wiki.wdfiles.com/local--files/scp-7606/SCPded.jpg")
            ))
        }
    }
}
