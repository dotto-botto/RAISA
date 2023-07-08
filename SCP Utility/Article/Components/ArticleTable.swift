//
//  ArticleTable.swift
//  SCP Utility
//
//  Created by Maximus Harding on 4/10/23.
//

import SwiftUI

/// Table to be displayed inside RAISAText.
/// "doc" should be the corresponsing [[table]] div or a table made using the "||" syntax.
struct ArticleTable: View {
    @State var article: Article
    @State var doc: String
    var body: some View {
        let table = parseEntireTable(doc)

        VStack {
            Rectangle().frame(height: 1)
            Grid {
                ForEach(Array(zip(table, table.indices)), id: \.1) { row, _ in
                    // Row
                    HStack {
                        ForEach(Array(zip(row, row.indices)), id: \.1) { cell, _ in
                            // Cell
                            RAISAText(article: article, text: cell)
                                .scrollDisabled(true)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    Divider()
                }
            }
            Rectangle().frame(height: 1)
        }
    }
    
    /// Returns an entire table, including the headers
    func parseEntireTable(_ doc: String) -> [[String]] {
        var rows: [[String]] = []
        
        let doc = doc.trimmingCharacters(in: .whitespacesAndNewlines)
        if doc.contains("[[table") && doc.contains("[[/table]]") {
            for rowMatch in matches(for: #"\[\[row[\s\S]*?\[\[\/row]]"#, in: doc) {
                var madeRow: [String] = []
                
                for cellMatch in matches(for: #"\[\[cell[\s\S]*?\[\[\/cell]]"#, in: rowMatch) {
                    try! madeRow.append(
                        cellMatch
                            .replacing(Regex(#"\[\[cell[\s\S]*?]]|\[\[\/cell]]"#), with: "")
                            .replacing(Regex(#"^(~|=)"#), with: "")
                    )
                }
                
                rows.append(madeRow)
            }
        } else if doc.contains("||") {
            for rowMatch in matches(for: #"((\|\|.*?)(\|\|)(\n|$))"#, in: doc) {
                var madeRow: [String] = []
                
                for cellMatch in matches(for: #"(?<=\|\|).*?(?=\|\|)"#, in: rowMatch) {
                    try! madeRow.append(
                        cellMatch
                            .replacingOccurrences(of: "||", with: "")
                            .replacing(Regex(#"^(~|=)"#), with: "")
                            .trimmingCharacters(in: .whitespacesAndNewlines)
                    )
                }
                
                rows.append(madeRow)
            }
        }
        
        return rows
    }
}

// https://stackoverflow.com/a/27880748/11248074
func matches(for regex: String, in text: String, option: NSRegularExpression.Options? = nil) -> [String] {
    do {
        let regex = try option == nil ? NSRegularExpression(pattern: regex) : NSRegularExpression(pattern: regex, options: option!)
        let results = regex.matches(in: text,
                                    range: NSRange(text.startIndex..., in: text))
        return results.map {
            String(text[Range($0.range, in: text)!])
        }
    } catch let error {
        print("invalid regex: \(error.localizedDescription)")
        return []
    }
}

struct ArticleTable_Previews: PreviewProvider {
    static var previews: some View {
        ArticleTable(article: placeHolderArticle, doc: """
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
        
        ArticleTable(article: placeHolderArticle, doc: """
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
