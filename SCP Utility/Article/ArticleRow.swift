//
//  ArticleItem.swift
//  SCP Wiki Utility
//
//  Created by Maximus Harding on 12/30/22.
//

import SwiftUI

struct ArticleRow: View {
    @State var passedSCP: Article
    @State var localArticle: Bool /// If the article comes from the core data store, or the Crom api
    @State var showSheet: Bool = false // list add view
    @State var showArticle: Bool = false // article view
    @State var barIds: String? = UserDefaults.standard.string(forKey: "articleBarIds")
    @State var open: Int = UserDefaults.standard.integer(forKey: "defaultOpen")
    @State private var bookmarkStatus: Bool = false
    var body: some View {
        let con = PersistenceController.shared
        let defaults = UserDefaults.standard
        
        Button {
            if localArticle {
                if open == 0 || open == 2 {
                    if barIds != nil {
                        barIds! += " " + passedSCP.id
                        defaults.set(barIds, forKey: "articleBarIds")
                    } else {
                        defaults.set(passedSCP.id, forKey: "articleBarIds")
                    }
                    
                    if open == 2 {
                        showArticle = true
                    }
                } else if open == 1 {
                    showArticle = true
                }
            } else {
                cromGetSourceFromURL(url: passedSCP.url) { source in
                    passedSCP.updateSource(source)
                    showArticle = true
                }
            }
        } label: {
            HStack {
                VStack(spacing: 3) {
                    HStack {
                        Text(passedSCP.title)
                            .foregroundColor(.primary)
                            .lineLimit(1)
                        if con.completionStatus(article: passedSCP) {
                            Image(systemName: "checkmark")
                                .foregroundColor(.accentColor)
                        }
                        Spacer()
                    }
                    
                    if localArticle {
                        HStack {
                            if passedSCP.pagesource != "" {
                                Image(systemName: "arrow.down.circle.fill")
                                    .resizable()
                                    .foregroundColor(.accentColor)
                                    .scaledToFit()
                                    .frame(width: 15, height: 14)
                            }
                            
                            var text = passedSCP.currenttext ??
                            passedSCP.pagesource.slice(from: "Description:** ") ??
                            passedSCP.pagesource
                            
                            if text == "" { // offloaded
                                let _ = text = NSLocalizedString("DOWNLOAD_ARTICLE_PROMPT", comment: "")
                            }
                                
                            Text(text)
                                .lineLimit(1)
                                .foregroundColor(.secondary)
                                .font(.monospaced(.caption2)())
                            Spacer()
                        }
                    }
                }
                Spacer()
                #if os(iOS)
                ZStack {
                    if let im = passedSCP.esoteric?.toImage(), im != "" {
                        if passedSCP.objclass == .esoteric {
                            Image(im)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 30, height: 30)
                        }
                    }
                }
                ZStack {
                    if let im = passedSCP.objclass?.toImage(), im != "" {
                        Image(im)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 30, height: 30)
                    }
                }
                #endif
            }
        }
        .contextMenu {
            if localArticle {
                Button {
                    if barIds != nil {
                        barIds! += " " + passedSCP.id
                        defaults.set(barIds, forKey: "articleBarIds")
                    } else {
                        defaults.set(passedSCP.id, forKey: "articleBarIds")
                    }
                } label: {
                    Label("Add to Bar", systemImage: "plus.circle")
                }
                
                Button {
                    showArticle = true
                } label: {
                    Label("Open in Reader", systemImage: "rectangle.portrait.and.arrow.forward")
                }
                
                Divider()
                
                if passedSCP.pagesource == "" {
                    Button {
                        cromGetSourceFromURL(url: passedSCP.url) { source in
                            con.updatePageSource(id: passedSCP.id, newPageSource: source)
                        }
                    } label: {
                        Label("Download", systemImage: "square.and.arrow.down")
                    }
                } else {
                    Button {
                        con.deletePageSource(id: passedSCP.id)
                    } label: {
                        Label("Offload", systemImage: "square.and.arrow.up")
                    }
                }
            }
        } preview: {
            NavigationStack { RAISAText(article: passedSCP) }
        }
        .swipeActions(allowsFullSwipe: false) {
            if localArticle {
                Button(role: .destructive) {
                    con.deleteArticleEntity(id: passedSCP.id)
                } label: { Image(systemName: "trash") }
            }
        }
        .sheet(isPresented: $showSheet) {
            ListAdd(isPresented: $showSheet, article: passedSCP)
        }
        .fullScreenCover(isPresented: $showArticle) {
            NavigationStack { ArticleView(scp: passedSCP) }
        }
        .onAppear {
            if localArticle && passedSCP.objclass == .unknown {
                // MARK: Article Scanning
                DispatchQueue.main.async {
                    cromGetTags(url: passedSCP.url) { tags in
                        for tag in tags {
                            switch tag {
                            case "keter": passedSCP.updateAttribute(objectClass: .keter); break
                            case "euclid": passedSCP.updateAttribute(objectClass: .euclid); break
                            case "safe": passedSCP.updateAttribute(objectClass: .safe); break
                            case "neutralized": passedSCP.updateAttribute(objectClass: .neutralized); break
                            case "pending": passedSCP.updateAttribute(objectClass: .pending); break
                            case "explained": passedSCP.updateAttribute(objectClass: .explained); break
                            case "esoteric-class": passedSCP.updateAttribute(objectClass: .esoteric); break
                            case "thaumiel": passedSCP.updateAttribute(objectClass: .esoteric); passedSCP.updateAttribute(esotericClass: .thaumiel); break
                            default: continue
                            }
                        }
                    }
                    
                    if passedSCP.objclass == .esoteric && passedSCP.esoteric == .unknown {
                        var newEso: EsotericClass? = nil
                        let doc = passedSCP.pagesource.lowercased()
                        if doc.contains("apollyon") { newEso = .apollyon }
                        else if doc.contains("archon") { newEso = .archon }
                        else if doc.contains("cernunnos") { newEso = .cernunnos }
                        else if doc.contains("decommissioned") { newEso = .decommissioned }
                        else if doc.contains("hiemal") { newEso = .hiemal }
                        else if doc.contains("tiamat") { newEso = .tiamat }
                        else if doc.contains("ticonderoga") { newEso = .ticonderoga }
                        else if doc.contains("thaumiel") { newEso = .thaumiel }
                        else if doc.contains("uncontained") { newEso = .uncontained }
                        
                        if newEso != nil { passedSCP.updateAttribute(esotericClass: newEso!) }
                        else { passedSCP.updateAttribute(esotericClass: .thaumiel) }
                    }
                }
            }
        }
    }
}

struct ArticleRow_Previews: PreviewProvider {
    static var previews: some View {
        ArticleRow(passedSCP: Article(
            title: "Tufto's Proposal",
            pagesource: "this is a --> EXPLAINED <-- scp, it is also --> apollyon <-- !!!!",
            url: placeholderURL,
            objclass: .keter,
            esoteric: .thaumiel,
            disruption: .amida,
            risk: .danger
        ), localArticle: true).previewDisplayName("Local")
        ArticleRow(passedSCP: Article(
            title: "Article with a extremely long title that could definitely break things if it is not accounted for!",
            pagesource: "",
            url: placeholderURL,
            objclass: .keter,
            esoteric: .thaumiel,
            disruption: .amida,
            risk: .danger
        ), localArticle: false).previewDisplayName("Online")
    }
}
