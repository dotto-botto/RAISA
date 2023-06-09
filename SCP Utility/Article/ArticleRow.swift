//
//  ArticleItem.swift
//  SCP Wiki Utility
//
//  Created by Maximus Harding on 12/30/22.
//

import SwiftUI
import MarkdownUI

/// The main view used to display articles that are saved by the user.
/// Meant to be used inside of a List or a VStack.
struct ArticleRow: View {
    @State var passedSCP: Article
    @State var open: Int = UserDefaults.standard.integer(forKey: "defaultOpen")
    @State private var flavorText: String? = nil
    @State private var showArticle: Bool = false // article view
    @State private var showUpdateView: Bool = false
    @State private var showListAddView: Bool = false
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
                        Image(systemName: "arrow.down.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 15, height: 14)
                        
                        Text(passedSCP.findLanguage()?.toAbbr() ?? RAISALanguage.english.toAbbr())
                        
                        Markdown(flavorText ?? "")
                            .lineLimit(1)
                            .markdownTextStyle(\.text) {
                                FontFamilyVariant(.normal)
                                FontSize(.em(0.5))
                                ForegroundColor(.secondary)
                            }
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
                showListAddView = true
            } label: {
                Label("LISTADDVIEW_TITLE", systemImage: "bookmark")
            }
            
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
        } preview: {
            NavigationStack { RAISAText(article: passedSCP) }
        }
        .swipeActions(allowsFullSwipe: false) {
            Button(role: .destructive) {
                con.deleteArticleEntity(id: passedSCP.id)
            } label: { Image(systemName: "trash") }
        }
        .sheet(isPresented: $showUpdateView) {
            UpdateAttributeView(article: passedSCP)
        }
        .fullScreenCover(isPresented: $showArticle, onDismiss: {
            if let articleitem = con.getArticleByID(id: passedSCP.id), let article = Article(fromEntity: articleitem) {
                passedSCP = article
            }
        }) {
            NavigationStack { ArticleView(scp: passedSCP) }
        }
        .sheet(isPresented: $showListAddView) {
            ListAdd(isPresented: $showListAddView, article: passedSCP)
        }
        .onAppear {
            if flavorText == nil && passedSCP.currenttext == nil {
                let list = passedSCP.pagesource.components(separatedBy: .newlines)
                let middleIndex = Int(list.count / 2)
                let secondHalf = list[middleIndex..<list.count].joined(separator: " ")
                
                FilterToMarkdown(doc: secondHalf) { doc in
                    flavorText = doc.trimmingCharacters(in: .whitespaces)
                }
            } else if passedSCP.currenttext != nil {
                flavorText = passedSCP.currenttext!
            }
            
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
