//
//  List.swift
//  SCP Utility
//
//  Created by Maximus Harding on 2/13/23.
//

import Foundation

fileprivate let con = PersistenceController.shared
/// Struct that defines a list of article id's.
/// Includes a title and an optional subtitle.
struct SCPList: Identifiable {
    let id: String
    var listid: String
    var contents: [String]? // article id's
    var subtitle: String?
    
    /// init with every saved article.
    init() {
        self.id = "ALL_SAVED_ARTICLES"
        self.listid = String(localized: "ALL_SAVED_ARTICLES")
        self.contents = con.getAllArticles()?
            .compactMap { Article(fromEntity: $0) }
            .map { $0.id } ?? []
    }

    init(id: String = UUID().uuidString, listid: String, subtitle: String? = nil) {
        self.id = id
        self.listid = listid
        self.subtitle = subtitle
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

    mutating func addContent(article: Article) {
        // Check for duplicate id's
        guard (self.contents ?? []).filter({ $0 == article.id }).isEmpty else { return }
        
        if self.contents != nil {
            self.contents!.append(article.id)
        } else {
            self.contents = [article.id]
        }
        
        if !(con.isArticleSaved(id: article.id) ?? false) {
            con.createArticleEntity(article: article)
            article.downloadImages()
        }
        con.addArticleToListFromId(listid: self.listid, article: article)
    }
    
    /// Remove an id from a list without deleting the article
    mutating func removeContent(id: String) {
        guard !(self.contents?.isEmpty ?? true) else { return }
        
        let newContents = self.contents?.filter { $0 != id }
        self.contents = newContents
        con.removeIdFromList(listIdentifier: self.id, idToRemove: id)
    }
    
    mutating func updateTitle(newTitle: String) {
        self.listid = newTitle
        con.updateListTitle(newTitle: newTitle, list: self)
    }
    
    mutating func updateSubtitle(newTitle: String) {
        self.subtitle = newTitle
        con.updateListSubtitle(newTitle: newTitle, list: self)
    }
    
    func deleteEntity() {
        con.deleteListEntity(listitem: self)
    }
}
