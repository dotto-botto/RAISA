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
    @State private var items = PersistenceController.shared.getAllLists()
    
    @State private var alertPresent: Bool = false
    @State private var query: String = ""
    @State private var showConf: Bool = false
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        let con = PersistenceController.shared
        
        NavigationStack {
            if items != nil {
                List(items!) { item in
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
                            con.createArticleEntity(article: article)
                            article.downloadImages()
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
                    TextField("", text: $query)
                    
                    Button("ADD") {
                        con.createListEntity(list: SCPList(listid: query))
                        items = con.getAllLists()
                        alertPresent = false
                        query = ""
                    }
                    Button("CANCEL", role: .cancel) {
                        alertPresent = false
                        query = ""
                    }
                }
                .disabled(article.url.formatted() == placeHolderArticle.url.formatted() && article.title == placeHolderArticle.title)
            }
        }
    }
}

struct ListAdd_Previews: PreviewProvider {
    static var previews: some View {
        ListAdd(isPresented: .constant(true), article: placeHolderArticle)
    }
}
