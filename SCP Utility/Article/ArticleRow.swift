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
    @State private var flavorText: String? = nil
    @State private var showArticle: Bool = false // article view
    @State private var showUpdateView: Bool = false
    @State private var showListAddView: Bool = false
    @State private var disabled: Bool = false
    var body: some View {
        let con = PersistenceController.shared
        
        Button {
            showArticle = true
        } label: {
            HStack {
                VStack(spacing: 3) {
                    HStack {
                        Text(passedSCP.title)
                            .foregroundColor(.primary)
                            .lineLimit(1)
                        
                        if let subtitle = passedSCP.subtitle, subtitle != "" {
                            Rectangle()
                                .frame(width: 5, height: 1)
                                .foregroundColor(.accentColor)
                            
                            Text(subtitle)
                                .foregroundColor(.primary)
                                .lineLimit(1)
                        }
                        
                        if passedSCP.isComplete() {
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
                        
                        Text(passedSCP.findLanguage()?.toAbbr() ?? "")
                                                
                        Text(flavorText ?? "...")
                            .lineLimit(1)
                            .foregroundColor(.secondary)
                            .font(.caption)
                        Spacer()
                    }
                }
                Spacer()
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
            
            Divider()
            
            Button {
                disabled = true
                cromGetSourceFromURL(url: passedSCP.url) {
                    passedSCP.updateSource($0)
                    passedSCP.downloadImages()
                    con.updatePageSource(id: passedSCP.id, newPageSource: $0)
                    disabled = false
                }
            } label: {
                Label("UPDATE_ARTICLE", systemImage: "square.and.arrow.down")
            }
            
            Button {
                showListAddView = true
            } label: {
                Label("LISTADDVIEW_TITLE", systemImage: "bookmark")
            }
            
            Button {
                showUpdateView = true
            } label: {
                Label("UPDATE_ATTRIBUTE", image: passedSCP.objclass?.toImage() ?? "euclid-icon")
            }
            
            Button(role: .destructive) {
                con.deleteArticleEntity(id: passedSCP.id)
                disabled = true
            } label: {
                Label("DELETE", systemImage: "trash")
            }
        } preview: {
            NavigationStack { RAISAText(article: passedSCP) }
        }
        .disabled(disabled)
        .swipeActions(allowsFullSwipe: false) {
            Button(role: .destructive) {
                con.deleteArticleEntity(id: passedSCP.id)
            } label: { Image(systemName: "trash") }
        }
        .sheet(isPresented: $showUpdateView, onDismiss: {
            if let articleitem = con.getArticleByID(id: passedSCP.id), let article = Article(fromEntity: articleitem) {
                passedSCP = article
            }
        }) {
            UpdateAttributeView(article: passedSCP)
        }
        .fullScreenCover(isPresented: $showArticle, onDismiss: {
            if let articleitem = con.getArticleByID(id: passedSCP.id), let article = Article(fromEntity: articleitem) {
                passedSCP = article
            } else {
                disabled = true
            }
        }) {
            NavigationStack { ArticleView(scp: passedSCP) }
        }
        .sheet(isPresented: $showListAddView) {
            ListAdd(isPresented: $showListAddView, article: passedSCP)
        }
        .task {
            if flavorText == nil {
                flavorText = {
                    if passedSCP.currenttext != nil { return FilterToPure(doc: passedSCP.currenttext!) }
                    if let description = passedSCP.pagesource.slice(from: "**Description:**", to: "\n") { return FilterToPure(doc: description) }
                    
                    let list = passedSCP.pagesource.components(separatedBy: .newlines)
                    let half = list[(Int(list.count) / 2)..<list.count].joined(separator: "\n")
                    let firstLine = half.slice(from: list.first ?? "", to: "\n")
                    return FilterToPure(doc: firstLine ?? half)
                }()
            }
            
            if passedSCP.objclass == .unknown {
                // MARK: Article Scanning
                raisaGetTags(url: passedSCP.url) { tags in
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
        .id(passedSCP.id)
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
