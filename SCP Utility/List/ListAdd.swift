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
    
    var body: some View {
        let con = PersistenceController.shared
        let items = con.getAllLists()
        
        NavigationView {
            if items != nil {
                List(items!) { item in
                    var newItem = SCPList(fromEntity: item)
                    
                    if (newItem != nil) {
                        Button {
                            newItem!.addContent(Article: article)
                            isPresented = false
                        } label: {
                            if con.isIdInList(listid: newItem!.id, articleid: article.id) {
                                HStack {
                                    Text(newItem!.listid)
                                    Spacer()
                                    Image(systemName: "checkmark")
                                }
                            } else {
                                Text(newItem!.listid)
                            }
                        }

                    }
                    
                }
            }
        }
    }
}

//struct ListAdd_Previews: PreviewProvider {
//    static var previews: some View {
//        ListAdd()
//    }
//}
