//
//  ArticleView.swift
//  SCP Wiki Utility
//
//  Created by Maximus Harding on 12/25/22.
//

import SwiftUI
    
// MARK: - View
struct ArticleView: View {
    @State var scp: Article
    @State var presentSheet: Bool = false
    @State var showSafari: Bool = false
    @State private var showInfo: Bool = false
    @State private var resume: Bool = false
    @State private var tooltip: Bool = false
    @State private var bookmarkStatus: Bool = false
    @State private var forbidden: Bool = true
    @State private var forbiddenComponents: [String] = []
    @Environment(\.dismiss) var dismiss
    @AppStorage("showComponentPrompt") var showComponentPrompt = true
    let defaults = UserDefaults.standard
    let con = PersistenceController.shared
    var body: some View {
        let mode: Int = defaults.integer(forKey: "articleViewSetting")
        VStack(alignment: .leading) {
            if forbidden && showComponentPrompt {
                VStack {
                    Text("This article contains unsupported components, it may not display correctly.")
                        .foregroundColor(.gray)
                        .font(.largeTitle)
                        .padding(.bottom, 20)
                    
                    Text("Unsupported Components:").foregroundColor(.gray)
                    ForEach(forbiddenComponents, id: \.self) { comp in
                        Text(comp).foregroundColor(.gray)
                    }
                    
                    HStack {
                        Button("Display As Is") {
                            forbidden = false
                        }
                        Text("or").foregroundColor(.gray)
                        Button("Open In Safari") {
                            showSafari = true
                        }
                    }
                    .padding(.vertical, 10)
                    
                    Text("You can turn this warning off in settings.").foregroundColor(.gray)
                }
            }
            
            if !forbidden {
                RAISAText(article: scp)
            }
        }
        .navigationTitle(scp.title)
        .onAppear {
            #if os(iOS)
            con.createHistory(from: History(title: scp.title, thumbnail: scp.thumbnail))
            #endif
            defaults.set(scp.url, forKey: "lastReadUrl")
            
            if mode == 0 && forbidden {
                if let list = scp.findForbiddenComponents(), showComponentPrompt {
                    forbiddenComponents = list
                    forbidden = true
                } else {
                    forbidden = false
                }
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
        NavigationStack {
            ArticleView(scp: placeHolderArticle)
        }.previewDisplayName("Normal")
        
        NavigationStack {
            ArticleView(scp: Article(
                title: "Tufto's Proposal",
                pagesource: "[[html",
                url: placeholderURL,
                thumbnail: URL(string: "https://scp-wiki.wdfiles.com/local--files/scp-7606/SCPded.jpg")
            ))
        }.previewDisplayName("Forbidden")
    }
}
