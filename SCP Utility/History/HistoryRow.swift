//
//  HistoryRow.swift
//  SCP Utility
//
//  Created by Maximus Harding on 3/9/23.
//

import SwiftUI
import Kingfisher

/// View that displays a history struct.
struct HistoryRow: View {
    @State var item: History
    @State private var associatedArticle: Article = placeHolderArticle
    @State private var gotCrom: Bool = false
    @State private var showSheet: Bool = false
    @State private var callingAPI: Bool = false
    
    let defaults = UserDefaults.standard
    let con = PersistenceController.shared
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(item.articletitle)
                    .lineLimit(1)
                Text(item.date.formatted())
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            if item.thumbnail != nil {
                KFImage(item.thumbnail!)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 50, height: 50)
                    .clipped()
            }
        }
        .onTapGesture {
            if !callingAPI {
                callingAPI = true
                cromGetSourceFromTitle(title: item.articletitle) { article in
                    associatedArticle = article
                    gotCrom = true
                    callingAPI = false
                }
            }
        }
        .onChange(of: gotCrom) { _ in
            showSheet = true
            gotCrom = false
        }
        .fullScreenCover(isPresented: $showSheet) {
            NavigationStack {
                ArticleView(scp: associatedArticle)
            }
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
