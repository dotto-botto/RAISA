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
    @State var localArticle: Bool /// If the article comes from the core data store, or the Crom api
    var body: some View {
        let con = PersistenceController.shared

        NavigationLink(destination: ArticleView(scp: passedSCP)) {
            HStack {
                Text(passedSCP.title)
                    .lineLimit(1)
                if con.completionStatus(article: passedSCP) {
                    Image(systemName: "checkmark")
                        .foregroundColor(.accentColor)
                }
                Spacer()
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
                        Image(passedSCP.esoteric?.toImage() ?? "")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 30, height: 30)
                    }
                }
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
                        Image(passedSCP.objclass?.toImage() ?? "")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 30, height: 30)
                    }
                }
            }
        }
        .contextMenu {
            Button(action: {
                con.complete(status: true, article: passedSCP)
            }, label: {
                Label("MARK_READ", systemImage: "eye")
            })
            Button(action: {
                con.complete(status: false, article: passedSCP)
            }, label: {
                Label("MARK_UNREAD", systemImage: "eye.slash")
            })
        }
        .swipeActions(allowsFullSwipe: false) {
            Button(role: .destructive) {
                con.deleteArticleEntity(articleitem: passedSCP)
            } label: { Image(systemName: "trash") }
            Button {
                
            } label: { Image(systemName: "ellipsis.circle") }
        }
        .disabled(!localArticle)
    }
}

struct ArticleRow_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
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
            ), localArticle: true).previewDisplayName("Online")
        }
    }
}
