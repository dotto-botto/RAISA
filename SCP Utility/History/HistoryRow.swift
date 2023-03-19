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
    var body: some View {
        HStack {
            VStack {
                Text(item.articletitle)
                Text(item.date.formatted())
            }
            Spacer()
            if item.thumbnail != nil { KFImage(item.thumbnail!) }
        }
    }
}

//struct HistoryRow_Previews: PreviewProvider {
//    static var previews: some View {
//        HistoryRow()
//    }
//}
