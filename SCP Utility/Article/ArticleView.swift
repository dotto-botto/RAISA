//
//  ArticleView.swift
//  SCP Wiki Utility
//
//  Created by Maximus Harding on 12/25/22.
//

import SwiftUI
    
// MARK: - View
/// View that wraps around RAISAText to display various controls to the user.
/// ArticleView also displays warnings before an article is displayed.
struct ArticleView: View {
    @State var scp: Article
    @State var dismissText: String? = ""
    @State var presentSheet: Bool = false
    @State private var showInfo: Bool = false
    @State private var showComments: Bool = false
    @State private var bookmarkStatus: Bool = false
    @State private var checkmarkStatus: Bool = false
    @State private var forbidden: Bool = true
    @State private var nextArticle: Article? = nil
    @State private var showNext: Bool = false
    @State private var forbiddenComponents: [String] = []
    @State private var containsExplicitContent: Bool = true
    @State private var explicitContent: [String] = []
    @State private var isBuiltIn: Bool = false
    @State private var isFragmented: Bool = true
    @State private var subtitle: String = ""
    @Environment(\.dismiss) var dismiss
    @AppStorage("showComponentPrompt") var showComponentPrompt = true
    let defaults = UserDefaults.standard
    let con = PersistenceController.shared
    var body: some View {
        if scp.url.formatted().contains("://scp-wiki.wikidot.com/scp-001") && scp.title == "SCP-001" {
            ScrollView {
                SCP001View()
                    .onAppear { isBuiltIn = true }
                    .padding(.horizontal, 5)
            }
        }
        VStack(alignment: .leading) {
            if forbidden && showComponentPrompt && !isBuiltIn {
                VStack {
                    Text("AV_UNSUPPORTED")
                        .foregroundColor(.gray)
                        .font(.largeTitle)
                        .padding(.bottom, 20)
                    
                    Text("AV_UNSUPPORTED_GUIDE").foregroundColor(.gray)
                    ForEach(forbiddenComponents, id: \.self) { comp in
                        Text(comp).foregroundColor(.gray)
                    }
                    
                    Button("AV_DISPLAY_AS_IS") {
                        forbidden = false
                    }
                    .padding(.vertical, 10)
                    
                    Text("AV_USER_TIRED_OF_WARNING").foregroundColor(.gray)
                }
            }
            
            if !forbidden && containsExplicitContent && !isBuiltIn {
                VStack {
                    Text("AV_SENSITIVE")
                        .foregroundColor(.gray)
                        .font(.largeTitle)
                        .padding(.bottom, 20)
                    
                    ForEach(explicitContent, id: \.self) { comp in
                        Text(comp).foregroundColor(.gray)
                    }
                    
                    Button("CONTINUE") {
                        containsExplicitContent = false
                    }
                    .padding(.top, 10)
                    
                    Button("BACK") {
                        dismiss()
                    }
                }
            }
            
            if !forbidden && !containsExplicitContent && !isBuiltIn && !isFragmented {
                RAISAText(article: scp)
            }
        }
        .navigationTitle(scp.title)
        .onAppear {
            bookmarkStatus = scp.isSaved()
            checkmarkStatus = scp.isComplete()
            
            if scp.title == "Could not find title" {
                dismiss()
            }
            
            con.createHistory(from: History(title: scp.title, thumbnail: scp.thumbnail))
            defaults.set(scp.url, forKey: "lastReadUrl")
            
            if scp.pagesource.contains("[[module ListPages") {
                isFragmented = true
                replaceFragmentsWithSource(article: scp) { newArticle in
                    con.updatePageSource(id: scp.id, newPageSource: newArticle.pagesource)
                    scp = newArticle
                    isFragmented = false
                }
            } else {
                isFragmented = false
            }
            
            if forbidden {
                if let list = scp.findForbiddenComponents(), showComponentPrompt {
                    forbiddenComponents = list
                    forbidden = true
                } else {
                    forbidden = false
                }
            }
            
            if containsExplicitContent {
                if let list = scp.findContentWarnings() {
                    explicitContent = list
                } else {
                    containsExplicitContent = false
                }
            }
            
            findNextArticle(currentTitle: scp.title) { article in
                nextArticle = article
            }
        }
        .sheet(isPresented: $presentSheet, onDismiss: {
            bookmarkStatus = scp.isSaved()
        }) {
            ListAdd(isPresented: $presentSheet, article: scp)
        }
        .sheet(isPresented: $showInfo) {
            ArticleInfoView(article: scp)
        }
        .sheet(isPresented: $showComments) {
            CommentsView(article: scp)
        }
        .fullScreenCover(isPresented: $showNext) {
            NavigationStack { ArticleView(scp: nextArticle ?? scp, dismissText: scp.title) }
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                VStack {
                    Text(scp.title).font(.headline)
                    if subtitle != "" {
                        Text(containsExplicitContent ? "-" : subtitle).font(.subheadline)
                    }
                }
                .task {
                    cromGetAlternateTitle(url: scp.url) { subtitle = $0 }
                }
            }
            
            ToolbarItem(placement: .cancellationAction) {
                Button {
                    dismiss()
                } label: {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text(dismissText ?? "")
                    }
                }
                .contextMenu {
                    var rootViewController: UIViewController? = nil
                    Button {
                        rootViewController?.dismiss(animated: true)
                    } label: {
                        Label("AV_DISMISS_ALL", systemImage: "house")
                    }
                    .task {
                        // https://stackoverflow.com/a/69968825/11248074
                        rootViewController = {
                            UIApplication.shared.connectedScenes
                                    .filter {$0.activationState == .foregroundActive }
                                    .map {$0 as? UIWindowScene }
                                    .compactMap { $0 }
                                    .first?.windows
                                    .filter({ $0.isKeyWindow }).first?.rootViewController
                        }()
                    }
                }
            }

            ToolbarItem {
                Button {
                    showNext = true
                } label: {
                    if nextArticle != nil {
                        HStack {
                            Text(nextArticle!.title)
                            Image(systemName: "chevron.right")
                        }
                    }
                }
            }

            // Bottom
            ToolbarItemGroup(placement: .bottomBar) {
                Button {
                    presentSheet.toggle()
                } label: {
                    Image(systemName: bookmarkStatus ? "bookmark.fill": "bookmark")
                }
                .disabled(containsExplicitContent)

                Spacer()
                Button {
                    showInfo.toggle()
                } label: {
                    Image(systemName: "info.circle")
                }
                .disabled(containsExplicitContent)

                Spacer()
                Button {
                    showComments.toggle()
                } label: {
                    Image(systemName: "bubble.left.and.bubble.right")
                }
                .disabled(containsExplicitContent)

                Spacer()
                Menu {
                    ForEach(RAISALanguage.allCases) { lang in
                        Button(lang.toName()) {
                            cromTranslate(url: scp.url, from: scp.findLanguage() ?? .english, to: lang) { article in
                                nextArticle = article
                                showNext = true
                            }
                        }
                    }
                } label: {
                    Image(systemName: "globe")
                }

                Spacer()
                Button {
                    checkmarkStatus.toggle()
                } label: {
                    if checkmarkStatus {
                        Image(systemName: "checkmark")
                    } else {
                        Image(systemName: "checkmark")
                            .foregroundColor(.secondary)
                            .opacity(0.5)
                    }
                }
                .onChange(of: checkmarkStatus) {
                    scp.complete(updateTo: $0)
                }
            }
        }
        .tint(scp.findTheme()?.themeAccent)
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
        let toSlice = self.slice(with: from, and: to)
          self = self.replacingOccurrences(of: toSlice, with: "")
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
