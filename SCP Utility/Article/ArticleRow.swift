//
//  ArticleItem.swift
//  SCP Wiki Utility
//
//  Created by Maximus Harding on 12/30/22.
//

/*
 Structure that defines how an article appears in a menu
 */
import Foundation
import SwiftUI

struct ArticleRow: View {
    @State var passedSCP: Article
    @State var alertPresent: Bool = false
    @State var toArticle: Bool = false
    @State var localArticle: Bool /// If the article comes from the core data store, or the Crom api

    @State var esoSelection: EsotericClass?
    
    
    var body: some View {
        let con = PersistenceController.shared

        if toArticle {
            NavigationStack { ArticleView(scp: passedSCP) }
        }

        NavigationLink(destination: ArticleView(scp: passedSCP)) {
            HStack {
                Text(passedSCP.title)
                Spacer()
                ZStack {
                    Image(passedSCP.esoteric?.toImage() ?? "")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 30, height: 30)
                        .contextMenu {
                            
                        }.disabled(!localArticle)
                }
                ZStack {
                    Image(passedSCP.objclass?.toImage() ?? "")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 30, height: 30)
                        .contextMenu {
                            
                        }
                }
            }
        }
        .swipeActions {
            Button(role: .destructive) {
                
            } label: { Image(systemName: "trash") }
            
            NavigationLink {
                Menu {
                    Button {
                        con.updateEsotericClass(articleid: passedSCP.id, newattr: .apollyon)
                    } label: { Label("APOLLYON", image: "apollyon-icon") }
                    Button {
                        con.updateEsotericClass(articleid: passedSCP.id, newattr: .archon)
                    } label: { Label("ARCHON", image: "archon-icon") }
                    Button {
                        con.updateEsotericClass(articleid: passedSCP.id, newattr: .cernunnos)
                    } label: { Label("CERNUNNOS", image: "cernunnos-icon") }
                    Button {
                        con.updateEsotericClass(articleid: passedSCP.id, newattr: .decommissioned)
                    } label: { Label("DECOMMISSIONED", image: "decommissioned-icon") }
                    Button {
                        con.updateEsotericClass(articleid: passedSCP.id, newattr: .hiemal)
                    } label: { Label("HIEMAL", image: "hiemal-icon") }
                    Button {
                        con.updateEsotericClass(articleid: passedSCP.id, newattr: .tiamat)
                    } label: { Label("TIAMAT", image: "tiamat-icon") }
                    Button {
                        con.updateEsotericClass(articleid: passedSCP.id, newattr: .ticonderoga)
                    } label: { Label("TICONDEROGA", image: "ticonderoga-icon") }
                    Button {
                        con.updateEsotericClass(articleid: passedSCP.id, newattr: .thaumiel)
                    } label: { Label("THAUMIEL", image: "thaumiel-icon") }
                    Button {
                        con.updateEsotericClass(articleid: passedSCP.id, newattr: .uncontained)
                    } label: { Label("UNCONTAINED", image: "uncontained-icon") }
                } label: {}
            } label: { Image("esoteric-icon").colorInvert() }
        }
        .disabled(!localArticle)
    }
}

struct ArticleRow_Previews: PreviewProvider {
    static var previews: some View {
        ArticleRow(passedSCP: Article(title: "Tufto's Proposal", pagesource: ""), localArticle: true)
    }
}
