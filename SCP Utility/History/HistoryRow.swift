//
//  HistoryRow.swift
//  SCP Utility
//
//  Created by Maximus Harding on 3/9/23.
//

import SwiftUI
import Kingfisher

struct HistoryRow: View {
    @State var item: History
    
    let defaults = UserDefaults.standard
    let con = PersistenceController.shared
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(item.articletitle)
                    .lineLimit(1)
                Text(item.date.formatted())
            }
            Spacer()
            if item.thumbnail != nil && defaults.bool(forKey: "showImages") {
                KFImage(item.thumbnail!)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 50, height: 50)
                    .clipped()
            }
        }
        .swipeActions(allowsFullSwipe: false) {
            Button(role: .destructive) {
                con.deleteHistoryFromId(id: item.id)
            } label: { Image(systemName: "trash") }
        }
    }
}

struct HistoryRow_Previews: PreviewProvider {
    static var previews: some View {
        HistoryRow(item: History(
            title: "SCP-3000",
            thumbnail: URL(string: "https://scp-wiki.wdfiles.com/local--files/scp-3000/gaslight.png")
        )
        )
    }
}
