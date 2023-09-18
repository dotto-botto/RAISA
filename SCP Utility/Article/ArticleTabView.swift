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
    var body: some View {
        let articles: [Article] = (UserDefaults.standard.stringArray(forKey: "articleBarIds") ?? [])
            .compactMap {
                guard let item = PersistenceController.shared.getArticleByID(id: $0) else { return nil }
                return Article(fromEntity: item)
            }
        
        TabView {
            ForEach(articles) { article in
                ArticleView(scp: article)
                    .contentShape(Rectangle()).gesture(DragGesture())
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
        .indexViewStyle(.page(backgroundDisplayMode: .always))
    }
}

struct ArticleTabView_Previews: PreviewProvider {
    static var previews: some View {
        ArticleTabView()
    }
}
