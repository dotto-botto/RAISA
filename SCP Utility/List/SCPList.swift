//
//  List.swift
//  SCP Utility
//
//  Created by Maximus Harding on 2/13/23.
//

import SwiftUI
import Foundation
import CoreData

struct SCPList: Identifiable, Sequence, IteratorProtocol, Codable {
    
    let id: String
    var listid: String
    var contents: [String]? // article id's

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

    mutating func addContent(Article article: Article) {
        if self.contents != nil {
            self.contents!.append(article.id)
        } else {
            self.contents = [article.id]
        }
        PersistenceController.shared.addArticleToListFromId(listid: self.listid, article: article)
        PersistenceController.shared.createArticleEntity(article: article)
    }
}
