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
    @State var openOnLoad: Bool = false
    
    @State private var filtered: Bool = false
    @State private var filteredText: String = ""
        
    init(article: Article) {
        self._article = State(initialValue: article)
    }
    
    init(article scp: Article, openOnLoad: Bool?) {
        self._article = State(initialValue: scp)
        self._openOnLoad = State(initialValue: openOnLoad ?? false)
    }
    
    init(article: Article, text: String) {
        self._article = State(initialValue: article)
        self._text = State(initialValue: text)
    }
    
    init(article: Article, parsedText: String) {
        self._article = State(initialValue: article)
        self._filtered = State(initialValue: true)
        self._filteredText = State(initialValue: parsedText)
    }
    
    var body: some View {
        let defaults = UserDefaults.standard
        ScrollViewReader { value in
            ScrollView {
                VStack(alignment: .leading, spacing: 5) {
                    if !filtered {
                        ProgressView()
                            .onAppear {
                                FilterToMarkdown(doc: text ?? article.pagesource) { str in
                                    filteredText = str
                                    filtered = true
                                }
                            }
                    }
                    
                    if filtered {
                        let list = parseRT(filteredText, openOnLoad: openOnLoad)
                        ForEach(Array(zip(list, list.indices)), id: \.1) { item, _ in
                            item.toCorrespondingView(article: article)
                        }
                        .onAppear {
                            if article.currenttext != nil && defaults.bool(forKey: "autoScroll") && filtered {
                                value.scrollTo(article.currenttext!)
                            }
                        }
                    }
                }
            }
        }
    }
}

