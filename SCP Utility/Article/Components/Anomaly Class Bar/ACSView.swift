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
    init?(component: String) {
        guard let num: Int = {
            Int(matches(for: #"(?<=item-number=).*?(?=\n|\|)"#, in: component).first?.replacingOccurrences(of: " ", with: "") ?? "")
        }() else { return nil }
        
        guard let clearance: Int = {
            Int(matches(for: #"(?<=clearance=).*?(?=\n|\|)"#, in: component).first?.replacingOccurrences(of: " ", with: "") ?? "")
        }() else { return nil }
        
        let obj: String = {
            matches(for: #"(?<=container-class=).*?(?=\n|\|)"#, in: component).first ?? ""
        }().replacingOccurrences(of: " ", with: "")
        
        
        let secondaryClass: String = {
            matches(for: #"(?<=secondary-class=).*?(?=\n|\|)"#, in: component).first ?? ""
        }().replacingOccurrences(of: " ", with: "")
        
        let dis: String = {
            matches(for: #"(?<=disruption-class=).*?(?=\n|\|)"#, in: component).first ?? ""
        }().replacingOccurrences(of: " ", with: "")
        
        let ris: String = {
            matches(for: #"(?<=risk-class=).*?(?=\n|\|)"#, in: component).first ?? ""
        }().replacingOccurrences(of: " ", with: "")
        
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
    }
    
    var body: some View {
        VStack {
            HStack {
                VStack {
                    Text("ITEM #")
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
                    Text("LEVEL \(clearance)").font(.largeTitle).bold()
                    Text("TOP SECRET")
                }
            }
            
            Rectangle().frame(height: 20)
            if UIDevice.current.userInterfaceIdiom == .phone {
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
            } else {
                
            }
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
