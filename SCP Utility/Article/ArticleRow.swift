//
//  ArticleItem.swift
//  SCP Wiki Utility
//
//  Created by Maximus Harding on 12/30/22.
//

import SwiftUI

/// The main view used to display articles that are saved by the user.
/// Meant to be used inside of a List or a VStack.
struct ArticleRow: View {
    @State var passedSCP: Article
    @State private var showSheet: Bool = false // list add view
    @State private var showArticle: Bool = false // article view
    @State var open: Int = UserDefaults.standard.integer(forKey: "defaultOpen")
    @State private var bookmarkStatus: Bool = false
    @State private var showUpdateView: Bool = false
    var body: some View {
        let con = PersistenceController.shared
        
        Button {
            if open == 1 {
                showArticle = true
            } else {
                addIDToBar(id: passedSCP.id)
                
                if open == 2 {
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
            Button {
                addIDToBar(id: passedSCP.id)
            } label: {
                Label("ADD_TO_BAR", systemImage: "plus.circle")
            }
            
            Button {
                showArticle = true
            } label: {
                Label("OPEN_IN_READER", systemImage: "rectangle.portrait.and.arrow.forward")
            }
            
            Button {
                showUpdateView = true
            } label: {
                Label("UPDATE_ATTRIBUTE", image: passedSCP.objclass?.toImage() ?? "euclid-icon")
            }
            
            Divider()
            
            if passedSCP.pagesource == "" {
                Button {
                    cromGetSourceFromURL(url: passedSCP.url) { source in
                        con.updatePageSource(id: passedSCP.id, newPageSource: source)
                    }
                } label: {
                    Label("DOWNLOAD", systemImage: "square.and.arrow.down")
                }
            } else {
                Button {
                    con.deletePageSource(id: passedSCP.id)
                } label: {
                    Label("OFFLOAD", systemImage: "square.and.arrow.up")
                }
            }
        } preview: {
            NavigationStack { RAISAText(article: passedSCP) }
        }
        .swipeActions(allowsFullSwipe: false) {
            Button(role: .destructive) {
                con.deleteArticleEntity(id: passedSCP.id)
            } label: { Image(systemName: "trash") }
        }
        .sheet(isPresented: $showSheet) {
            ListAdd(isPresented: $showSheet, article: passedSCP)
        }
        .sheet(isPresented: $showUpdateView) {
            UpdateAttributeView(article: passedSCP)
        }
        .fullScreenCover(isPresented: $showArticle) {
            NavigationStack { ArticleView(scp: passedSCP) }
        }
        .onAppear {
            if passedSCP.objclass == .unknown {
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
                                
                            case "apollyon": passedSCP.updateAttribute(objectClass: .esoteric); passedSCP.updateAttribute(esotericClass: .apollyon); break
                            case "archon": passedSCP.updateAttribute(objectClass: .esoteric); passedSCP.updateAttribute(esotericClass: .archon); break
                            case "cernunnos": passedSCP.updateAttribute(objectClass: .esoteric); passedSCP.updateAttribute(esotericClass: .cernunnos); break
                            case "decommissioned": passedSCP.updateAttribute(objectClass: .esoteric); passedSCP.updateAttribute(esotericClass: .decommissioned); break
                            case "hiemal": passedSCP.updateAttribute(objectClass: .esoteric); passedSCP.updateAttribute(esotericClass: .hiemal); break
                            case "tiamat": passedSCP.updateAttribute(objectClass: .esoteric); passedSCP.updateAttribute(esotericClass: .tiamat); break
                            case "ticonderoga": passedSCP.updateAttribute(objectClass: .esoteric); passedSCP.updateAttribute(esotericClass: .ticonderoga); break
                            case "thaumiel": passedSCP.updateAttribute(objectClass: .esoteric); passedSCP.updateAttribute(esotericClass: .thaumiel); break
                            case "uncontained": passedSCP.updateAttribute(objectClass: .esoteric); passedSCP.updateAttribute(esotericClass: .uncontained); break
                            default: continue
                            }
                        }
                        
                        if passedSCP.objclass == .unknown {
                            passedSCP.updateAttribute(objectClass: .esoteric)
                        }
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
        ))
    }
}
