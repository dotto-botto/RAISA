//
//  RAISAText.swift
//  SCP Utility
//
//  Created by Maximus Harding on 4/28/23.
//

import SwiftUI
#if os(iOS)
import MarkdownUI
#endif

struct RAISAText: View {
    @State var article: Article
    @State var text: String? = nil
    
    @State private var filtered: Bool = false
    @State private var filteredText = ""
    var body: some View {
        let defaults = UserDefaults.standard
        let mode = defaults.integer(forKey: "articleViewSetting")
        ScrollViewReader { value in
            ScrollView {
                VStack(alignment: .leading, spacing: 5) {
                    if mode == 0 && !filtered {
                        ProgressView()
                            .onAppear {
                                FilterToMarkdown(doc: text ?? article.pagesource) { str in
                                    filteredText = str
                                    filtered = true
                                }
                            }
                    }
                    
                    if filtered && mode == 0 { // Default
                        var forbiddenLines: [String] = []
                        let list = filteredText.components(separatedBy: .newlines)
                        ForEach(list, id: \.self) { item in
                            // Tab View
                            if item.contains("[[tabview") {
                                let sliced = filteredText.slice(with: item, and: "[[/tabview]]")
                                TabViewComponent(
                                    article: article,
                                    text: sliced
                                )
                                let _ = filteredText = filteredText.replacingOccurrences(of: sliced, with: "")
                                let _ = forbiddenLines += sliced.components(separatedBy: .newlines)
                            }
                            
                            // Collapsible
                            if item.contains("[[collapsible") {
                                let sliced = filteredText.slice(with: item, and: "[[/collapsible]]")
                                
                                Collapsible(
                                    article: article,
                                    text: sliced
                                )
                                let _ = filteredText = filteredText.replacingOccurrences(of: sliced, with: "")
                                let _ = forbiddenLines += sliced.components(separatedBy: .newlines)
                            }
                            
                            // Image
                            #if os(iOS)
                            if item.contains(":scp-wiki:component:image-features-source") {
                                let slice = filteredText.slice(with: item, and: "]]")
                                ArticleImage(
                                    articleURL: article.url,
                                    content: slice
                                )
                                let _ = filteredText = filteredText.replacingOccurrences(of: slice, with: "")
                                let _ = forbiddenLines += slice.components(separatedBy: .newlines)
                            } else if item.contains(":image-block") {
                                var slice = ""
                                if item.contains("]]") { let _ = slice = item }
                                else { let _ = slice = filteredText.slice(with: item, and: "]]") }
                                ArticleImage(
                                    articleURL: article.url,
                                    content: slice
                                )
                                let _ = filteredText = filteredText.replacingOccurrences(of: slice, with: "")
                                let _ = forbiddenLines += slice.components(separatedBy: .newlines)
                            } else if item.contains("[[image") ||
                                        item.contains("[[>image") ||
                                        item.contains("[[<image") ||
                                        item.contains("[[=image") {
                                ArticleImage(articleURL: article.url, content: item)
                                let _ = filteredText = filteredText.replacingOccurrences(of: item, with: "")
                                let _ = forbiddenLines += [item]
                            }
                            #endif
                            
                            // Table
                            if item.contains("[[table") {
                                let tableSlice = filteredText.slice(with: "[[table", and: "[[/table]]")
                                ArticleTable(
                                    doc: tableSlice
                                )
                                let _ = filteredText = filteredText.replacingOccurrences(of: tableSlice, with: "")
                                let _ = forbiddenLines += tableSlice.components(separatedBy: .newlines)
                            }
                            
                            // Link
                            if item.contains("[[[") {
                                let content = item.replacingOccurrences(of: "://*", with: "://")
                                InlineButton(
                                    article: article,
                                    content: content
                                )
                                let _ = forbiddenLines += [item]
                            }
                            
                            // Text
                            if !forbiddenLines.contains(item) {
                                #if os(iOS)
                                Markdown(item)
                                    .id(item)
                                    .contextMenu {
                                        Button {
                                            article.setScroll(item)
                                        } label: {
                                            Label("Save Position", systemImage: "bookmark")
                                        }
                                    }

                                #else
                                Text(item)
                                    .id(item)
                                    .contextMenu {
                                        Button {
                                            article.setScroll(item)
                                        } label: {
                                            Label("Save Position", systemImage: "bookmark")
                                        }
                                    }

                                #endif
                            }
                        }
                        .onAppear {
                            if article.currenttext != nil && defaults.bool(forKey: "autoScroll") && filtered {
                                value.scrollTo(article.currenttext!)
                            }
                        }
                    } else if mode == 1 { // Raw
                        let list = article.pagesource.components(separatedBy: .newlines)
                        ForEach(list, id: \.self) { item in
                            Text(item)
                                .id(item)
                                .contextMenu {
                                    Button {
                                        article.setScroll(item)
                                    } label: {
                                        Label("Save Position", systemImage: "bookmark")
                                    }
                                }
                        }
                    }
                }
            }
        }
    }
}

