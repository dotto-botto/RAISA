//
//  HistoryItem.swift
//  SCP Utility
//
//  Created by Maximus Harding on 3/9/23.
//

import Foundation

/// Struct that defines a users history.
struct History: Identifiable, Codable {
    let id: String
    
    let date: Date
    let articletitle: String
    var thumbnail: URL? = nil
    
    init(title: String, thumbnail: URL? = nil) {
        self.id = UUID().uuidString
        self.date = Date()
        self.articletitle = title
        self.thumbnail = thumbnail
    }
    
    init?(fromEntity entity: HistoryItem) {
        guard let id = entity.identifier else { return nil }
        guard let title = entity.articletitle else { return nil }
        guard let date = entity.date else { return nil }
        
        self.id = id
        self.date = date
        self.articletitle = title
        self.thumbnail = entity.thumbnail
    }
}
