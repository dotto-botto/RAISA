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
    
    @State private var filtered: Bool = false
    @State private var filteredText = ""
    @AppStorage("articleViewSetting") var mode = 0
    var body: some View {
        let defaults = UserDefaults.standard
        ScrollViewReader { value in
            ScrollView {
                VStack(alignment: .leading) {
                    if mode == 0 && !filtered {
                        ProgressView()
                            .onAppear {
                                FilterToMarkdown(doc: article.pagesource) { str in
                                    filteredText = str
                                    filtered = true
                                }
                            }
                    }
                    
                    if filtered && mode == 0 { // Default
                        var forbiddenLines: [String] = []
                        let list = filteredText.components(separatedBy: .newlines)
                        ForEach(list, id: \.self) { item in
                            // Collapsible
                            if item.contains("[[collapsible") {
                                let sliced = filteredText.slice(with: item, and: "[[/collapsible]]")
                                
                                Collapsible(
                                    articleID: article.id,
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
                            
                            // Text
                            if !forbiddenLines.contains(item) {
                                #if os(iOS)
                                Markdown(item)
                                    .padding(.bottom, 1)
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
                                    .padding(.bottom, 1)
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
                                .padding(.bottom, 1)
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
        
        // Links
        text.removeText(from: "<< [[[", to: "]]] >>")
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

//struct RAISAText_Previews: PreviewProvider {
//    static var previews: some View {
//        RAISAText()
//    }
//}
