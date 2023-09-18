//
//  ACSView.swift
//  SCP Utility
//
//  Created by Maximus Harding on 5/5/23.
//

import SwiftUI

/// Component designed to mimic the Anomaly Classification Bar, in SwiftUI.
struct ACSView: View {
    let itemnumber: Int
    let clearance: Int
    let object: ObjectClass
    let esoteric: EsotericClass?
    let disruption: DisruptionClass
    let risk: RiskClass
    var customSecondary: String? = nil
    let secondaryIcon: String?
    
    /// Init from a raw wikidot component string. Example:
    /// [[include :scp-wiki:component:anomaly-class-bar-source
    ///    |item-number=5004
    ///    |clearance=5
    ///    |container-class=esoteric
    ///    |secondary-class=thaumiel
    ///    |secondary-icon=...
    ///    |disruption-class=ekhi
    ///    |risk-class=notice
    ///    ]]
    /// - Parameter component: The raw string
    init?(component: String, article: Article? = nil) {
        guard let num: Int = {
            Int(matches(for: #"(?<=item-number=).*?(?=\n|\|)"#, in: component).first?.replacingOccurrences(of: " ", with: "") ?? "")
        }() else { return nil }
        
        guard let clearance: Int = {
            Int(matches(for: #"(?<=clearance=).*?(?=\n|\|)"#, in: component).first?.replacingOccurrences(of: " ", with: "") ?? "")
        }() else { return nil }
        
        let obj: String = {
            matches(for: #"(?<=container-class=).*?(?=\n|\|)"#, in: component).first ?? ""
        }().trimmingCharacters(in: .whitespaces)
        
        
        let secondaryClass: String = {
            matches(for: #"(?<=secondary-class=).*?(?=\n|\|)"#, in: component).first ?? ""
        }().trimmingCharacters(in: .whitespaces)
        
        let dis: String = {
            matches(for: #"(?<=disruption-class=).*?(?=\n|\|)"#, in: component).first ?? ""
        }().trimmingCharacters(in: .whitespaces)
        
        let ris: String = {
            matches(for: #"(?<=risk-class=).*?(?=\n|\|)"#, in: component).first ?? ""
        }().trimmingCharacters(in: .whitespaces)
        
        let secondaryIcon = matches(for: #"(?<=secondary-icon=).*?(?=\n|\|)"#, in: component).first?
            .replacingOccurrences(of: "http:", with: "https:")
            .trimmingCharacters(in: .whitespaces)
        
        self.itemnumber = num
        self.clearance = clearance
        
        self.object = {
            switch obj.lowercased() {
            case "safe": return .safe
            case "euclid": return .euclid
            case "keter": return .keter
            case "neutralized": return .neutralized
            case "pending": return .pending
            case "explained": return .explained
            case "esoteric": return .esoteric
            default: return .unknown
            }
        }()
        
        self.esoteric = {
            switch obj.lowercased() {
            case "uncontained": return .uncontained
            default: return {
                switch secondaryClass.lowercased() {
                case "apollyon": return .apollyon
                case "archon": return .archon
                case "cernunnos": return .cernunnos
                case "decommissioned": return .decommissioned
                case "hiemal": return .hiemal
                case "tiamat": return .tiamat
                case "ticonderoga": return .ticonderoga
                case "thaumiel": return .thaumiel
                case "uncontained": return .uncontained
                default: return .unknown
                }
            }()
            }
        }()
        
        if self.esoteric == .unknown {
            self.customSecondary = secondaryClass
        }
        
        self.disruption = {
            switch dis.lowercased() {
            case "dark": return .dark
            case "vlam": return .vlam
            case "keneq": return .keneq
            case "ekhi": return .ekhi
            case "amida": return .amida
            default: return .unknown
            }
        }()
        
        self.risk = {
            switch ris.lowercased() {
            case "notice": return .notice
            case "caution": return .caution
            case "warning": return .warning
            case "danger": return .danger
            case "critical": return .critical
            default: return .unknown
            }
        }()
        
        self.secondaryIcon = (secondaryClass == "none" || secondaryClass == "") ? nil : secondaryIcon
        
        if let article = article, article.objclass == .unknown {
            let con = PersistenceController.shared
            con.updateObjectClass(articleid: article.id, newattr: self.object)
            con.updateEsotericClass(articleid: article.id, newattr: self.esoteric ?? .unknown)
            con.updateRiskClass(articleid: article.id, newattr: self.risk)
            con.updateDisruptionClass(articleid: article.id, newattr: self.disruption)
        }
    }
    
    var body: some View {
        VStack {
            HStack {
                VStack {
                    Text("ACS_ITEMNUM")
                    Text(String(itemnumber)).font(.largeTitle).bold()
                }
                
                VStack {
                    ForEach(0..<clearance, id: \.self) { _ in
                        Rectangle()
                            .foregroundColor(object.toColor())
                            .frame(height: 8)
                    }
                }
                
                VStack {
                    Text("ACS_LEVEL\(clearance)").font(.largeTitle).bold()
                    Text("ACS_TOPSECRET")
                }
            }
            
            Rectangle().frame(height: 20)
            if esoteric == .unknown && secondaryIcon != nil {
                ACSCellView(
                    secondaryname: customSecondary ?? "",
                    secondaryIconURL: URL(string: secondaryIcon ?? "")
                )
            } else if esoteric != nil && esoteric != .unknown {
                ACSCellView(.esoteric(esoteric!))
            } else {
                ACSCellView(.object(object))
            }
            ACSCellView(.disruption(disruption))
            ACSCellView(.risk(risk))
        }
    }
}

struct ACSView_Previews: PreviewProvider {
    static var previews: some View {
        ACSView(component: """
[[include :scp-wiki:component:anomaly-class-bar-source
|item-number=5004
|clearance=5
|container-class=esoteric
|secondary-class=thaumiel
|secondary-icon=http://scp-wiki.wikidot.com/local--files/component:anomaly-class-bar/thaumiel-icon.svg
|disruption-class=ekhi
|risk-class=notice
]]
""")
    }
}
