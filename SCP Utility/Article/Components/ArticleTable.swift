//
//  ArticleTable.swift
//  SCP Utility
//
//  Created by Maximus Harding on 4/10/23.
//

import SwiftUI
import MarkdownUI

struct ArticleTable: View {
    @State var doc: String
    var body: some View {
        var content = doc
        var rows: [[String]] = []
        
        if content.contains("[[table") && content.contains("[[/table]]") {
            ForEach(content.indicesOf(string: "[[row"), id: \.self) { _ in
                var row = content.slice(from: "[[row", to: "[[/row]]")!
                var cells: [String] = []
                ForEach(row.indicesOf(string: "[[cell"), id: \.self) { _ in
                    let cell = row.slice(from: "\"]]", to: "[[/cell]]")!
                    let _ = cells.append(cell)
                    let _ = row = row.replacingOccurrences(of: cell, with: "")
                    let _ = row.removeText(from: "[[cell", to: "[[/cell]]")
                }
                let _ = rows.append(cells)
                let _ = content = content.replacingOccurrences(of: row, with: "")
                let _ = content.replacingOccurrences(of: "[[row[[/row]]", with: "")
            }
            
            ForEach(rows, id: \.self) { row in
                ForEach(row, id: \.self) { cell in
                    Markdown(cell).padding(.all)
                }
            }
        } else if content.contains("||") {
            
        } else {
            Text("Table is in incorrect format").font(.caption2)
            Text(content)
        }
    }
}

struct ArticleTable_Previews: PreviewProvider {
    static var previews: some View {
        ArticleTable(doc: """
[[table style="width: 100%;"]]
[[row]]
[[cell style="border-bottom: 1px solid #AAA; border-right: 1px solid #AAA; text-align: center; width: 25%;"]]
[[size 90%]]**Assigned Site**[[/size]]
[[/cell]]
[[cell style="border-bottom: 1px solid #AAA; border-right: 1px solid #AAA; text-align: center; width: 25%;"]]
[[size 90%]]**Site Director**[[/size]]
[[/cell]]
[[cell style="border-bottom: 1px solid #AAA; border-right: 1px solid #AAA; text-align: center; width: 25%;"]]
[[size 90%]]**Research Head**[[/size]]
[[/cell]]
[[cell style="border-bottom: 1px solid #AAA; text-align: center; width: 25%;"]]
[[size 90%]]**Assigned Task Force**[[/size]]
[[/cell]]
[[/row]]
[[row]]
[[cell style="border-right: 1px solid #AAA; text-align: center; width: 25%;"]]
[[size 80%]]USMILA Site-19[[/size]]
[[/cell]]
[[cell style="border-right: 1px solid #AAA; text-align: center; width: 25%;"]]
[[size 80%]]Tilda Moose[[/size]]
[[/cell]]
[[cell style="border-right: 1px solid #AAA; text-align: center; width: 25%;"]]
[[size 80%]]Everett Mann, M.D.[[/size]]
[[/cell]]
[[cell style="text-align: center; width: 25%;"]]
[[size 80%]]MTF A-14 "Dishwashers"[[/size]]
[[/cell]]
[[/row]]
[[/table]]
""").previewDisplayName("Div Style")
        
        ArticleTable(doc: """
||~ **Position**||~ **Name**||~ **Title**||
||Committee Lead||Dir. Sophia Light||Director, Western Regional Command||
||Assistant Lead||Dr. Mark Kiryu||Sr. Research||
||Psychology Consult||Dr. Simon Glass||Head, Foundation Psychology||
||Research Consult||Dr. Charles Gears||Head, Foundation Analytics||
||Thaumaturgical Consult||Dr. Katherine Sinclair||Director, Thaumatology and Occult Studies, Site-87||
||Containment Consult||Dr. Hollister Cox||Asst. Director, Site-81||
||General Consult||[[[SCP-963|Dir. Elias Shaw]]]||Head, Foundation Personnel||
||Tactical Consults||||Agent Sasha Merlo and Agent Daniel Navarro||
||GOI Liaison||Dr. Justine Everwood||GOI Specialist||
||Special Liaison to the FBI||Agent Carmen Maldonado||Unusual Incidents Unit||
""").previewDisplayName("Text Style")
    }
}
