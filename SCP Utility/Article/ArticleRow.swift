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
    @State var id: String
    @State var title: String
    @State var url: URL
    @State var completed: Bool
    @State var currenttext: String?
    @State var language: RAISALanguage?
    @State var objclass: ObjectClass?
    @State var esotericclass: EsotericClass?
    
    @State private var article: Article? = nil
    @State private var flavorText: String? = nil
    @State private var showArticle: Bool = false // article view
    @State private var showUpdateView: Bool = false
    @State private var showListAddView: Bool = false
    @State private var disabled: Bool = false
    @EnvironmentObject var subtitlesStore: SubtitlesStore
    var body: some View {
        let con = PersistenceController.shared
        
        Button {
            self.getArticleandOpen()
        } label: {
            ZStack {
                HStack {
                    VStack(spacing: 3) {
                        HStack {
                            Text(title)
                                .foregroundColor(.primary)
                                .lineLimit(1)
                            
                            if let subtitle = RaisaReq.getAlternateTitle(url: url, store: subtitlesStore), subtitle != "" {
                                Rectangle()
                                    .frame(width: 5, height: 1)
                                    .foregroundColor(.accentColor)
                                
                                Text(subtitle)
                                    .foregroundColor(.primary)
                                    .lineLimit(1)
                            }
                            
                            if completed {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.accentColor)
                            }
                            Spacer()
                        }
                        
                        HStack {
                            Image(systemName: "arrow.down.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 15, height: 14)
                            
                            Text(language?.toAbbr() ?? "")
                            
                            Text(currenttext ?? "...")
                                .lineLimit(1)
                                .foregroundColor(.secondary)
                                .font(.caption)
                            Spacer()
                        }
                    }
                    Spacer()
                    if let im = esotericclass?.toImage(), im != "" {
                        Image(im)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 30, height: 30)
                    } else if let im = objclass?.toImage(), im != "" {
                        Image(im)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 30, height: 30)
                    }
                }
                
                if disabled {
                    ProgressView()
                }
            }
        }
        .frame(height: 50)
        .contextMenu {
            Button {
                self.getArticleandOpen()
            } label: {
                Label("OPEN_IN_READER", systemImage: "rectangle.portrait.and.arrow.forward")
            }
            
            Divider()
            
            Button {
                disabled = true
                RaisaReq.pageSourceFromURL(url: url) {
                    if $1 != nil || $0 == nil {
                        disabled = false
                        return
                    }
                    
                    if article == nil {
                        if let articleitem = con.getArticleByID(id: id), let article = Article(fromEntity: articleitem) {
                            self.article = article
                        }
                    }
                    
                    if article != nil {
                        article!.updateSource($0!)
                        article!.downloadImages(ignoreUserPreference: true)
                        con.updatePageSource(id: article!.id, newPageSource: $0!)
                    }
                    disabled = false
                }
            } label: {
                Label("UPDATE_ARTICLE", systemImage: "square.and.arrow.down")
            }
            
            Button {
                if article == nil {
                    if let articleitem = con.getArticleByID(id: id), let article = Article(fromEntity: articleitem) {
                        self.article = article
                        showListAddView = true
                    }
                }
            } label: {
                Label("LISTADDVIEW_TITLE", systemImage: "bookmark")
            }
            
            Button {
                if article == nil {
                    if let articleitem = con.getArticleByID(id: id), let article = Article(fromEntity: articleitem) {
                        self.article = article
                        showUpdateView = true
                    }
                }
            } label: {
                Label("UPDATE_ATTRIBUTE", image: objclass?.toImage() ?? "euclid-icon")
            }
            
            Button(role: .destructive) {
                con.deleteArticleEntity(id: id)
                disabled = true
            } label: {
                Label("DELETE", systemImage: "trash")
            }
        }
        .disabled(disabled)
        .swipeActions(allowsFullSwipe: false) {
            Button(role: .destructive) {
                con.deleteArticleEntity(id: id)
            } label: { Image(systemName: "trash") }
        }
        .sheet(isPresented: $showUpdateView, onDismiss: {
            if let articleitem = con.getArticleByID(id: id), let article = Article(fromEntity: articleitem) {
                self.article = article
            }
        }) {
            UpdateAttributeView(article: article ?? placeHolderArticle)
        }
        .fullScreenCover(isPresented: $showArticle, onDismiss: {
            if let articleitem = con.getArticleByID(id: id), let article = Article(fromEntity: articleitem) {
                self.article = article
            } else {
                disabled = true
            }
        }) {
            if article != nil {
                NavigationStack { ArticleView(scp: article!) }
            }
        }
        .sheet(isPresented: $showListAddView) {
            if article != nil {
                ListAdd(isPresented: $showListAddView, article: article!)
            }
        }
        .task {
            if objclass == .unknown {
                // MARK: Tag Scanning
                if article == nil {
                    if let articleitem = con.getArticleByID(id: id), let article = Article(fromEntity: articleitem) {
                        self.article = article
                    }
                }
                
                if article != nil {
                    RaisaReq.tags(url: url) { tags, _ in
                        for tag in tags ?? [] {
                            switch tag {
                            case "keter": article!.updateAttribute(objectClass: .keter); break
                            case "euclid": article!.updateAttribute(objectClass: .euclid); break
                            case "safe": article!.updateAttribute(objectClass: .safe); break
                            case "neutralized": article!.updateAttribute(objectClass: .neutralized); break
                            case "pending": article!.updateAttribute(objectClass: .pending); break
                            case "explained": article!.updateAttribute(objectClass: .explained); break
                                
                            case "apollyon": article!.updateAttribute(objectClass: .esoteric); article!.updateAttribute(esotericClass: .apollyon); break
                            case "archon": article!.updateAttribute(objectClass: .esoteric); article!.updateAttribute(esotericClass: .archon); break
                            case "cernunnos": article!.updateAttribute(objectClass: .esoteric); article!.updateAttribute(esotericClass: .cernunnos); break
                            case "decommissioned": article!.updateAttribute(objectClass: .esoteric); article!.updateAttribute(esotericClass: .decommissioned); break
                            case "hiemal": article!.updateAttribute(objectClass: .esoteric); article!.updateAttribute(esotericClass: .hiemal); break
                            case "tiamat": article!.updateAttribute(objectClass: .esoteric); article!.updateAttribute(esotericClass: .tiamat); break
                            case "ticonderoga": article!.updateAttribute(objectClass: .esoteric); article!.updateAttribute(esotericClass: .ticonderoga); break
                            case "thaumiel": article!.updateAttribute(objectClass: .esoteric); article!.updateAttribute(esotericClass: .thaumiel); break
                            case "uncontained": article!.updateAttribute(objectClass: .esoteric); article!.updateAttribute(esotericClass: .uncontained); break
                            default: continue
                            }
                        }
                        
                        if objclass == .unknown {
                            article!.updateAttribute(objectClass: .esoteric)
                        }
                    }
                }
            }
        }
        .id(id)
    }
    
    private func getArticleandOpen() {
        self.disabled = true
        if let item = PersistenceController.shared.getArticleByID(id: self.id){
            let a = Article(fromEntity: item)
            self.article = a
            
            showArticle = true
            self.disabled = false
        }
    }
}

struct ArticleRow_Previews: PreviewProvider {
    static var previews: some View {
        ArticleRow(
            id: "",
            title: "Tufto's Proposal",
            url: placeholderURL,
            completed: false,
            objclass: ObjectClass.esoteric,
        )
    }
}
