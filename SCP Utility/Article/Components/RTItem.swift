//
//  RTItem.swift
//  SCP Utility
//
//  Created by Maximus Harding on 5/31/23.
//

import SwiftUI
import MarkdownUI

enum RTItem: Hashable {
    case text(_ raw: String)
    case acs(_ raw: String) // anomaly class bar or any of its variants
    case tabview(_ raw: String)
    case collapsible(_ raw: String)
    case image(_ raw: String) // any component that is used to display an image
    case table(_ raw: String) // "[[table" or "||"
    case inlinebuton(_ raw: String)
    
    func toCorrespondingView(article: Article) -> AnyView {
        switch self {
        case .text(let str):
            return AnyView(Markdown(str)
                .id(str)
                .contextMenu {
                    Button {
                        PersistenceController.shared.setScroll(text: str, articleid: article.id)
                    } label: {
                        Label("SAVE_POSITION_PROMPT", systemImage: "bookmark")
                    }
                })
        case .acs(let str):
            return AnyView(ACSView(component: str))
        case .tabview(let str):
            return AnyView(TabViewComponent(article: article, text: str))
        case .collapsible(let str):
            return AnyView(Collapsible(article: article, text: str))
        case .image(let str):
            return AnyView(ArticleImage(article: article, content: str))
        case .table(let str):
            return AnyView(ArticleTable(article: article, doc: str))
        case .inlinebuton(let str):
            return AnyView(InlineButton(article: article, content: str))
        }
    }
}

