//
//  ArticleTabView.swift
//  SCP Utility
//
//  Created by Maximus Harding on 4/22/23.
//

import SwiftUI

struct ArticleTabView: View {
    @State private var selectedID: String = ""
    @Environment(\.dismiss) var dismiss

    @AppStorage("articleBarIds") var barIDS = ""
    let con = PersistenceController.shared
    var body: some View {
        let ids = barIDS.components(separatedBy: .whitespaces)
        VStack {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(ids, id: \.self) { id in
                        VStack {
                            if let articleItem = con.getArticleByID(id: id) {
                                let article = Article(fromEntity: articleItem)!
                                Text(article.title)
                                    .lineLimit(1)
                                    .foregroundColor(.accentColor)
                            }
                        }
                        .id(id)
                        .onTapGesture { selectedID = id }
                    }
                }
            }
            if let articleItem = con.getArticleByID(id: selectedID) {
                NavigationStack { ArticleView(scp: Article(fromEntity: articleItem)!) }
            } else {
                VStack {
                    Spacer()
                    Text("Select an Article")
                        .foregroundColor(.gray)
                        .font(.largeTitle)
                        .lineLimit(1)
                        .padding(.bottom)
                    Spacer()
                }
            }
        }
    }
}

struct ArticleTabView_Previews: PreviewProvider {
    static var previews: some View {
        ArticleTabView()
    }
}
