//
//  Article.swift
//  SCP Utility
//
//  Created by Maximus Harding on 3/5/23.
//

import SwiftUI

fileprivate let con = PersistenceController.shared
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
        self.objclass = ObjectClass(rawValue: entity.objclass) ?? ObjectClass.unknown
        self.esoteric = EsotericClass(rawValue: entity.esoteric) ?? EsotericClass.unknown
        self.clearance = entity.clearance
        self.disruption = DisruptionClass(rawValue: entity.disruption) ?? DisruptionClass.unknown
        self.risk = RiskClass(rawValue: entity.risk) ?? RiskClass.unknown
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
        return con.isArticleSaved(url: self.url)
    }
    
    /// Checks page source for unsupported components and returns the components.
    func findForbiddenComponents() -> [String]? {
        let forbidden: [String:String] = [
            "Fragments" : "category=\"fragment\"",
            "Audio Players": "[[include :snippets:html5player",
            "HTML": "[[html"
        ]
        
        var values: [String] = []
        for key in forbidden.keys {
            if self.pagesource.contains(forbidden[key]!) {
                values.append(key)
            }
        }
        if values == [] { return nil }
        else { return values }
    }
    
    /// Checks page source for content warnings and returns the warnings.
    /// https://scp-wiki.wikidot.com/component:adult-content-warning
    func findContentWarnings() -> [String]? {
        let forbidden: [String:String] = [
            "gore" : "|gore",
            "sexual references" : "|sexual-references=",
            "sexual content" : "|sexually-explicit=",
            "sexual assault" : "|sexual-assault=",
            "child abuse" : "|child-abuse=",
            "self harm" : "|self-harm=",
            "suicide" : "|suicide=",
            "torture" : "|torture=",
            "other content" : "|custom=",
        ]
        
        var values: [String] = []
        for key in forbidden.keys {
            if self.pagesource.contains(forbidden[key]!) {
                values.append(key)
            }
        }
        if values == [] { return nil }
        else { return values }
    }
}

