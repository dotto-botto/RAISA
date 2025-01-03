//
//  ListAdd.swift
//  SCP Utility
//
//  Created by Maximus Harding on 3/5/23.
//

import SwiftUI
import Foundation

/// View that allows a user to add an article to an SCPList.
struct ListAdd: View {
    @Binding var isPresented: Bool
    @State var article: Article
    @State private var items = PersistenceController.shared.getAllLists() ?? []
    
    @State private var alertPresent: Bool = false
    @State private var query: String = ""
    @State private var subtitleQuery: String = ""
    @State private var showConf: Bool = false
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        let con = PersistenceController.shared
        
        NavigationStack {
            List(items) { item in
                if var newItem = SCPList(fromEntity: item) {
                    Button {
                        newItem.addContent(article: article)
                        isPresented = false
                    } label: {
                        HStack {
                            if con.isIdInList(listid: newItem.id, articleid: article.id) {
                                Image(systemName: "checkmark").foregroundColor(.accentColor)
                            }
                            
                            ListRow(list: newItem)
                        }
                    }
                }
            }
            .listStyle(.plain)
            .navigationTitle("LISTADDVIEW_TITLE")
            .overlay {
                if items.isEmpty {
                    Text("NEW_LIST_PROMPT")
                        .foregroundColor(.secondary)
                }
            }
            .toolbar {
                ToolbarItemGroup(placement: .bottomBar) {
                    Button("DELETE") {
                        showConf = true
                    }
                    .confirmationDialog("LAV_DELETE_\(article.title)", isPresented: $showConf) {
                        Button("LAV_DELETE_\(article.title)", role: .destructive) {
                            con.deleteArticleEntity(id: article.id)
                            dismiss()
                        }
                    }
                    
                    Button("LAV_SAVE_TO_LIBRARY") {
                        article.saveToDisk()
                        dismiss()
                    }
                    .disabled(con.isArticleSaved(url: article.url))
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        alertPresent = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .alert("ADD_LIST_PROMPT", isPresented: $alertPresent) {
                // Copied from ListView
                TextField("", text: $query, prompt: Text("TITLE"))
                TextField("", text: $subtitleQuery, prompt: Text("SUBTITLE"))
                
                Button("ADD") {
                    con.createListEntity(list: SCPList(listid: query.isEmpty ? String(localized: "DEAFULT_LIST_TITLE") : query, subtitle: subtitleQuery))
                    items = con.getAllLists() ?? []
                    alertPresent = false
                    query = ""
                    subtitleQuery = ""
                }
                Button("CANCEL", role: .cancel) {
                    alertPresent = false
                    query = ""
                    subtitleQuery = ""
                }
            }
            .disabled(article.url.formatted() == placeHolderArticle.url.formatted() && article.title == placeHolderArticle.title)
        }
    }
}

struct ListAdd_Previews: PreviewProvider {
    static var previews: some View {
        ListAdd(isPresented: .constant(true), article: placeHolderArticle)
    }
}
