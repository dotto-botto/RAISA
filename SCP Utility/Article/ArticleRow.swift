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
    
    var body: some View {
        let con = PersistenceController.shared
        let defaults = UserDefaults.standard
        
        Button(action: {
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
                showArticle = true
            }
        }) {
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
                            } label: {
                                Label(eso.toLocalString(), image: eso.toImage())
                            }
                        }
                    } label: {
                        if let im = passedSCP.esoteric?.toImage() {
                            Image(im)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 30, height: 30)
                        }
                    }
                }.disabled(!localArticle)
                ZStack {
                    Menu {
                        ForEach(ObjectClass.allCases, id: \.self) { obj in
                            Button {
                                con.updateObjectClass(articleid: passedSCP.id, newattr: obj)
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
                    Image(systemName: "bookmark")
                        .onTapGesture { showSheet = true }
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
            Button(role: .destructive) {
                con.deleteArticleEntity(id: passedSCP.id)
            } label: { Image(systemName: "trash") }
            Button {
                
            } label: { Image(systemName: "ellipsis.circle") }
        }
        .sheet(isPresented: $showSheet) {
            ListAdd(isPresented: $showSheet, article: passedSCP)
        }
        .fullScreenCover(isPresented: $showArticle) {
            NavigationView { ArticleView(scp: passedSCP) }
        }
    }
}

struct ArticleRow_Previews: PreviewProvider {
    static var previews: some View {
        ArticleRow(passedSCP: Article(
            title: "Tufto's Proposal",
            pagesource: "",
            objclass: .keter,
            esoteric: .thaumiel,
            disruption: .amida,
            risk: .danger
        ), localArticle: true).previewDisplayName("Local")
        ArticleRow(passedSCP: Article(
            title: "Article with a extremely long title that could definitely break things if it is not accounted for!",
            pagesource: "",
            objclass: .keter,
            esoteric: .thaumiel,
            disruption: .amida,
            risk: .danger
        ), localArticle: false).previewDisplayName("Online")
    }
}
