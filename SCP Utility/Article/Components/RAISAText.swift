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
    @State private var currentId: String?
    
    var body: some View {
        ScrollViewReader { value in
            ScrollView {
                VStack(alignment: .leading, spacing: 5) {
                    if !filtered {
                        ProgressView()
                    } else {
                        ForEach(Array(zip(itemList, itemList.indices)), id: \.1) { item, _ in
                            item.toCorrespondingView(article: article)
                        }
                        .onAppear {
                            if article.currenttext != nil {
                                withAnimation {
                                    value.scrollTo(article.currenttext!)
                                }
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
                // TODO: Dont call openurl on every instance of RT
                .onOpenURL { url in
                    // raisa://toc/(index)
                    guard url.scheme == "raisa" else { return }
                    
                    let components = url.absoluteString.components(separatedBy: "/")
                    guard components.count == 4 else { return }
                    guard components[2] == "toc" else { return }
                    
                    if let index = Int(components.last ?? "x") {
                        let header = matches(for: #"^\++\s.+$"#, in: article.pagesource, option: .anchorsMatchLines)[index]
                        withAnimation {
                            // need to filter
                            FilterToMarkdown(doc: header) { filtered in
                                value.scrollTo(filtered)
                            }
                        }
                    }
                }
            }
        }
    }
}

/// Parse text that has already been filtered.
func parseRT(_ text: String) -> [RTItem] {
    var source = text
    var items: [RTItem] = []
    let list = source.components(separatedBy: .newlines)
    
    let collapsibles = matches(for: #"\[\[(c|C)ollapsible.*?\]\]([\s\S]*?)\[\[\/(c|C)ollapsible\]\]"#, in: source)
    
    let regex = #"(\[\[include.*?(image-features-source|image-block)[\s\S]*?]]|\[\[.*?image.*?]])"#
    let imageStrings = matches(for: regex, in: source)
    let quickTables = matches(for: #"(\|\|[\s\S]+?\|\|(?:\n|$))+"#, in: source)
    let htmls = matches(for: #"\[\[html[\s\S]*?\[\[\/html]]"#, in: source)
    let audios = matches(for: #"\[\[include.+?html5player[\s\S]*?]]"#, in: source)
    let divTables = matches(for: #"\[\[table.*?]][\s\S]*?\[\[\/table]]"#, in: source)
    
    var collapsibleIndex = 0
    var imageIndex = 0
    var quickTableIndex = 0
    var htmlIndex = 0
    var audioIndex = 0
    var divTableIndex = 0
    
    var skipCount = 0
    
    for (item, index) in zip(list, list.indices) {
        if skipCount > 0 {
            skipCount -= 1
            continue
        }
        
        let itemAndNext: String = index + 3 < list.count - 1 ?
        item + "\n" + list[index + 1] + "\n" + list[index + 2] + "\n" + list[index + 3] : item
        
        // Find all occurances in collapsible tags
        func resolveIndices(content: String) {
            imageIndex += matches(for: #"(image-features-source|image-block|\[\[.*?image)"#, in: content).count
            quickTableIndex += matches(for: #"(\|\|[\s\S]+?\|\|(?:\n|$))+"#, in: content).count
            audioIndex += matches(for: #"\[\[include.+?html5player[\s\S]*?]]"#, in: content).count
        }
        
        if item.contains("anomaly-class") || item.contains("object-warning-box") {
            let slice = source.slice(with: item, and: "]]")
            items.append(.component(slice))
            source.removeText(from: item, to: "]]")
            skipCount += slice.components(separatedBy: .newlines).count - 1
            
        } else if item.contains("[[tabview") {
            let slice = source.slice(with: itemAndNext, and: "[[/tabview]]")
            items.append(.tabview(slice))
            source = source.replacingOccurrences(of: slice, with: "")
            skipCount += slice.components(separatedBy: .newlines).count - 1
            resolveIndices(content: slice)
            
        } else if item.lowercased().contains("[[collapsible") {
            guard collapsibles.indices.contains(collapsibleIndex) else { continue }
            let collapsible = collapsibles[collapsibleIndex]
            items.append(.collapsible(collapsible))
            skipCount += collapsible.components(separatedBy: .newlines).count - 1
            collapsibleIndex += 1
            resolveIndices(content: collapsible)
            
        } else if item.contains("[[table") {
            guard divTables.indices.contains(divTableIndex) else { continue }
            let table = divTables[divTableIndex]
            items.append(.table(table))
            skipCount += table.components(separatedBy: .newlines).count - 1
            divTableIndex += 1
            resolveIndices(content: table)
            
        } else if item.contains(":scp-wiki:component:image-features-source") || item.contains(":image-block") ||
            (item.contains("[[") && item.contains("image ")) {
            guard imageStrings.indices.contains(imageIndex) else { continue }
            items.append(.image(imageStrings[imageIndex]))
            skipCount += imageStrings[imageIndex].components(separatedBy: .newlines).count - 1
            imageIndex += 1
            
        } else if item.contains("||") {
            guard quickTables.indices.contains(quickTableIndex) else { continue }
            let tableItem: RTItem = .table(quickTables[quickTableIndex])
            items.append(tableItem)
            skipCount += quickTables[quickTableIndex].components(separatedBy: .newlines).count - 1
            quickTableIndex += 1
            
        } else if item.contains("[[html") {
            guard htmls.indices.contains(htmlIndex) else { continue }
            let html = htmls[htmlIndex]
            items.append(.html(html))
            skipCount += html.components(separatedBy: .newlines).count - 1
            htmlIndex += 1
            
        } else if item.contains("[[include :snippets:html5player") && audios.indices.contains(audioIndex) {
            let audio = audios[audioIndex]
            items.append(.audio(audio))
            skipCount += audio.components(separatedBy: .newlines).count - 1
            audioIndex += 1
            
        } else {
            items.append(.text(item))
        }
    }
    
    return items
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
            Regex(#"(<<|«)\s*?\[\[.*?\]\]\s*?(»|>>)"#),
            Regex(#"\[\[module[\s\S]*?\[\[\/module\]\]"#),
            Regex(#"\[\[a href=.*?\]\]"#),
            Regex(#"\[\[include.*license-box[\s\S]*?]][\s\S]*?\[\[include.*?license-box-end.*?]]"#),
            Regex(#"\[!--[\s\S]*?--\]"#),
            Regex(#"\[\[footnoteblock.*?\]\]"#),
            Regex(#"(\[\[code.*?\]\]|\[\[\/code\]\])"#),
            Regex(#"^\s*={3,}\s*$"#).anchorsMatchLineEndings(),
            Regex(#"^="#).anchorsMatchLineEndings(),
        ]
        
        for regex in regexDeletes {
            text = text.replacing(regex, with: "")
        }
        
        text.removeText(from: "[[include info:start", to: "include info:end]]")
        text.removeText(from: "[[include :scp-wiki:info:start", to: "info:end]]")
        
        // Blockquotes
        for match in matches(for: #"\[\[div class="blockquote".*?]][\s\S]*?\[\[\/div]]"#, in: text) {
            let newlist = match.components(separatedBy: .newlines).map { "> " + $0 }
            text = text.replacingOccurrences(of: match, with: newlist.joined(separator: "\n"))
        }
        
        text.removeText(from: "[[include component:info-ayers", to: "]]")
        text.removeText(from: "[[include :scp-wiki:component:info-ayers", to: "]]")
        text.removeText(from: "[[include :scp-wiki:component:author-label-source start=--", to: "[[include :scp-wiki:component:author-label-source end=--]]")
        
        // "--]" is used as a component parameter, and it doesnt match anything, so it causes problems
        text = text.replacingOccurrences(of: "--]", with: "")
        
        text = text.replacingOccurrences(of: "[*http", with: "[http")
        
        // Footnotes
        let fnmatches = matches(for: #"\[\[footnote]][\s\S]*?\[\[\/footnote]]"#, in: text)
        for (match, index) in zip(fnmatches, fnmatches.indices) {
            let mark = " [[" + String(localized: "FOOTNOTE_MARK\(index + 1)") + "]](raisa://footnote/\(index))"
            text = text.replacingOccurrences(of: match, with: mark)
        }
        
        // (^|[^|])(--[^-]+?--)(?!-) --> Unreliable regex but doesn't match markdown table syntax
        for match in matches(for: #"--[^\s].*[^\s]--"#, in: text) {
            text = text.replacingOccurrences(of: match, with: match.replacingOccurrences(of: "--", with: "~~"))
        }
        
        for match in matches(for: #"__[^\s].+?[^\s]__"#, in: text) {
            text = text.replacingOccurrences(of: match, with: match.replacingOccurrences(of: "__", with: ""))
        }
        
        for match in matches(for: #",,.*?,,"#, in: text) {
            text = text.replacingOccurrences(of: match, with: match.replacingOccurrences(of: ",,", with: ""))
        }
        
        for match in matches(for: #"(@| )+@"#, in: text) {
            text = text.replacingOccurrences(of: match, with: match.replacingOccurrences(of: "@", with: " "))
        }
        
        for match in matches(for: #"(^|[^:])(\/\/)"#, in: text) {
            text = text.replacingOccurrences(of: match, with: match.replacingOccurrences(of: "//", with: "*"))
        }
        
        // Superscript "^^2^^"
        for match in matches(for: #"\^\^.*\^\^"#, in: text) {
            text = text.replacingOccurrences(
                of: match, with: "^" + (match.slice(from: "^^", to: "^^") ?? match)
            )
        }
        
        // User tags
        for match in matches(for: #"\[\[\*?user.*?\]\]"#, in: text, option: .caseInsensitive) {
            text = text.replacingOccurrences(of: match, with: match
                .replacingOccurrences(of: "[[*user ", with: "", options: .caseInsensitive)
                .replacingOccurrences(of: "[[user ", with: "", options: .caseInsensitive)
                .replacingOccurrences(of: "]]", with: "")
            )
        }
        
        // Links that dont start with http (SCP-7579)
        for match in matches(for: #"\[\*?\/.*? .*?\]"#, in: text) {
            if let url = matches(for: #"\*?\/.*?(?= )"#, in: match).first?.replacing(/^\*/, with: ""), let content = matches(for: "(?<= ).*?]", in: match).first {
                // TODO: Fix for international branches
                text = text.replacingOccurrences(of: match, with: "[\(content)(https://scp-wiki.wikidot.com\(url))")
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
            "[[toc]]"
        ]
        for string in stringDeletes {
            text = text.replacingOccurrences(of: string, with: "")
        }
        
        text = try! text.replacing(Regex(#"^---+$"#).anchorsMatchLineEndings(), with: "---") // horizontal rule
        text = try! text.replacing(Regex(#"^# "#).anchorsMatchLineEndings(), with: "- ")
        text = try! text.replacing(Regex(#"^\++ "#).anchorsMatchLineEndings(), with: "## ") // header markings
        text = try! text.replacing(Regex(#"^\++\*"#).anchorsMatchLineEndings(), with: "##") // header markings escaped from toc
        text = try! text.replacing(Regex(#"^> \++ "#).anchorsMatchLineEndings(), with: "> ## ")
        text = try! text.replacing(Regex(#"^> \++\* "#).anchorsMatchLineEndings(), with: "> ## ") // header markings escaped from toc
        text = try! text.replacing(Regex(#"^> ="#).anchorsMatchLineEndings(), with: "> ")
        
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
    text.removeText(from: "[[include info:start", to: "include info:end]]")
    text.removeText(from: "[[include :scp-wiki:info:start", to: "info:end]]")
    text.removeText(from: "[[module Rate", to: "]]"); text.removeText(from: "[[module rate", to: "]]")
    
    // Blockquotes
    for match in matches(for: #"\[\[div class="blockquote".*?]][\s\S]*?\[\[\/div]]"#, in: text) {
        let newlist = match.components(separatedBy: .newlines).map { "> " + $0 }
        text = text.replacingOccurrences(of: match, with: newlist.joined(separator: "\n"))
    }
    
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
    
    // User tags
    for match in matches(for: #"\[\[\*?user.*?\]\]"#, in: text) {
        text = text.replacingOccurrences(of: match, with: match
            .replacingOccurrences(of: "[[*user ", with: "")
            .replacingOccurrences(of: "[[user ", with: "")
            .replacingOccurrences(of: "]]", with: "")
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
        "__",
        "[[/collapsible]]",
        "[[footnoteblock]]",
        "[[/a]]",
        "[[[",
        "]]]",
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
        Regex(#"\[\[a href=.*?\]\]"#),
        Regex(#"(\[\[code.*?\]\]|\[\[\/code\]\])"#),
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
