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
        let items = PersistenceController.shared.getAllLists()
        
        NavigationView {
            if items != nil {
                List(items!) { item in
                    var newItem = SCPList(fromEntity: item)
                    
                    if (newItem != nil) {
                        Button(newItem!.listid) {
                            newItem!.addContent(Article: article)
                            isPresented = false
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
