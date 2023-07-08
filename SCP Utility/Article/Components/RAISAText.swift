//
//  RAISAText.swift
//  SCP Utility
//
//  Created by Maximus Harding on 4/28/23.
//

import SwiftUI
import MarkdownUI

/// View that parses and displays an article's page source. RAISAText calls many other views that also call RAISAText.
/// If "text" is not nil, it will be parsed instead of the passed article's page source.
struct RAISAText: View {
    @State var article: Article
    @State var text: String? = nil
    
    @State private var filtered: Bool = false
    @State private var filteredText: String = ""
    @State private var itemList: [RTItem] = []
    @State private var actionToPerform: (() -> Void)? = nil
    @State private var currentId: String?

    init(article: Article) {
        self._article = State(initialValue: article)
    }
    
    init(article: Article, text: String) {
        self._article = State(initialValue: article)
        self._text = State(initialValue: text)
    }
    
    var body: some View {
        let defaults = UserDefaults.standard
        ScrollViewReader { value in
            ScrollView {
                VStack(alignment: .leading, spacing: 5) {
                    if !filtered {
                        ProgressView()
                    } else {
                        Group {
                            if #available(iOS 17, *) {
//                                ForEach(Array(zip(itemList, itemList.indices)), id: \.1) { item, _ in
//                                    item.toCorrespondingView(article: article)
//                                        .id(item)
//                                }
//                                .scrollPosition(id: $currentId)
//                                .onDisappear {
//                                    article.setScroll(currentId)
//                                }
//                                .onAppear {
//                                    withAnimation {
//                                        currentId = article.currenttext
//                                    }
//                                }
                            } else {
                                ForEach(Array(zip(itemList, itemList.indices)), id: \.1) { item, _ in
                                    item.toCorrespondingView(article: article)
                                }
                                .onAppear {
                                    if article.currenttext != nil && defaults.bool(forKey: "autoScroll") {
                                        value.scrollTo(article.currenttext!)
                                    }
                                }
                            }
                        }
                        .onAppear {
                            if actionToPerform != nil {
                                actionToPerform!()
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .task {
                    if !filtered {
                        FilterToMarkdown(doc: text ?? article.pagesource) { str in
                            filteredText = str
                            
                            if itemList.isEmpty {
                                itemList = parseRT(filteredText)
                            }
                            filtered = true
                        }
                    }
                }
            }
        }
    }
}

extension RAISAText {
    func onTextLoad(perform: (() -> Void)? = nil) -> RAISAText {
        actionToPerform = perform
        return self
    }
}

/// Parse text that has already been filtered.
func parseRT(_ text: String, stopRecursiveFunction stop: Bool? = nil) -> [RTItem] {
    var source = text
    var items: [RTItem] = []
    let list = source.components(separatedBy: .newlines)
    
    var forbiddenLines: [String] = []
    
    let collapsibles = findAllCollapsibles(source)
    let imageStrings = findAllImages(source)
    let quickTables = findAllQuickTables(source)
    let htmls = findAllHTML(source)
    let audios = findAllAudio(source)
    
    var collapsibleIndex = 0
    var imageIndex = 0
    var quickTableIndex = 0
    var htmlIndex = 0
    var audioIndex = 0
    
    for (item, index) in zip(list, list.indices) {
        let itemAndNext: String = index + 3 < list.count - 1 ?
        item + "\n" + list[index + 1] + "\n" + list[index + 2] + "\n" + list[index + 3] : item
        
//        let lastItem: String = index == 0 ? item : list[index - 1]
        
        // Check if the next items are also forbidden, because check of the one item would fail in cases where it isn't unique.
        guard !Set(itemAndNext.components(separatedBy: .newlines)).isSubset(of: Set(forbiddenLines)) else { continue }
        
        if item.contains("anomaly-class") || item.contains("object-warning-box") {
            let slice = source.slice(with: item, and: "]]")
            items.append(.component(slice))
            source.removeText(from: item, to: "]]")
            forbiddenLines += slice.components(separatedBy: .newlines)
            
        } else if item.contains("[[tabview") {
            let slice = source.slice(with: itemAndNext, and: "[[/tabview]]")
            items.append(.tabview(slice))
            source = source.replacingOccurrences(of: slice, with: "")
            forbiddenLines += slice.components(separatedBy: .newlines)
            
        } else if item.lowercased().contains("[[collapsible") && collapsibles.indices.contains(collapsibleIndex) {
            items.append(.collapsible(collapsibles[collapsibleIndex]))
            forbiddenLines += collapsibles[collapsibleIndex].components(separatedBy: .newlines)
            collapsibleIndex += 1
            
        } else if item.contains("[[table") {
            let slice = source.slice(with: itemAndNext, and: "[[/table]]")
            items.append(.table(slice))
            forbiddenLines += slice.components(separatedBy: .newlines)
            
        } else if item.contains(":scp-wiki:component:image-features-source") || item.contains(":image-block") ||
            (item.contains("[[") && item.contains("image ")) {
            guard imageStrings.indices.contains(imageIndex) else { continue }
            items.append(.image(imageStrings[imageIndex]))
            forbiddenLines += imageStrings[imageIndex].components(separatedBy: .newlines)
            imageIndex += 1
            
        } else if item.contains("||") {
            guard quickTables.indices.contains(quickTableIndex) else { continue }
            let tableItem: RTItem = .table(quickTables[quickTableIndex])
            guard !items.contains(tableItem) else { continue }
            items.append(tableItem)
            quickTableIndex += 1
            
        } else if item.contains("[[html") && htmls.indices.contains(htmlIndex) {
            let html = htmls[htmlIndex]
            items.append(.html(html))
            forbiddenLines += html.components(separatedBy: .newlines)
            htmlIndex += 1
            
        } else if item.contains("[[include :snippets:html5player") && audios.indices.contains(audioIndex) {
            let audio = audios[audioIndex]
            items.append(.audio(audio))
            forbiddenLines += audio.components(separatedBy: .newlines)
            audioIndex += 1
            
        } else if item.contains("[[[") {
            // terniary operator to fix crash when the closing tag is on a newline
            items.append(.inlinebuton(item.contains("]]]") ? item : source.slice(with: item, and: "]]]")))
        } else if item.contains("[") && item.contains("http") && !(stop ?? false) {
            items.append(.inlinebuton(item))
        } else if !forbiddenLines.contains(item) {
            items.append(.text(item))
        }
    }
    
    return items
}


/// Finds all tables that use the "||" syntax
func findAllQuickTables(_ source: String) -> [String] {
    return matches(for: #"(\|\|[\s\S]+?\|\|(?:\n|$))+"#, in: source)
}

/// Finds and returns all text inside of collapsible tags, including those tags.
func findAllCollapsibles(_ doc: String) -> [String] {
    return matches(for: #"\[\[(c|C)ollapsible.*?\]\]([\s\S]*?)\[\[\/(c|C)ollapsible\]\]"#, in: doc)
}

/// Finds and returns all text that displays an image.
func findAllImages(_ doc: String) -> [String] {
    let regex = #"(\[\[include[\s\S]*?(image-features-source|image-block)[\s\S]*?]]|\[\[.*?image.*?]])"#
    return matches(for: regex, in: doc)
}

func parseBlockQuoteDivs(_ doc: String) -> String {
    var returnDoc = doc
    for match in matches(for: #"\[\[div class="blockquote".*?]][\s\S]*?\[\[\/div]]"#, in: doc) {
        var newlist: [String] = []
        let list = match.components(separatedBy: .newlines)
        for item in list {
            newlist.append("> " + item)
        }
        
        returnDoc = returnDoc.replacingOccurrences(of: match, with: newlist.joined(separator: "\n"))
    }
    return returnDoc
}

func findAllHTML(_ doc: String) -> [String] {
    return matches(for: #"\[\[html[\s\S]*?\[\[\/html]]"#, in: doc)
}

func findAllAudio(_ doc: String) -> [String] {
    return matches(for: #"\[\[include.+?html5player[\s\S]*?]]"#, in: doc)
}

// MARK: Normal Filter
func FilterToMarkdown(doc: String, completion: @escaping (String) -> Void) {
    DispatchQueue.main.async {
        var text = doc
        
        // Basic Divs
        let regexDeletes: [Regex] = try! [
            Regex(#"(\[\[div.*?\]\]|\[\[\/div\]\])"#),
            Regex(#"(\[\[span.*?\]\]|\[\[\/span\]\])"#),
            Regex(#"\[\[module rate\]\]"#).ignoresCase(),
            Regex(#"\[\[# .*?\]\]"#),
            Regex(#"\[#toc.*?\]"#),
            Regex(#"<< \[\[\[.*?\]\]\] >>"#),
            Regex(#"\[\[module[\s\S]*?\[\[\/module\]\]"#),
            Regex(#"\[\[a href=.*?\]\]"#),
            Regex(#"\[\[include.*license-box[\s\S]*?]][\s\S]*?\[\[include.*?license-box-end.*?]]"#),
            Regex(#"\[!--[\s\S]*?--\]"#),
            Regex(#"\[\[\*?user.*?\]\]"#),
        ]
        
        for regex in regexDeletes {
            text = text.replacing(regex, with: "")
        }
        
        text.removeText(from: "[[include info:start", to: "include info:end]]")
        text.removeText(from: "[[include :scp-wiki:info:start", to: "info:end]]")
        text = parseBlockQuoteDivs(text)
        
        text.removeText(from: "[[include component:info-ayers", to: "]]")
        text.removeText(from: "[[include :scp-wiki:component:info-ayers", to: "]]")
        text.removeText(from: "[[include :scp-wiki:component:author-label-source start=--", to: "[[include :scp-wiki:component:author-label-source end=--]]")
        
        // "--]" is used as a component parameter, and it doesnt match anything, so it causes problems
        text = text.replacingOccurrences(of: "--]", with: "")
        
        // Footnotes
        let fnmatches = matches(for: #"\[\[footnote]][\s\S]*?\[\[\/footnote]]"#, in: text)
        for (match, index) in zip(fnmatches, fnmatches.indices) {
            text = text.replacingOccurrences(of: match, with: " [fn.\(index + 1)]")
        }
        
        for match in matches(for: #"--[^\s].+[^\s]--"#, in: text) {
            text = text.replacingOccurrences(of: match, with: match.replacingOccurrences(of: "--", with: "~~"))
        }
        
        for match in matches(for: #",,.*?,,"#, in: text) {
            text = text.replacingOccurrences(of: match, with: match.replacingOccurrences(of: ",,", with: ""))
        }
        
        for match in matches(for: #"(@| )+@"#, in: text) {
            text = text.replacingOccurrences(of: match, with: match.replacingOccurrences(of: "@", with: " "))
        }
        
        for match in matches(for: #"\/\/.*\/\/"#, in: text) {
            text = text.replacingOccurrences(of: match, with: match.replacingOccurrences(of: "//", with: "*"))
        }
        
        // Superscript "^^2^^"
        for match in matches(for: #"\^\^.*\^\^"#, in: text) {
            text = text.replacingOccurrences(
                of: match, with: "^" + (match.slice(from: "^^", to: "^^") ?? match)
            )
        }
        
        // Links that dont start with http (SCP-7579)
        for match in matches(for: #"\[\*\/.*? .*?\]"#, in: text) {
            if let url = matches(for: #"(?<=\*\/).*?(?= )"#, in: match).first {
                // TODO: Fix for international branches
                text = text.replacingOccurrences(of: match, with:
                                                    match.replacingOccurrences(of: "*/\(url)", with: "https://scp-wiki.wikidot.com/\(url)")
                )
            }
        }
        
        // Monospace
        // It wont parse links or bold text so this needs to happen
        for match in matches(for: #"\{\{.*?\}\}"#, in: text) {
            if try! match.contains("**") || match.contains("[[[") || match.contains("~~") || match.contains("*") || match.contains(Regex(#"\[.*?http"#)) {
                text = text.replacingOccurrences(of: match, with: match.slice(from: "{{", to: "}}") ?? match)
            } else {
                text = text.replacingOccurrences(of: match, with:
                                                    match
                    .replacingOccurrences(of: "{{", with: "``")
                    .replacingOccurrences(of: "}}", with: "``")
                )
            }
        }
        
        let stringDeletes: [String] = [
            "[[>]]",
            "[[/>]]",
            "[[<]]",
            "[[/<]]",
            "[[=]]",
            "[[/=]]",
            "[[==]]",
            "[[/==]]",
            "[[/a]]",
            "[[footnoteblock]]",
        ]
        for string in stringDeletes {
            text = text.replacingOccurrences(of: string, with: "")
        }
        
        text = try! text.replacing(Regex(#"\n---+$"#), with: "\n---") // horizontal rule
        text = try! text.replacing(Regex(#"\n===$"#), with: "\n---$")
        text = try! text.replacing(Regex(#"\n\++ "#), with: "\n## ") // header markings
        text = try! text.replacing(Regex(#"\++\*"#), with: "##") // header markings escaped from toc
        text = try! text.replacing(Regex(#"\n="#), with: "\n")
        text = try! text.replacing(Regex(#"\n> ="#), with: "\n> ")
        text = try! text.replacing(Regex(#"\n# "#), with: "\n- ")
        
        let supportedIncludes: [String] = [
            "image-features-source",
            "image-block",
            "anomaly-class",
            "object-warning-box",
            "snippets:html5player",
        ]
        
        let regex = try! Regex(#"\[\[include(?!.*("# + supportedIncludes.joined(separator: "|") + #"))[^\]]*\]\](?![^\[]*\])"#)
        text = text.replacing(regex, with: "")
        
        text = text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        completion(text)
    }
}

// MARK: Pure Filter
func FilterToPure(doc: String) -> String {
    var text = doc
    
    // Basic Divs
    if let firstLicense = matches(for: #"\[\[include.*license-box.*?]]"#, in: text).first,
       let lastLicense = matches(for: #"\[\[include.*?license-box-end.*?]]"#, in: text).first {
        text.removeText(from: firstLicense, to: lastLicense)
    }
    text = try! text.replacing(Regex(#"\[!--[\s\S]*?--]"#), with: "")
    for _ in text.indicesOf(string: "[[*user") { text.removeText(from: "[[*user", to: "]]") }
    text.removeText(from: "[[include info:start", to: "include info:end]]")
    text.removeText(from: "[[include :scp-wiki:info:start", to: "info:end]]")
    text.removeText(from: "[[module Rate", to: "]]"); text.removeText(from: "[[module rate", to: "]]")
    text = parseBlockQuoteDivs(text)
    for _ in text.indicesOf(string: "[[div") {
        text.removeText(from: "[[div", to: "]]")
        text.removeText(from: "[[/div", to: "]]")
    }
    for _ in text.indicesOf(string: "[[span") {
        text.removeText(from: "[[span", to: "]]")
        text.removeText(from: "[[/span", to: "]]")
    }
    for _ in text.indicesOf(string: "[[size") {
        text.removeText(from: "[[size", to: "]]")
        text.removeText(from: "[[/size", to: "]]")
    }
    
    // Table of Contents markings
    for _ in text.indicesOf(string: "[[#") {
        text.removeText(from: "[[#", to: "]]")
    }
    for _ in text.indicesOf(string: "[#toc") {
        text.removeText(from: "[#toc", to: "]")
    }
    
    text.removeText(from: "[[include component:info-ayers", to: "]]")
    text.removeText(from: "[[include :scp-wiki:component:info-ayers", to: "]]")
    text.removeText(from: "[[include :scp-wiki:component:author-label-source start=--", to: "[[include :scp-wiki:component:author-label-source end=--]]")
    
    // "--]" is used as a component parameter, and it doesnt match anything, so it causes problems
    text = text.replacingOccurrences(of: "--]", with: "")
    text.removeText(from: "[[>", to: "]]")
    text.removeText(from: "[[/>", to: "]]")
    text.removeText(from: "[[<", to: "]]")
    text.removeText(from: "[[/<", to: "]]")
    text.removeText(from: "[[=", to: "]]")
    text.removeText(from: "[[/=", to: "]]")
    text.removeText(from: "[[==", to: "]]")
    text.removeText(from: "[[/==", to: "]]")
    text.removeText(from: "<< [[[", to: "]]] >>")
    for _ in text.indicesOf(string: "[[module") { text.removeText(from: "[[module", to: "[[/module]]") }
    
    // Footnotes
    for _ in text.indicesOf(string: "[[footnote") {
        text = text.replacingOccurrences(of: "[[footnote]]", with: " (")
        text = text.replacingOccurrences(of: "[[/footnote]]", with: ")")
    }
    
    for match in matches(for: #"--[^\s].+[^\s]--"#, in: text) {
        text = text.replacingOccurrences(of: match, with: match.replacingOccurrences(of: "--", with: ""))
    }
    
    text = text.replacingOccurrences(of: "@@ @@", with: "     ")
    for match in matches(for: "@@.*@@", in: text) {
        text = text.replacingOccurrences(of: match, with: match.replacingOccurrences(of: "@@", with: ""))
    }
    
    // Superscript "^^2^^"
    for match in matches(for: #"\^\^.*\^\^"#, in: text) {
        text = text.replacingOccurrences(
            of: match, with: "^" + (match.slice(from: "^^", to: "^^") ?? match)
        )
    }
    
    // Color
    for match in matches(for: #"##[^|]*\|(.*?)##"#, in: text) {
        text = text.replacingOccurrences(of: match, with: match.slice(from: "|", to: "##") ?? match)
    }
    
    for match in matches(for: #"\[.*?http.*? (.*?)]"#, in: text) {
        text = text.replacingOccurrences(of: match, with: match.slice(from: " ", to: "]") ?? "")
    }
    
    let stringDeletes: [String] = [
        "@@@@",
        "{{",
        "}}",
        "``",
        "//",
        "***",
        "**",
        "--",
        ",,",
        "[[/collapsible]]",
        "[[footnoteblock]]",
        "[[/a]]"
    ]
    
    for string in stringDeletes {
        text = text.replacingOccurrences(of: string, with: "")
    }
    
    let regexDeletes: [Regex] = try! [
        Regex(#"^---+$"#), // horizontal rule
        Regex("^===$"),
        Regex(#"\n\++ "#), // header markings
        Regex(#"\++\*"#), // header markings escaped from toc
        Regex(#"\n="#),
        Regex(#"\[\[collapsible.+?]]"#),
        Regex(#"^> "#),
        Regex(#"^\* "#), // bullets
        Regex(#"\[\[.*?image.*?]]"#),
        Regex(#"\[\[include[^\]]*\]\](?![^\[]*\])"#), // all componenets
        Regex(#"\[\[a href=.*?\]\]"#)
    ]
    
    for regex in regexDeletes {
        text = text.replacing(regex, with: "")
    }
    
    text = text.trimmingCharacters(in: .whitespacesAndNewlines)
    
    return text
}

struct RAISAText_Previews: PreviewProvider {
    static var previews: some View {
        RAISAText(article: placeHolderArticle)
    }
}