func FilterToMarkdown(doc: String, completion: @escaping (String) -> Void) {
    DispatchQueue.main.async {
        var text = doc
        
        // Basic Divs
        for _ in text.indicesOf(string: "[[*user") { text.removeText(from: "[[*user", to: "]]") }
        text.removeText(from: "[[include component:info-ayers", to: "]]")
        text.removeText(from: "[[include :scp-wiki:component:info-ayers", to: "]]")
        text.removeText(from: "[[include :scp-wiki:component:anomaly-class-bar-source", to: "]]")
        text.removeText(from: "[[include :scp-wiki:component:license-box", to: "license-box-end]]")
        text.removeText(from: "[[include info:start", to: "include info:end]]")
        text.removeText(from: "[[include :scp-wiki:theme", to: "]]")
        text.removeText(from: "[[module Rate", to: "]]")
        for _ in text.indicesOf(string: "[[div") {
            text.removeText(from: "[[div", to: "]]")
            text.removeText(from: "[[/div", to: "]]")
        }
        text.removeText(from: "[[size", to: "]]")
        text.removeText(from: "[[/size", to: "]]")
        text.removeText(from: "[[>", to: "]]")
        text.removeText(from: "[[/>", to: "]]")
        text.removeText(from: "[[=", to: "]]")
        text.removeText(from: "[[/=", to: "]]")
        text.removeText(from: "[!--", to: "--]")
        for _ in text.indicesOf(string: "[[module") { text.removeText(from: "[[module", to: "[[/module]]") }
        
        // Footnotes
        for _ in text.indicesOf(string: "[[footnote") {
            text = text.replacingOccurrences(of: "[[footnote]]", with: " (")
            text = text.replacingOccurrences(of: "[[/footnote]]", with: ")")
        }
        
        text = text.replacingOccurrences(of: "------", with: "---")
        text = text.replacingOccurrences(of: "@@@@", with: "\n")
        text = text.replacingOccurrences(of: "@@ @@", with: "\n")
        text = text.replacingOccurrences(of: "//", with: "*")
        text = text.replacingOccurrences(of: ":*scp-wiki", with: "://scp-wiki")
        text = text.replacingOccurrences(of: " --", with: " ~~")
        text = text.replacingOccurrences(of: "-- ", with: "~~ ")
        text = text.replacingOccurrences(of: "\n--", with: "\n~~")
        text = text.replacingOccurrences(of: "--\n", with: "~~\n")
        text = text.replacingOccurrences(of: "[[footnoteblock]]", with: "")
        text = text.replacingOccurrences(of: "++++++ ", with: "###### ")
        text = text.replacingOccurrences(of: "+++++ ", with: "##### ")
        text = text.replacingOccurrences(of: "++++ ", with: "#### ")
        text = text.replacingOccurrences(of: "+++ ", with: "### ")
        text = text.replacingOccurrences(of: "++ ", with: "## ")
        
        completion(text)
    }
}

struct RAISAText_Previews: PreviewProvider {
    static var previews: some View {
        RAISAText(article: placeHolderArticle)
    }
}
