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
            let str = component.slice(from: "|item-number=SCP-", to: "\n") ??
            component.slice(from: "|item-number=", to: "\n")
            return Int(str ?? "")
        }() else { return nil }
        guard let clearance = Int(component.slice(from: "|clearance=", to: "\n")?.replacingOccurrences(of: " ", with: "") ?? "") else { return nil }
        
        var object: ObjectClass
        if component.contains("safe") { object = .safe }
        else if component.contains("euclid") { object = .euclid }
        else if component.contains("keter") { object = .keter }
        else if component.contains("neutralized") { object = .neutralized }
        else if component.contains("pending") { object = .pending }
        else if component.contains("explained") { object = .explained }
        else if component.contains("esoteric") { object = .esoteric }
        else { return nil }
        
        var newEso: EsotericClass? = nil
        if component.contains("apollyon") { newEso = .apollyon }
        else if component.contains("archon") { newEso = .archon }
        else if component.contains("cernunnos") { newEso = .cernunnos }
        else if component.contains("decommissioned") { newEso = .decommissioned }
        else if component.contains("hiemal") { newEso = .hiemal }
        else if component.contains("tiamat") { newEso = .tiamat }
        else if component.contains("ticonderoga") { newEso = .ticonderoga }
        else if component.contains("thaumiel") { newEso = .thaumiel }
        else if component.contains("uncontained") { newEso = .uncontained }
        
        var dis: DisruptionClass
        if component.contains("dark") { dis = .dark }
        else if component.contains("vlam") { dis = .vlam }
        else if component.contains("keneq") { dis = .keneq }
        else if component.contains("ekhi") { dis = .ekhi }
        else if component.contains("amida") { dis = .amida }
        else { return nil }
        
        var ris: RiskClass
        if component.contains("notice") { ris = .notice }
        else if component.contains("caution") { ris = .caution }
        else if component.contains("warning") { ris = .warning }
        else if component.contains("danger") { ris = .danger }
        else if component.contains("critical") { ris = .critical }
        else { return nil }
        
        self.itemnumber = num
        self.clearance = clearance
        self.object = object
        self.esoteric = newEso
        self.disruption = dis
        self.risk = ris
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
                ACSCellView(.object(object))
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
