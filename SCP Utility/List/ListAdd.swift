//
//  ListAdd.swift
//  SCP Utility
//
//  Created by Maximus Harding on 3/5/23.
//

import SwiftUI
import Foundation

struct ListAdd: View {
    @Binding var isPresented: Bool
    @State var article: Article
    @State private var items = PersistenceController.shared.getAllLists()
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
            }
        }
    }
}

//struct ListAdd_Previews: PreviewProvider {
//    static var previews: some View {
//        ListAdd()
//    }
//}
