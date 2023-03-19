//
//  Article.swift
//  SCP Utility
//
//  Created by Maximus Harding on 3/5/23.
//

import Foundation

struct Article: Identifiable, Codable {
    let id: String
    
    let title: String
    let pagesource: String
    var thumbnail: URL? = nil
    var currenttext: String? = nil
    
    var objclass: ObjectClass? = nil
    var esoteric: EsotericClass? = nil// aka secondary
    var clearance: String? = nil
    var disruption: DisruptionClass? = nil
    var risk: RiskClass? = nil
    
    init(
        title: String,
        pagesource: String,
        thumbnail: URL? = nil
    ) {
        self.id = UUID().uuidString
        self.title = title
        self.pagesource = pagesource
        self.thumbnail = thumbnail ?? nil
    }
    
    /// Create an article from core data object.
    init?(fromEntity entity: ArticleItem) {
        guard let id = entity.identifier else { return nil }
        guard let entityTitle = entity.title else { return nil }
        guard let entityPagesource = entity.pagesource else { return nil }
        
        self.id = id
        self.title = entityTitle
        self.pagesource = entityPagesource
        self.thumbnail = entity.thumbnail
        self.currenttext = entity.currenttext
        self.objclass = ObjectClass(rawValue: entity.objclass)
        self.esoteric = EsotericClass(rawValue: entity.esoteric)
        self.clearance = entity.clearance
        self.disruption = DisruptionClass(rawValue: entity.disruption)
        self.risk = RiskClass(rawValue: entity.risk)
    }
    
    /// Update the specified attribute.
    mutating func updateAttribute(objectClass: ObjectClass) {
        self.objclass = objectClass
    }
    
    /// Update the specified attribute.
    mutating func updateAttribute(esotericClass: EsotericClass) {
        self.esoteric = esotericClass
    }
    
    /// Update the specified attribute.
    mutating func updateAttribute(disruptionClass: DisruptionClass) {
        self.disruption = disruptionClass
    }
    
    /// Update the specified attribute.
    mutating func updateAttribute(riskClass: RiskClass) {
        self.risk = riskClass
    }
    
    /// Update the specified attribute.
    mutating func updateAttribute(clearance: String) {
        self.clearance = clearance
    }
}

// MARK: - Atribute Enums
enum ObjectClass: Int16, Codable {
    case safe = 0
    case euclid = 1
    case keter = 2
    case neutralized = 3
    case pending = 4
    case explained = 5
    case esoteric = 6
    
    /// Return a string of the corresponding image.
    func toImage() -> String {
        switch self {
        case .safe: return "safe-icon"
        case .euclid: return "euclid-icon"
        case .keter: return "keter-icon"
        case .neutralized: return "neutralized-icon"
        case .pending: return "pending-icon"
        case .explained: return "explained-icon"
        case .esoteric: return "esoteric-icon"
        }
    }
}

enum EsotericClass: Int16, Codable, CaseIterable {
    case apollyon = 0
    case archon = 1
    case cernunnos = 2
    case decommissioned = 3
    case hiemal = 4
    case tiamat = 5
    case ticonderoga = 6
    case thaumiel = 7
    case uncontained = 8
    
    /// Return a string of the corresponding image.
    func toImage() -> String {
        switch self {
        case .apollyon: return "apollyon-icon"
        case .archon: return "archon-icon"
        case .cernunnos: return "cernunnos-icon"
        case .decommissioned: return "decommissioned-icon"
        case .hiemal: return "hiemal-icon"
        case .tiamat: return "tiamat-icon"
        case .ticonderoga: return "ticonderoga-icon"
        case .thaumiel: return "thaumiel-icon"
        case .uncontained: return "uncontained-icon"
        }
    }
}

enum DisruptionClass: Int16, Codable {
    case dark = 0
    case vlam = 1
    case keneq = 2
    case ekhi = 3
    case amida = 4
    
    /// Return a string of the corresponding image.
    func toImage() -> String {
        switch self {
        case .dark: return "dark-icon"
        case .vlam: return "vlam-icon"
        case .keneq: return "keneq-icon"
        case .ekhi: return "ekhi-icon"
        case .amida: return "amida-icon"
        }
    }
}

enum RiskClass: Int16, Codable {
    case notice = 0
    case caution = 1
    case warning = 2
    case danger = 3
    case critical = 4
    
    /// Return a string of the corresponding image.
    func toImage() -> String {
        switch self {
        case .notice: return "notice-icon"
        case .caution: return "caution-icon"
        case .warning: return "warning-icon"
        case .danger: return "danger-icon"
        case .critical: return "critical-icon"
        }
    }
}
