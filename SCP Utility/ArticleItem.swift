//
//  ArticleItem.swift
//  SCP Wiki Utility
//
//  Created by Maximus Harding on 12/30/22.
//

/*
 Structure that defines how an article appears in a menu
 */
import Foundation
import SwiftSoup

struct ArticleDefiner: Identifiable {
    var id: ObjectIdentifier
    
    var objclass: String // aka containment class
    var esoteric: String // aka secondary
    var clearance: String
    var disruption: String
    var risk: String
    
    var articlelink: String
    var storeddocument: Document
}

var scpxxx: ArticleDefiner = (ArticleDefiner(id: "scpxxx", objclass: "Keter", esoteric: "na", clearance: "2", disruption: "Amida", risk: "Critical", articlelink: "google.com", storeddocument: ""))// test variable

