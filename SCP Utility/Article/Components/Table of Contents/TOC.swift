//
//  TOC.swift
//  SCP Utility
//
//  Created by Maximus Harding on 11/23/24.
//

import Foundation

/// Defines tables of contents on articles.
///    Headers are all raw text.
struct TOC {
    let headers: [String]
    let title: String? = nil
    
    init(headers: [String]) {
        self.headers = headers
    }
    
    init(fromArticle article: Article) {
        var headers: [String] = []
        for match in matches(for: #"^\++\s.+$"#, in: article.pagesource, option: .anchorsMatchLines) {
            headers.append(match)
        }
        self.headers = headers
    }
}

// SCP-4231
let placeHolderTOC = TOC(headers: ["+ Meat", "+ Chapter excerpt from the textbook \"Reality Altering Beings: Socioeconomics, Mental Illness, and Diagnostic Criteria\" published 2014", "+ Frog in a Boiling Pot"])
