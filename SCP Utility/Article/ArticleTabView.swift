//
//  ArticleTabView.swift
//  SCP Utility
//
//  Created by Maximus Harding on 4/22/23.
//

import SwiftUI

/// View presented when ArticleBar is tapped, this is not the same as TabViewComponent, which is a reader component displayed in RAISAText.
/// Displays a switcher at the bottom which can be used to change the article displayed in the corresponding ArticleView.
struct ArticleTabView: View {
    @State var selectedID: String? = nil
    @Environment(\.dismiss) var dismiss
    @AppStorage("articleBarIds") var barIDS = ""
    let con = PersistenceController.shared
    var body: some View {
        let ids = barIDS.components(separatedBy: .whitespaces)
        VStack {
            ForEach(ids, id: \.self) { id in
                if id == selectedID {
                    if let articleItem = con.getArticleByID(id: selectedID!) {
                        ArticleView(scp: Article(fromEntity: articleItem)!)
                    }
                }
            }
            Spacer()
            HStack {
                Image(systemName: "chevron.left.2").foregroundColor(.secondary)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(ids, id: \.self) { id in
                            if let articleItem = con.getArticleByID(id: id) {
                                let article = Article(fromEntity: articleItem)!
                                Button(article.title) { selectedID = id }
                            }
                        }
                    }
                }
                Image(systemName: "chevron.right.2").foregroundColor(.secondary)
            }
        }
    }
}

struct ArticleTabView_Previews: PreviewProvider {
    static var previews: some View {
        ArticleTabView()
    }
}
