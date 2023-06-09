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
                    Button {
                        alertPresent = true
                    } label: {
                        Image(systemName: "plus")
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
            }
        }
    }
}

struct ListAdd_Previews: PreviewProvider {
    static var previews: some View {
        ListAdd(isPresented: .constant(true), article: placeHolderArticle)
    }
}
