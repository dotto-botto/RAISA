//
//  List.swift
//  SCP Utility
//
//  Created by Maximus Harding on 2/13/23.
//

import SwiftUI
import Foundation
import CoreData

fileprivate let con = PersistenceController.shared
struct SCPList: Identifiable, Sequence, IteratorProtocol, Codable {
    let id: String
    var listid: String
    var contents: [String]? // article id's
    var subtitle: String?

    init(id: String = UUID().uuidString, listid: String) {
        self.id = id
        self.listid = listid
    }

    /// Create instance from core data entity.
    init?(fromEntity entity: SCPListItem) {
        guard let entityid = entity.identifier else { return nil }
        guard let entitylistid = entity.listid else { return nil }

        self.id = entityid
        self.listid = entitylistid
        self.contents = entity.contents
        self.subtitle = entity.subtitle
    }

    mutating func next() -> Int? {
        var count: Int = 0
        if count == 0 {
            return nil
        } else {
            do { count -= 1 }
            return count
        }
    }

    mutating func addContent(article: Article) {
        if self.contents != nil {
            self.contents!.append(article.id)
        } else {
            self.contents = [article.id]
        }
        
        if !(con.isArticleSaved(id: article.id) ?? false) {
            con.createArticleEntity(article: article)
        }
        con.addArticleToListFromId(listid: self.listid, article: article)
    }
}