/// Finds the next article using "currentTitle" as a query.
/// If "currentTitle" is not an SCP from the main series, (eg: SCP-173 or SCP-097, but not SCP-8900-EX), this returns nil.
func findNextArticle(currentTitle title: String, completion: @escaping (Article?) -> Void) {
    if var key = title.slice(from: "SCP-"), let num = Int(key) {
        key = String(num + 1)
        cromGetSourceFromTitle(title: key) { article in
            completion(article)
        }
    } else { completion(nil) }
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
    
    func getTooltip() -> String? {
        switch self {
        case .safe: return NSLocalizedString("SAFE_TOOLTIP", comment: "")
        case .euclid: return NSLocalizedString("EUCLID_TOOLTIP", comment: "")
        case .keter: return NSLocalizedString("KETER_TOOLTIP", comment: "")
        case .neutralized: return NSLocalizedString("NEUTRALIZED_TOOLTIP", comment: "")
        case .pending: return NSLocalizedString("PENDING_TOOLTIP", comment: "")
        case .explained: return NSLocalizedString("EXPLAINED_TOOLTIP", comment: "")
        case .esoteric: return NSLocalizedString("ESOTERIC_TOOLTIP", comment: "")
        case .unknown: return nil
        }
    }
    
    func toColor() -> Color {
        switch self {
        case .safe: return Color("Unrestricted Green")
        case .euclid: return Color("Confidential Yellow")
        case .keter: return Color("Top-Secret Red")
        case .neutralized: return Color("Declassified Gray")
        case .pending: return Color("Pending Black")
        case .explained: return Color("Pending Black")
        case .esoteric: return Color("Declassified Gray")
        case .unknown: return Color("Pending Black")
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
    
    func getTooltip() -> String? {
        switch self {
        case .apollyon: return NSLocalizedString("APOLLYON_TOOLTIP", comment: "")
        case .archon: return NSLocalizedString("ARCHON_TOOLTIP", comment: "")
        case .cernunnos: return NSLocalizedString("CERNUNNOS_TOOLTIP", comment: "")
        case .decommissioned: return NSLocalizedString("DECOMMISSIONED_TOOLTIP", comment: "")
        case .hiemal: return NSLocalizedString("HIEMAL_TOOLTIP", comment: "")
        case .tiamat: return NSLocalizedString("TIAMAT_TOOLTIP", comment: "")
        case .ticonderoga: return NSLocalizedString("TICONDEROGA_TOOLTIP", comment: "")
        case .thaumiel: return NSLocalizedString("THAUMIEL_TOOLTIP", comment: "")
        case .uncontained: return NSLocalizedString("UNCONTAINED_TOOLTIP", comment: "")
        case .unknown: return nil
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
    
    func toColor() -> Color {
        return Color("Declassified Gray")
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
    
    func toColor() -> Color {
        switch self {
        case .dark: return Color("Unrestricted Green")
        case .vlam: return Color("Restricted Blue")
        case .keneq: return Color("Confidential Yellow")
        case .ekhi: return Color("Secret Orange")
        case .amida: return Color("Top-Secret Red")
        case .unknown: return Color("Pending Black")
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
    
    func toColor() -> Color {
        switch self {
        case .notice: return Color("Unrestricted Green")
        case .caution: return Color("Restricted Blue")
        case .warning: return Color("Confidential Yellow")
        case .danger: return Color("Secret Orange")
        case .critical: return Color("Top-Secret Red")
        case .unknown: return Color("Pending Black")
        }
    }
}

enum ArticleAttribute {
    case object(ObjectClass)
    case esoteric(EsotericClass)
    case disruption(DisruptionClass)
    case risk(RiskClass)
    
    func toImage() -> String {
        switch self {
        case .object(let objectClass): return objectClass.toImage()
        case .esoteric(let esotericClass): return esotericClass.toImage()
        case .disruption(let disruptionClass): return disruptionClass.toImage()
        case .risk(let riskClass): return riskClass.toImage()
        }
    }
    
    func toLocalString() -> String {
        switch self {
        case .object(let objectClass): return objectClass.toLocalString()
        case .esoteric(let esotericClass): return esotericClass.toLocalString()
        case .disruption(let disruptionClass): return disruptionClass.toLocalString()
        case .risk(let riskClass): return riskClass.toLocalString()
        }
    }
    
    func toColor() -> Color {
        switch self {
        case .object(let objectClass): return objectClass.toColor()
        case .esoteric(let esotericClass): return esotericClass.toColor()
        case .disruption(let disruptionClass): return disruptionClass.toColor()
        case .risk(let riskClass): return riskClass.toColor()
        }
    }
}

// MARK: - Placeholder Vars
let placeholderURL: URL = URL(string: "https://scp-wiki.wikidot.com/")!
let placeHolderArticle = Article(
    title: "SCP-173",
    pagesource: """
**Item #:** SCP-173

**Object Class:** Euclid

**Special Containment Procedures:** Item SCP-173 is to be kept in a locked container at all times. When personnel must enter SCP-173's container, no fewer than 3 may enter at any time and the door is to be relocked behind them. At all times, two persons must maintain direct eye contact with SCP-173 until all personnel have vacated and relocked the container.

**Description:** Moved to Site-19 1993. Origin is as of yet unknown. It is constructed from concrete and rebar with traces of Krylon brand spray paint. SCP-173 is animate and extremely hostile. The object cannot move while within a direct line of sight. Line of sight must not be broken at any time with SCP-173. Personnel assigned to enter container are instructed to alert one another before blinking. Object is reported to attack by snapping the neck at the base of the skull, or by strangulation. In the event of an attack, personnel are to observe Class 4 hazardous object containment procedures.

Personnel report sounds of scraping stone originating from within the container when no one is present inside. This is considered normal, and any change in this behaviour should be reported to the acting HMCL supervisor on duty.

The reddish brown substance on the floor is a combination of feces and blood. Origin of these materials is unknown. The enclosure must be cleaned on a bi-weekly basis.
""",
    url: URL(string: "https://scp-wiki.wikidot.com/scp-173")!,
    thumbnail: URL(string: "https://api.time.com/wp-content/uploads/2015/02/imsis270-064.jpg")!,
    objclass: .euclid,
    disruption: .vlam,
    risk: .notice
)
