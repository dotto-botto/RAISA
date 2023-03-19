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

// TODO: - Optimize redundant checks
func testValid(item: String) -> Bool {
    switch item {
    case "=====": return false
    case "}": return false
    case "> ----": return false
        
    case let str where str.contains("#page"): return false
    case let str where str.contains("|") && !str.contains("||"): return false
    case let str where str.contains("> **Title:**"): return false
    case let str where str.contains("> **Author(s):**"): return false
    case let str where str.contains("> **Release year:**"): return false
    case let str where str.contains("> **Note:**"): return false
    case let str where str.contains("> **Source:**"): return false
    case let str where str.contains("> **License:**"): return false
    case let str where str.contains("> **Author:**"): return false
    case let str where str.contains("[[") && !str.contains("[[footnote]]"): return false
    case let str where str.contains("]]") && !str.contains("[[footnote]]"): return false
    case let str where str.contains("@@"): return false
    case let str where str.contains("sup {"): return false
    case let str where str.contains(":root{"): return false
    case let str where str.contains("vertical-align:"): return false
    case let str where str.contains("Filename:"): return false
    case let str where str.contains("[!--:"): return false
        
    case let str where str.last == ";": return false
    case let str where str.last == "{": return false
    case let str where str.last == "}": return false

    default: return true
    }
}
    
// MARK: - View
struct ArticleView: View {
    @State var scp: Article
    @State var presentSheet: Bool = false
    
    let defaults = UserDefaults.standard
    var body: some View {
        let document = scp.pagesource.components(separatedBy: CharacterSet.newlines)
//        let document = scp.pagesource
        
        let mode = defaults.integer(forKey: "articleViewSetting")
        #if os(iOS)
        let _ = PersistenceController.shared.createHistory(from: History(title: scp.title, thumbnail: scp.thumbnail))
        #endif
        
        ScrollView {
            #if os(iOS)
            if scp.thumbnail != nil && defaults.bool(forKey: "showImages") { KFImage(scp.thumbnail).frame(width: 425)
            }
            #endif
    
            VStack {
                if mode == 0 || mode == 1 {
                    ForEach(document, id: \.self) { item in
                        if testValid(item: item) && mode == 0 {
                            Text(.init(item
                                .replacingOccurrences(of: "//", with: "_")
                                .replacingOccurrences(of: "++ ==", with: "# ")
                                .replacingOccurrences(of: ">", with: "")
                                .replacingOccurrences(of: "--", with: "~~") // strikethrough

                            ))
                            .onTapGesture {
//                                print("tapped")
                            }
                        } else if mode == 1 {
                            Text(item)
                        }
                    }
                } else if mode == 2 {

                }
//                Markdown(FilterToMarkdown(doc: document))
            }
            .navigationTitle(scp.title)
        }
        .sheet(isPresented: $presentSheet) {
        } content: {
            ListAdd(isPresented: $presentSheet, article: scp)
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: {
                    presentSheet.toggle()
                }, label: {
                    Image(systemName: "bookmark")
                })
            }
        }
    }
}

func FilterToMarkdown(doc: String) -> String {
    var document = doc
    
    document = document.removeText(from: "[[module CSS]]", to: "[[/module]]")
    document = document.removeText(from: "[[include", to: "]]")
    
    var oldLink = document.slice(from: "[[[", to: "]]]") // Links
    if oldLink != nil {
        oldLink = oldLink!.slice(from: "|", to: oldLink!.last!.description)
        document = document.replacingOccurrences(of: "[[[]]]", with: oldLink!)
    }
    
    document = document.replacingOccurrences(of: "@@@@", with: "\n")
    document = document.replacingOccurrences(of: "[[>]]", with: "")
    document = document.replacingOccurrences(of: "[[module Rate]]", with: "")
    document = document.replacingOccurrences(of: "[[/>]]", with: "")
    document = document.replacingOccurrences(of: "||", with: "|")

    
    return document
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

// MARK: - Table
struct WikidotTable: View {
    @State var text: String
    
    var body: some View {
        let array = text.components(separatedBy: CharacterSet.newlines)

    }
}

// MARK: - Text
struct DotText: View {
    @State var text: String
    var body: some View {
        Text(.init(text
            .replacingOccurrences(of: "//", with: "_")
            .replacingOccurrences(of: "++ ==", with: "# ")
            .replacingOccurrences(of: ">", with: "")
            .replacingOccurrences(of: "--", with: "~~") // strikethrough
                  ))
    }
}

// MARK: - Slice
// https://stackoverflow.com/a/31727051
extension String {
    func slice(from: String, to: String) -> String? {
        return (range(of: from)?.upperBound).flatMap { substringFrom in
            (range(of: to, range: substringFrom..<endIndex)?.lowerBound).map { substringTo in
                String(self[substringFrom..<substringTo])
            }
        }
    }
    
    mutating func removeText(from: String, to: String) -> String {
        let toSlice = self.slice(from: from, to: to)
        if toSlice != nil {
            return self.replacingOccurrences(of: toSlice!, with: "")
        } else {
            return self
        }
    }
}


struct ArticleView_Previews: PreviewProvider {
    static var previews: some View {
        ArticleView(scp: Article(title: "Tufto's Proposal", pagesource: "Lorem Ipsum"))
    }
}
