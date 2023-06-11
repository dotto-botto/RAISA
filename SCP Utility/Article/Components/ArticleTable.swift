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
        let headers: [String] = findHeaders(doc)
        let rows: [[String]] = parseTableContent(doc)
    
        VStack(spacing: 0) {
            Rectangle().frame(height: 1)
            HStack {
                ForEach(headers.isEmpty ? [""] : headers, id: \.self) { header in
                    RAISAText(article: article, text: header)
                    Spacer()
                }
            }
            Rectangle().frame(height: 1)
            ForEach(rows, id: \.self) { row in
                HStack {
                    ForEach(row, id: \.self) { cell in
                        RAISAText(article: article, text: cell)
                        Spacer()
                    }
                }
            }
            Rectangle().frame(height: 1)
        }
    }
}

fileprivate func findHeaders(_ doc: String) -> [String] {
    var headers: [String] = []
    let content = doc
    
    if doc.contains("[[table") && doc.contains("[[/table]]") {
        var firstRow = content.slice(with: "[[row", and: "[[/row]]")
        
        var cellMark: String = ""
        var cellEndMark: String = ""
        if firstRow.contains("[[hcell") { cellMark = "[[hcell"; cellEndMark = "[[/hcell]]" }
        else { cellMark = "[[cell"; cellEndMark = "[[/cell]]" }
        
        for _ in firstRow.indicesOf(string: cellMark) {
            if let header = firstRow.slice(from: "\"]]", to: cellEndMark) {
                headers.append(header)
                firstRow.removeText(from: cellMark, to: cellEndMark)
            }
        }
    } else if doc.contains("||") {
        var firstRow = content.slice(with: "||", and: "||\n")
        for _ in firstRow.indicesOf(string: "||~") {
            if let header = firstRow.slice(from: "||~ ", to: "||") {
                headers.append(header.replacingOccurrences(of: "\n", with: ""))
                firstRow = firstRow.replacingOccurrences(of: "||~ " + header, with: "")
            }
        }
    }
    
    return headers
}

fileprivate func parseTableContent(_ doc: String) -> [[String]] {
    var rows: [[String]] = []
    
    if doc.contains("[[table") && doc.contains("[[/table]]") {
        // Remove first row
        var content = doc.replacingOccurrences(of: doc.slice(with: "[[row", and: "[[/row]]"), with: "")
        for _ in content.indicesOf(string: "[[row") {
            var madeRow: [String] = []
            if var stringRow = content.slice(from: "[[row]]", to: "[[/row]]") {
                for _ in stringRow.indicesOf(string: "[[cell") {
                    if let cell = stringRow.slice(from: "\"]]", to: "[[/cell]]") {
                        madeRow.append(cell)
                        stringRow.removeText(from: "[[cell", to: "[[/cell]]")
                    }
                }
            }
            rows.append(madeRow)
            content.removeText(from: "[[row", to: "[[/row]]")
        }
    } else if doc.contains("||") {
         //Remove first row
        var content = doc.replacingOccurrences(of: doc.slice(with: "||", and: "||\n"), with: "")
        for line in content.components(separatedBy: .newlines) {
            var madeRow: [String] = []

            var stringRow = line
            for _ in stringRow.indicesOf(string: "||") {
                if let cell = stringRow.slice(from: "||", to: "||") {
                    madeRow.append(cell)
                    stringRow = stringRow.replacingOccurrences(of: "||" + cell, with: "")
                }
            }
            
            rows.append(madeRow)
            content = content.replacingOccurrences(of: line, with: "")
        }
    }
    
    return rows
}

// https://stackoverflow.com/a/27880748/11248074
func matches(for regex: String, in text: String) -> [String] {
    do {
        let regex = try NSRegularExpression(pattern: regex)
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
