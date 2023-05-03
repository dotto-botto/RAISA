//
//  ListRow.swift
//  SCP Utility
//
//  Created by Maximus Harding on 5/3/23.
//

import SwiftUI

struct ListRow: View {
    @State var list: SCPList
    @State private var listTitlePresent: Bool = false
    @State private var listSubtitlePresent: Bool = false
    @State private var query: String = ""
    let con = PersistenceController.shared
    
    /// Init from a stored SCPList.
    init(list: SCPList) {
        self.list = list
    }
    
    init?(fromEntity entity: SCPListItem) {
        guard let list = SCPList(fromEntity: entity) else { return nil }
        self.list = list
    }
    
    var body: some View {
        NavigationLink(destination: OneListView(list: list)) {
            HStack {
                VStack(alignment: .leading) {
                    Text(list.listid)
                        .lineLimit(1)
                    if list.subtitle != nil {
                        Text(list.subtitle!)
                            .foregroundColor(.gray)
                            .font(.system(size: 13))
                            .lineLimit(1)
                    } else {
                        Text("SUBTITLE_PLACEHOLDER")
                            .foregroundColor(.gray)
                            .font(.system(size: 13))
                            .lineLimit(1)
                    }
                }
                Spacer()
                Image(systemName: "arrow.down.circle.fill").foregroundColor(.accentColor)
            }
        }
        .swipeActions(allowsFullSwipe: false) {
            Button(role: .destructive) {
                list.deleteEntity()
            } label: { Image(systemName: "trash") }
        }
        .contextMenu {
            Button {
                listTitlePresent = true
            } label: {
                Label("CHANGE_LIST_TITLE", systemImage: "pencil")
            }
            Button {
                listSubtitlePresent = true
            } label: {
                Label("CHANGE_LIST_SUBTITLE", systemImage: "pencil.line")
            }
        }
        .alert("CHANGE_LIST_TITLE", isPresented: $listTitlePresent) {
            TextField(list.listid, text: $query)
            
            Button("CHANGE") {
                list.updateTitle(newTitle: query)
                listTitlePresent = false
                query = ""
            }
            Button("CANCEL", role: .cancel) {
                listTitlePresent = false
                query = ""
            }
        }
        .alert("CHANGE_LIST_SUBTITLE", isPresented: $listSubtitlePresent) {
            TextField(list.subtitle ?? "", text: $query)
            
            Button("CHANGE") {
                list.updateSubtitle(newTitle: query)
                listSubtitlePresent = false
                query = ""
            }
            Button("CANCEL", role: .cancel) {
                listSubtitlePresent = false
                query = ""
            }
        }
    }
}

struct ListRow_Previews: PreviewProvider {
    static var previews: some View {
        ListRow(list: SCPList(listid: "The Best SCP's"))
    }
}