/// Parse text that has already been filtered.
func parseRT(_ text: String, openOnLoad: Bool? = nil, stopRecursiveFunction stop: Bool? = nil) -> [RTItem] {
    var source = text
    var items: [RTItem] = []
    let list = source.components(separatedBy: .newlines)
    
    var forbiddenLines: [String] = []
    
    let collapsibles = findAllCollapsibles(source)
    let imageStrings = findAllImages(source)

    let quickTables = findAllQuickTables(source)
    
    var collapsibleIndex = 0
    var imageIndex = 0
    var quickTableIndex = 0
    
    for (item, index) in zip(list, list.indices) {
        let itemAndNext: String = index + 3 < list.count - 1 ?
        item + "\n" + list[index + 1] + "\n" + list[index + 2] + "\n" + list[index + 3] : item
        
        let lastItem: String = index == 0 ? item : list[index - 1]
        
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
            
        } else if item.lowercased().contains("[[collapsible") {
            items.append(.collapsible(collapsibles[collapsibleIndex], openOnLoad: openOnLoad ?? false))
            forbiddenLines += collapsibles[collapsibleIndex].components(separatedBy: .newlines)
            collapsibleIndex += 1
            
        } else if item.contains("[[table") {
            let slice = source.slice(with: itemAndNext, and: "[[/table]]")
            items.append(.table(slice))
            forbiddenLines += slice.components(separatedBy: .newlines)
            
        } else if item.contains(":scp-wiki:component:image-features-source") || item.contains(":image-block") ||
            (item.contains("[[") && item.contains("image ")) {
            items.append(.image(imageStrings[imageIndex]))
            forbiddenLines += imageStrings[imageIndex].components(separatedBy: .newlines)
            imageIndex += 1
            
        } else if item.contains("||") && quickTableIndex < quickTables.count {
            for firstline in quickTables.map({ $0.components(separatedBy: .newlines).first ?? "" }) {
                let table = quickTables[quickTableIndex]

                if firstline == item && !table.contains(lastItem) {
                    items.append(.table(table))
                    forbiddenLines += table.components(separatedBy: .newlines)
                    quickTableIndex += 1
                }
            }
            
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
    var tables: [String] = []
    let list = source.components(separatedBy: .newlines)
    for item in list {
        if item.contains("||~") {
            let pipeCount: Int = Array(item).filter { $0 == "|" }.count
            
             // ((\|\|.*?){3}(\|\|)(\n|$))+
            let regex = #"((\|\|.*?){"# + String((pipeCount - 2) / 2) + #"}(\|\|)(\n|$))+"#
            for match in matches(for: regex, in: source) {
                tables.append(match.trimmingCharacters(in: .newlines))
            }
        }
    }
    
    return tables
}

/// Finds and returns all text inside of collapsible tags, including those tags.
func findAllCollapsibles(_ doc: String) -> [String] {
    var returnArray: [String] = []
    let regex = #"\[\[(c|C)ollapsible.*?\]\]([\s\S]*?)\[\[\/(c|C)ollapsible\]\]"#
    for match in matches(for: regex, in: doc) {
//        if !match.contains("[[collapsible") {
            returnArray.append(match)
//        }
    }
    
//    returnArray = returnArray.map { $0.replacingOccurrences(of: "[[/collapsible]]", with: "") }
    return returnArray
}

/// Finds and returns all text that displays an image.
func findAllImages(_ doc: String) -> [String] {
    var returnArray: [String] = []
    var source = doc
    
    let list = source.components(separatedBy: .newlines)
    for (item, index) in zip(list, list.indices) {
        if item.contains(":scp-wiki:component:image-features-source") {
            let itemAndNext = item + "\n" + list[index + 1]
            let slice = source.slice(with: itemAndNext, and: "]]")
            returnArray.append(slice)
            source = source.replacingOccurrences(of: slice, with: "")
        } else if item.contains(":image-block") {
            let itemAndNext = item + "\n" + list[index + 1]
            let slice = item.contains("]]") ? item : (itemAndNext.contains("]]") ? itemAndNext: source.slice(with: itemAndNext, and: "]]"))
            returnArray.append(slice)
            source = source.replacingOccurrences(of: slice, with: "")
        } else if item.contains("[[") && item.contains("image ") {
            returnArray.append(item)
            source = source.replacingOccurrences(of: item, with: "")
        }
    }
    
    return returnArray
}

func FilterToMarkdown(doc: String, completion: @escaping (String) -> Void) {
    DispatchQueue.main.async {
        var text = doc
        
        // Basic Divs
        text = try! text.replacing(Regex(#"\[!--[\s\S]*?--]"#), with: "")
        for _ in text.indicesOf(string: "[[*user") { text.removeText(from: "[[*user", to: "]]") }
        text = try! text.replacing(Regex(#"\[\[include.*license-box]][\s\S]*?license-box-end.*?]]"#), with: "")
        text.removeText(from: "[[include info:start", to: "include info:end]]")
        text.removeText(from: "[[include :scp-wiki:info:start", to: "info:end]]")
        text.removeText(from: "[[module Rate", to: "]]"); text.removeText(from: "[[module rate", to: "]]")
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
        for _ in text.indicesOf(string: ",,[#toc") {
            text.removeText(from: ",,[#toc", to: "],,")
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
        
        for match in matches(for: #"--[^\s].*[^\s]--"#, in: text) {
            text = text.replacingOccurrences(of: match, with: match.replacingOccurrences(of: "--", with: "~~"))
        }
        for match in matches(for: #"\/\/.*\/\/"#, in: text) {
            text = text.replacingOccurrences(of: match, with: match.replacingOccurrences(of: "//", with: "*"))
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
        
        text = text.replacingOccurrences(of: "@@@@", with: "\n")
        text = text.replacingOccurrences(of: "{{", with: "")
        text = text.replacingOccurrences(of: "}}", with: "")
        text = try! text.replacing(Regex("---+\n"), with: "---\n") // horizontal rule
        text = try! text.replacing(Regex("===+\n"), with: "---\n")
        text = try! text.replacing(Regex(#"\n\++ "#), with: "\n## ") // header markings
        text = try! text.replacing(Regex(#"\++\*"#), with: "##") // header markings escaped from toc
        text = try! text.replacing(Regex(#"\n="#), with: "\n")
        text = text.replacingOccurrences(of: "[[footnoteblock]]", with: "")
        
        let supportedIncludes: [String] = [
            "image-features-source",
            "image-block",
            "anomaly-class",
            "object-warning-box",
        ]
        
        let regex = try! Regex("\\[\\[include(?!.*(\(supportedIncludes.joined(separator: "|"))))[^\\]]*\\]\\](?![^\\[]*\\])")
        text = text.replacing(regex, with: "")
        
        text = text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        completion(text)
    }
}

struct RAISAText_Previews: PreviewProvider {
    static var previews: some View {
        RAISAText(article: placeHolderArticle)
    }
}
