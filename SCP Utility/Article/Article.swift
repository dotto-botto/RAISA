//
//  Article.swift
//  SCP Utility
//
//  Created by Maximus Harding on 3/5/23.
//

import Foundation

fileprivate let con = PersistenceController.shared
let placeholderURL: URL = URL(string: "https://scp-wiki.wikidot.com/")!
struct Article: Identifiable, Codable {
    let id: String
    
    let title: String
    var pagesource: String
    var url: URL
    var thumbnail: URL? = nil
    var currenttext: String? = nil
    var completed: Bool? = false
    
    var objclass: ObjectClass? = .unknown
    var esoteric: EsotericClass? = .unknown// aka secondary
    var clearance: String? = nil
    var disruption: DisruptionClass? = .unknown
    var risk: RiskClass? = .unknown
    
    init(
        title: String,
        pagesource: String,
        url: URL,
        thumbnail: URL? = nil,
        
        objclass: ObjectClass? = .unknown,
        esoteric: EsotericClass? = .unknown,
        clearance: String? = nil,
        disruption: DisruptionClass? = .unknown,
        risk: RiskClass? = .unknown
    ) {
        self.id = UUID().uuidString
        self.title = title
        self.pagesource = pagesource
        self.url = url
        self.thumbnail = thumbnail ?? nil
        
        self.objclass = objclass ?? .unknown
        self.esoteric = esoteric ?? .unknown
        self.clearance = clearance ?? nil
        self.disruption = disruption ?? .unknown
        self.risk = risk ?? .unknown
    }
    
    /// Create an article from core data object.
    init?(fromEntity entity: ArticleItem) {
        guard let id = entity.identifier else { return nil }
        guard let entityTitle = entity.title else { return nil }
        guard let entityPagesource = entity.pagesource else { return nil }
        
        self.id = id
        self.title = entityTitle
        self.pagesource = entityPagesource
        self.url = entity.url ?? placeholderURL // backwards compatability
        self.thumbnail = entity.thumbnail
        self.currenttext = entity.currenttext
        self.completed = entity.completed
        self.objclass = ObjectClass(rawValue: entity.objclass)
        self.esoteric = EsotericClass(rawValue: entity.esoteric)
        self.clearance = entity.clearance
        self.disruption = DisruptionClass(rawValue: entity.disruption)
        self.risk = RiskClass(rawValue: entity.risk)
    }
    
    /// Update the specified attribute.
    mutating func updateAttribute(objectClass: ObjectClass) {
        self.objclass = objectClass
        con.updateObjectClass(articleid: self.id, newattr: objectClass)
    }
    
    /// Update the specified attribute.
    mutating func updateAttribute(esotericClass: EsotericClass) {
        self.esoteric = esotericClass
        con.updateEsotericClass(articleid: self.id, newattr: esotericClass)
    }
    
    /// Update the specified attribute.
    mutating func updateAttribute(disruptionClass: DisruptionClass) {
        self.disruption = disruptionClass
        con.updateDisruptionClass(articleid: self.id, newattr: disruptionClass)
    }
    
    /// Update the specified attribute.
    mutating func updateAttribute(riskClass: RiskClass) {
        self.risk = riskClass
        con.updateRiskClass(articleid: self.id, newattr: riskClass)
    }
    
    /// Update the specified attribute.
    mutating func updateAttribute(clearance: String) {
        self.clearance = clearance
    }
    
    /// Sets scroll variable of article to given string.
    /// - Parameter text: The text to set the current text to.
    mutating func setScroll(_ text: String) {
        self.currenttext = text
        con.setScroll(text: text, articleid: self.id)
    }
    
    /// Updates sources without saving it to core data.
    mutating func updateSource(_ text: String) {
        self.pagesource = text
    }
    
    func isSaved() -> Bool {
        return con.isArticleSaved(url: self.url) ?? false
    }
}

// MARK: - Atribute Enums
enum ObjectClass: Int16, Codable, CaseIterable {
    case safe = 0
    case euclid = 1
    case keter = 2
    case neutralized = 3
    case pending = 4
    case explained = 5
    case esoteric = 6
    case unknown = 7
    
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
        case .unknown: return ""
        }
    }
    
    func toLocalString() -> String {
        switch self {
        case .safe: return NSLocalizedString("SAFE", comment: "")
        case .euclid: return NSLocalizedString("EUCLID", comment: "")
        case .keter: return NSLocalizedString("KETER", comment: "")
        case .neutralized: return NSLocalizedString("NEUTRALIZED", comment: "")
        case .pending: return NSLocalizedString("PENDING", comment: "")
        case .explained: return NSLocalizedString("EXPLAINED", comment: "")
        case .esoteric: return NSLocalizedString("ESOTERIC", comment: "")
        case .unknown: return ""
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
    case unknown = 9
    
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
        case .unknown: return ""
        }
    }
    
    func toLocalString() -> String {
        switch self {
        case .apollyon: return NSLocalizedString("APOLLYON", comment: "")
        case .archon: return NSLocalizedString("ARCHON", comment: "")
        case .cernunnos: return NSLocalizedString("CERNUNNOS", comment: "")
        case .decommissioned: return NSLocalizedString("DECOMMISSIONED", comment: "")
        case .hiemal: return NSLocalizedString("HIEMAL", comment: "")
        case .tiamat: return NSLocalizedString("TIAMAT", comment: "")
        case .ticonderoga: return NSLocalizedString("TICONDEROGA", comment: "")
        case .thaumiel: return NSLocalizedString("THAUMIEL", comment: "")
        case .uncontained: return NSLocalizedString("UNCONTAINED", comment: "")
        case .unknown: return ""
        }
    }
}

enum DisruptionClass: Int16, Codable, CaseIterable {
    case dark = 0
    case vlam = 1
    case keneq = 2
    case ekhi = 3
    case amida = 4
    case unknown = 5
    
    /// Return a string of the corresponding image.
    func toImage() -> String {
        switch self {
        case .dark: return "dark-icon"
        case .vlam: return "vlam-icon"
        case .keneq: return "keneq-icon"
        case .ekhi: return "ekhi-icon"
        case .amida: return "amida-icon"
        case .unknown: return ""
        }
    }
    
    func toLocalString() -> String {
        switch self {
        case .dark: return NSLocalizedString("DARK", comment: "")
        case .vlam: return NSLocalizedString("VLAM", comment: "")
        case .keneq: return NSLocalizedString("KENEQ", comment: "")
        case .ekhi: return NSLocalizedString("EKHI", comment: "")
        case .amida: return NSLocalizedString("AMIDA", comment: "")
        case .unknown: return ""
        }
    }
}

enum RiskClass: Int16, Codable, CaseIterable {
    case notice = 0
    case caution = 1
    case warning = 2
    case danger = 3
    case critical = 4
    case unknown = 5
    
    /// Return a string of the corresponding image.
    func toImage() -> String {
        switch self {
        case .notice: return "notice-icon"
        case .caution: return "caution-icon"
        case .warning: return "warning-icon"
        case .danger: return "danger-icon"
        case .critical: return "critical-icon"
        case .unknown: return ""
        }
    }
    
    func toLocalString() -> String {
        switch self {
        case .notice: return NSLocalizedString("NOTICE", comment: "")
        case .caution: return NSLocalizedString("CAUTION", comment: "")
        case .warning: return NSLocalizedString("WARNING", comment: "")
        case .danger: return NSLocalizedString("DANGER", comment: "")
        case .critical: return NSLocalizedString("CRITICAL", comment: "")
        case .unknown: return ""
        }
    }
}
