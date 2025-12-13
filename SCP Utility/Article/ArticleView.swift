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
    @State var subtitle: String? = nil
    @State var dismissText: String? = ""
    @State var presentSheet: Bool = false
    @State var theme: RAISATheme? = nil
    @State var markLatest: Bool? = true
    
    @State private var showInfo: Bool = false
    @State private var showComments: Bool = false
    @State private var bookmarkStatus: Bool = false
    @State private var checkmarkStatus: Bool = false
    @State private var nextArticle: Article? = nil
    @State private var showNext: Bool = false
    @State private var showFootnoteView: Bool = false
    @State private var footnoteIndex: Int? = nil
    @State private var containsExplicitContent: Bool = true
    @State private var explicitContent: [String] = []
    @State private var isFragmented: Bool = true
    @State private var showBookmarkAlert: Bool = false
    @State private var noTranslationAlert: Bool = false
    @State private var showTOCView: Bool = false
    @State private var TOCExists: Bool = false
    @AppStorage("showAVWallpaper") var showBackground: Bool = true
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var subtitlesStore: SubtitlesStore
    let defaults = UserDefaults.standard
    let con = PersistenceController.shared
    var body: some View {
        let theme: RAISATheme? = theme ?? scp.findTheme()
        
        // MARK: View
        VStack(alignment: .leading) {
            if containsExplicitContent {
                VStack {
                    Text("AV_SENSITIVE")
                        .foregroundColor(.secondary)
                        .font(.largeTitle)
                        .padding(.bottom, 20)
                    
                    ForEach(explicitContent, id: \.self) { comp in
                        Text(comp).foregroundColor(.secondary)
                    }
                    
                    Button("CONTINUE") {
                        containsExplicitContent = false
                    }
                    .padding(.top, 20)
                    .frame(height: 44.0)
                }
            }
            
            if !containsExplicitContent && !isFragmented {
                RAISAText(article: scp)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        // MARK: On Appear
        .onAppear {
            bookmarkStatus = scp.isSaved()
            checkmarkStatus = scp.isComplete()
            
            if scp.title == "Could not find title" {
                dismiss()
            }
            
            if defaults.bool(forKey: "trackHistory") && scp.title != "Could not find title" {
                con.createHistory(from: History(title: scp.title, thumbnail: scp.thumbnail))
            }
            
            if markLatest ?? false {
                defaults.set(scp.url, forKey: "lastReadUrl")
            }
            
            if scp.pagesource.contains("[[module ListPages") {
                isFragmented = true
                replaceFragmentsWithSource(article: scp) { newSource in
                    con.updatePageSource(id: scp.id, newPageSource: newSource)
                    scp.updateSource(newSource)
                    isFragmented = false
                }
            } else {
                isFragmented = false
            }
            
            if containsExplicitContent {
                if let list = scp.findContentWarnings() {
                    explicitContent = list
                } else {
                    containsExplicitContent = false
                }
            }
            
            if scp.pagesource.contains(/\[\[.*?toc.*?]]/) {
                TOCExists = true
            }
            
            scp.findNextArticle() { article in
                nextArticle = article
            }
        }
        // MARK: Sheets
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
        .sheet(isPresented: $showFootnoteView) {
            FootnoteView(article: scp, selectedNoteIndex: footnoteIndex)
                .presentationDetents([.medium])
        }
        .sheet(isPresented: $showTOCView) {
            TOCView(toc: TOC(fromArticle: scp))
                .presentationDetents([.medium])
        }
        .fullScreenCover(isPresented: $showNext) {
            NavigationStack { ArticleView(scp: nextArticle ?? scp, dismissText: scp.title) }
        }
        .alert("WANTED_TO_BOOKMARK", isPresented: $showBookmarkAlert) { 
            Button("BACK_TO_ARTICLE") {}
            
            Button("DONT_SHOW_AGAIN") {
                defaults.set(false, forKey: "bookmarkAlert")
                dismiss()
            }
        } message: {
            Text("HOW_TO_SAVE")
        }
        .toolbar {
            // MARK: Top Bar
            ToolbarItem(placement: .principal) {
                VStack {
                    Text(scp.title).font(.headline)
                    if subtitle != nil && subtitle != "" {
                        Text(containsExplicitContent ? "-" : subtitle!).font(.subheadline)
                    }
                }
                .task {
                    if subtitle == nil {
                        subtitle = RaisaReq.getAlternateTitle(url: scp.url, store: subtitlesStore)
                    }
                }
            }
            
            ToolbarItem(placement: .cancellationAction) {
                Button {
                    if bookmarkStatus == true && con.getScroll(id: scp.id) == nil && defaults.bool(forKey: "bookmarkAlert") {
                        showBookmarkAlert.toggle()
                    } else {
                        dismiss()
                    }
                } label: {
                    Image(systemName: "chevron.left")
                }
                .frame(width: 44.0, height: 44.0)
                .contextMenu {
                    if #unavailable(iOS 16.0) {
                        var rootViewController: UIViewController? = nil
                        Button {
                            rootViewController?.dismiss(animated: true)
                        } label: {
                            Label("AV_DISMISS_ALL", systemImage: "house")
                        }
                        .task {
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
            }
            
            ToolbarItem {
                if nextArticle != nil {
                    Button {
                        showNext = true
                    } label: {
                        Image(systemName: "chevron.right")
                    }
                    .frame(width: 44.0, height: 44.0)
                }
            }

            // MARK: Bottom Bar
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
                    ForEach(RAISALanguage.allSupportedCases) { lang in
                        Button("\(lang.emoji()) \(lang.toName())") {
                            RaisaReq.translate(url: scp.url, from: scp.findLanguage() ?? .english, to: lang) { article, _ in
                                // Wasn't translated
                                if article == nil {
                                    noTranslationAlert.toggle()
                                } else {
                                    nextArticle = article
                                    showNext = true
                                }
                            }
                        }
                    }
                } label: {
                    Image(systemName: "globe")
                }
                .alert("NO_TRANSLATION_FOUND", isPresented: $noTranslationAlert) {
                    Button("OK") {}
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
                
                Group {
                    Spacer()
                    Menu {
                        // Footnote view
                        Button {
                            showFootnoteView.toggle()
                        } label: {
                            HStack {
                                Text("FOOTNOTE_TITLE")
                                Image(systemName: "textformat.superscript")
                            }
                        }
                        .disabled(!scp.pagesource.contains("[[footnote]]"))
                        .disabled(containsExplicitContent)
                        
                        // Background toggle
                        Button {
                            showBackground.toggle()
                        } label: {
                            HStack {
                                Text("TOGGLE_BG")
                                Image(systemName: "photo")
                                    .opacity(showBackground ? 1 : 0.3)
                            }
                        }
                        .disabled(theme == nil)
                        
                        // Table of contents view
                        Button {
                            showTOCView.toggle()
                        } label: {
                            HStack {
                                Text("TOCV_TITLE")
                                Image(systemName: "list.bullet.rectangle")
                                    .opacity(showBackground ? 1 : 0.3)
                            }
                        }
                        .disabled(!TOCExists)
                        
                        // Vote button
//                        Menu {
//                            if #available(iOS 16.4, *) {
//                                ControlGroup {
//                                    Button {
//                                        RaisaReq.ratePage(url: scp.url, vote: .up) { _ in }
//                                    } label: {
//                                        Label("Upvote", systemImage: "plus")
//                                    }
//                                    
//                                    Button {
//                                        RaisaReq.ratePage(url: scp.url, vote: .down) { _ in }
//                                    } label: {
//                                        Label("Downvote", systemImage: "minus")
//                                    }
//                                    
//                                    Button {
//                                        RaisaReq.ratePage(url: scp.url, vote: .clear) { _ in }
//                                    } label: {
//                                        Label("Clear vote", systemImage: "xmark")
//                                    }
//                                }
//                                .controlGroupStyle(.compactMenu)
//                            } else {
//                                Button {
//                                    RaisaReq.ratePage(url: scp.url, vote: .clear) { _ in }
//                                } label: {
//                                    Label("Clear vote", systemImage: "xmark")
//                                }
//                                
//                                Button {
//                                    RaisaReq.ratePage(url: scp.url, vote: .down) { _ in }
//                                } label: {
//                                    Label("Downvote", systemImage: "minus")
//                                }
//                                
//                                Button {
//                                    RaisaReq.ratePage(url: scp.url, vote: .up) { _ in }
//                                } label: {
//                                    Label("Upvote", systemImage: "plus")
//                                }
//                            }
//                        } label: {
//                            Label("Vote", systemImage: "arrow.up.arrow.down")
//                        }
                    } label: {
                        Image(systemName: "list.bullet")
                    }
                }
            }
        }
        .background {
            if showBackground {
//            theme?.wallpaper
                switch theme?.keyword {
                case "theme:space": SpaceTheme().wallpaper
                case "theme:isolated-terminal": IsolatedTerminalTheme().wallpaper
                case "theme:creepypasta": CreepypastaTheme().wallpaper
                case "theme:flopstyle-dark": FlopstyleDarkTheme().wallpaper
                default: AnyView(EmptyView())
                }
            }
        }
        .tint(theme?.themeAccent ?? Color("AccentColor"))
        .preferredColorScheme(theme?.preferredScheme)
        .onDisappear {
            defaults.set("", forKey: "focusedCurrentText")
        }
        .onOpenURL { url in
            // raisa://footnote/x
            guard url.scheme == "raisa" else { return }
            
            let components = url.absoluteString.components(separatedBy: "/")
            guard components.count == 4 else { return }
            guard components[2] == "footnote" else { return }
            guard let ind = components.last else { return }
            
            // This workaround is necessary for the sheet to appear
            let i = Int(ind)
            if footnoteIndex == i {
                // Update it twice so onchange will trigger
                footnoteIndex = i
                footnoteIndex = 0
            } else {
                footnoteIndex = i
            }
        }
        // footnote index won't be correctly passed to the sheet without this workaround
        .onChange(of: footnoteIndex) { _ in
            showFootnoteView = true
        }
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
            ArticleView(scp: placeHolderArticle, theme: SpaceTheme())
        }.previewDisplayName("Normal")
        
        NavigationStack {
            ArticleView(scp: Article(
                title: "Tufto's Proposal",
                pagesource: "[[math",
                url: placeholderURL,
                thumbnail: URL(string: "https://scp-wiki.wdfiles.com/local--files/scp-7606/SCPded.jpg")
            ))
        }.previewDisplayName("Forbidden")
    }
}
