//
//  ArticleItem.swift
//  SCP Wiki Utility
//
//  Created by Maximus Harding on 12/30/22.
//

import Foundation
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
                Text(passedSCP.title)
                    .foregroundColor(.primary)
                    .lineLimit(1)
                if con.completionStatus(article: passedSCP) {
                    Image(systemName: "checkmark")
                        .foregroundColor(.accentColor)
                }
                Spacer()
                #if os(iOS)
                ZStack {
                    Menu {
                        ForEach(EsotericClass.allCases, id: \.self) { eso in
                            Button {
                                con.updateEsotericClass(articleid: passedSCP.id, newattr: eso)
                                passedSCP.esoteric = eso
                            } label: {
                                Label(eso.toLocalString(), image: eso.toImage())
                            }
                        }
                    } label: {
                        if let im = passedSCP.esoteric?.toImage() {
                            if passedSCP.objclass == .esoteric {
                                Image(im)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 30, height: 30)
                            }
                        }
                    }
                }.disabled(!localArticle)
                ZStack {
                    Menu {
                        ForEach(ObjectClass.allCases, id: \.self) { obj in
                            Button {
                                con.updateObjectClass(articleid: passedSCP.id, newattr: obj)
                                passedSCP.objclass = obj
                            } label: {
                                Label(obj.toLocalString(), image: obj.toImage())
                            }
                        }
                    } label: {
                        if let im = passedSCP.objclass?.toImage() {
                            Image(im)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 30, height: 30)
                        }
                    }
                }.disabled(!localArticle)
                #endif
                
                if !localArticle {
                    Button {} label: {
                        if passedSCP.isSaved() || bookmarkStatus == true {
                            Image(systemName: "bookmark.fill")
                                .onTapGesture { showSheet.toggle() }
                        } else {
                            Image(systemName: "bookmark")
                                .onTapGesture {
                                    con.createArticleEntity(article: passedSCP)
                                    bookmarkStatus = true
                                }
                        }
                    }
                }
            }
        }
        .contextMenu {
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
            if localArticle {
                // MARK: Article Scanning
                DispatchQueue.main.async {
                    let doc = passedSCP.pagesource.lowercased()
                    
                    if passedSCP.objclass == .safe {
                        var newObj: ObjectClass
                        if doc.contains("keter") { newObj = .keter }
                        else if doc.contains("euclid") { newObj = .euclid }
                        else if doc.contains("neutralized") { newObj = .neutralized }
                        else if doc.contains("pending") { newObj = .pending }
                        else if doc.contains("explained") { newObj = .explained }
                        else if doc.contains("safe") { newObj = .safe }
                        else { newObj = .esoteric }
                        passedSCP.updateAttribute(objectClass: newObj)
                    }
                    
                    if passedSCP.esoteric == .thaumiel {
                        var newEso: EsotericClass
                        if doc.contains("apollyon") { newEso = .apollyon }
                        else if doc.contains("archon") { newEso = .archon }
                        else if doc.contains("cernunnos") { newEso = .cernunnos }
                        else if doc.contains("decommissioned") { newEso = .decommissioned }
                        else if doc.contains("tiamat") { newEso = .tiamat }
                        else if doc.contains("ticonderoga") { newEso = .ticonderoga }
                        else if doc.contains("uncontained") { newEso = .uncontained }
                        else { newEso = .thaumiel }
                        passedSCP.updateAttribute(esotericClass: newEso)
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
