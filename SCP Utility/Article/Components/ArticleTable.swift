//
//  ArticleTable.swift
//  SCP Utility
//
//  Created by Maximus Harding on 4/10/23.
//

import SwiftUI
import MarkdownUI

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
                                .contextMenu {
                                    Button {} label: {
                                        Label("DISMISS", systemImage: "xmark")
                                    }
                                } preview: {
                                    List {
                                        Markdown(FilterToPure(doc: cell))
                                    }
                                }
                        }
                    }
                    Divider()
                }
            }
            Rectangle().frame(height: 1)
        }
//        ScrollView(.horizontal, showsIndicators: false) {
//            Rectangle().frame(height: 1)
//            Grid {
//                ForEach(Array(zip(table, table.indices)), id: \.1) { row, _ in
//                    // Row
//                    HStack {
//                        ForEach(Array(zip(row, row.indices)), id: \.1) { cell, _ in
//                            // Cell
//                            RAISAText(article: article, text: cell)
//                                .scrollDisabled(true)
//                                .frame(maxWidth: 300, maxHeight: .infinity, alignment: .leading)
//                                .fixedSize(horizontal: false, vertical: true)
//                                .contextMenu {
//                                    Button {} label: {
//                                        Label("DISMISS", systemImage: "xmark")
//                                    }
//                                } preview: {
//                                    List {
//                                        RAISAText(article: article, text: cell)
//                                    }
//                                }
//                        }
//                    }
//                    Spacer()
//                    Divider()
//                }
//            }
//            Rectangle().frame(height: 1)
//        }
//        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    /// Returns an entire table, including the headers
    func parseEntireTable(_ doc: String) -> [[String]] {
        var rows: [[String]] = []
        
        let doc = doc.trimmingCharacters(in: .whitespacesAndNewlines)
        if doc.contains("[[table") && doc.contains("[[/table]]") {
            for rowMatch in matches(for: #"\[\[row[\s\S]*?\[\[\/row]]"#, in: doc) {
                var madeRow: [String] = []
                
                for cellMatch in matches(for: #"\[\[h?cell[\s\S]*?\[\[\/h?cell]]"#, in: rowMatch) {
                    try! madeRow.append(
                        cellMatch
                            .replacing(Regex(#"\[\[h?cell[\s\S]*?]]|\[\[\/h?cell]]"#), with: "")
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
        
        let textDoc = """
||~ Subject Information ||~ SCP-3285-A Title Instance ||~ Summary ||~ Effects of SCP-3285-A Exposure ||
|| D-37245, standard subject taken from normal pool of D-Class. Subject is a 26-year old female with high school education and criminal convictions related to motor vehicle theft. || The Free Story of Mark Twain's Stupidity || An extended dialogue between writers Mark Twain and William Shakespeare, apparently located in an afterlife resembling the traditional Western version of Heaven. Shakespeare angrily criticizes Twain for questioning the authorship of his plays, punctuating his outbursts with passages read out loud from Twain's //Is Shakespeare Dead?// (1909). Mark Twain responds with characteristic humor and wit, asking for Shakespeare to produce ready evidence of his authorship and defending his support of the Baconian theory. The story ends with Francis Bacon entering the scene and denouncing both Twain and Shakespeare as "silly dreaming children," saying that he considered the theatre a waste of time and would never have written plays. Shakespeare laughs at Twain's expense as the dream ends.  || Subject expressed a strong desire to read novels and requested reading material from researchers, despite showing no great interest in literature prior to the test. No other long-term effects. ||
|| D-37245, same as previous experiment. || The Free Story of King Lear the Author || Adaptation of William Shakespeare's //King Lear// onto a modern setting, depicting Lear as a famous author who is in the terminal stages of pancreatic cancer. As he writes out the final version of his will, planning to divide his assets between his three daughters, he asks them what they plan to do with the rights to his works. Goneril and Regan proclaim their desire to sell the rights of film and television adaptations, whereas Cordelia expresses her desire to donate the rights to the Library of Congress in Washington, D.C. Angered by her attempts to give away his legacy without financial gain, Lear disinherits Cordelia and divides the rights to his works between the other two sisters. After firing his literary agent Kent for expressing disapproval at his disownment of Cordelia, Lear slowly begins to lose his mind, and the other main characters die as in the original play. Story ends with Lear's reputation ruined as his family's scandals and his daughters' plots to kill one another are exposed; he dies without a direct heir, and Goneril's widower Albany inherits his fortune. || Subject expressed extreme distaste for the works of author George R.R. Martin, and displayed in-depth knowledge of his //A Song of Ice and Fire// series despite not having previously read it. ||
|| Junior Researcher Adams. After lack of negative side effects in previous tests, consumption of SCP-3285-A instances by Foundation personnel for research purposes was provisionally approved. || The Free Story of Lawrence the Preserver || A medieval fantasy epic featuring a fictionalized version of Creative Commons founder Lawrence Lessig as the primary protagonist. Story begins as an army of antagonists referred to as the Suppressors sack Lawrence's hometown, destroying the library that Lawrence had previously worked in as a scribe. Vowing to avenge "the ink and the blood," Lawrence raises an army of peasants and other lower-class citizens to remove the Suppressors from their land. Climax of the story takes place in a battlefield referred to as Extentia, as Lawrence does battle with and defeats the nameless leader of the Suppressors, suffering a mortal wound in the process. The Suppressors are driven from the land, and Lawrence is idolized and immortalized as "Lawrence the Preserver." || Researcher Adams expressed a desire to "contribute to humanity's collective knowledge." After being placed in on-site lodging, logs of Researcher Adams' computer indicated numerous visits to the Wikimedia Commons image website, followed by uploads of public domain images collected from elsewhere on the Internet to the site. Full recovery from SCP-3285-A's effects was successfully achieved following Class-B Amnestic treatment. ||
|| Andrew Garcia, Foundation legal counsel. Subject had previously worked for ████████████ as an intellectual property attorney, representing the company in court when it brought suit against competitors for trademark infringement. Test cleared by Site Director. || [REDACTED] || [REDACTED - SEE ADDENDUM] || [REDACTED] ||
"""
        ScrollView {
            Text("vvvv")
            ArticleTable(article: placeHolderArticle, doc: textDoc).previewDisplayName("Text Style")
            Text("^^^^")
        }
    }
}
