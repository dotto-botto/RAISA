//
//  ArticleTable.swift
//  SCP Utility
//
//  Created by Maximus Harding on 4/10/23.
//

import SwiftUI
import MarkdownUI

let ROWS_PER_PAGE = 10

/// Table to be displayed inside RAISAText.
/// "doc" should be the corresponsing [[table]] div or a table made using the "||" syntax.
struct ArticleTable: View {
    @State var article: Article
    @State var doc: String
    @State private var focusedCell: SheetData? = nil
    @State private var table: [[String]] = [[]]
    @State private var tableViewed: Bool = false
    
    @State private var page: Int = 1
    @State private var maxpage: Int = 1

    var body: some View {
        NavigationLink {
            subView.tint(article.findTheme()?.themeAccent ?? .accentColor)
        } label: {
            HStack {
                Image(systemName: "chevron.left")
                Text("TAP_FOR_TABLE")
                if tableViewed { Image(systemName: "checkmark") }
                Image(systemName: "chevron.right")
            }
        }
        .task { parseEntireTable(doc) }
    }
    
    private var subView: some View {
        VStack {
            Group {
                Text("TABLE_CELL_PROMPT")
                Text("TABLE_SCROLL_PROMPT")
            }
            .font(.subheadline)
            .foregroundColor(.secondary)

            Rectangle()
                .frame(height: 1)
            ScrollView(.horizontal) {
                let maxWidth = UIScreen.main.bounds.width * 2
                VStack(alignment: .leading, spacing: 0) {
                    Grid {
                        let pages = Array(zip(table, table.indices)).dropFirst((page - 1) * ROWS_PER_PAGE).prefix(ROWS_PER_PAGE)
                        ForEach(pages, id: \.1) { row, index in
                            // Row
                            HStack(alignment: .top) {
                                ForEach(Array(zip(row, row.indices)), id: \.1) { cell, _ in
                                    // Cell
                                    RAISAText(article: article, text: cell)
                                        .scrollDisabled(true)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .fixedSize(horizontal: false, vertical: false)
                                        .onTapGesture {
                                            focusedCell = SheetData(text: cell)
                                        }
                                }
                            }
                            
                            if index != table.count - 1 {
                                Rectangle().frame(height: 0.5)
                            }
                        }
                    }
                }
                .frame(maxWidth: maxWidth, alignment: .leading)
                .fixedSize(horizontal: false, vertical: false)
            }
            Rectangle().frame(height: 1)
            
            if maxpage > 1 {
                pager
            }
        }
        .sheet(item: $focusedCell) { data in
            NavigationStack {
                RAISAText(article: article, text: data.text)
                    .padding(.horizontal, 10)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button {
                                focusedCell = nil
                            } label: {
                                Image(systemName: "chevron.down")
                            }
                        }
                    }
            }
        }
        .navigationTitle("TABLE_VIEW_TITLE")
        .onAppear {
            tableViewed = true
        }
    }
    
    @ViewBuilder
    private var pager: some View {
        if maxpage > 1 {
            HStack {
                Spacer()
                
                if page > 2 {
                    Button {
                        page = 1
                    } label: {
                        Image(systemName: "chevron.left.2")
                    }
                    .padding(.trailing, 5)
                }
                
                if page > 1 {
                    Button {
                        page -= 1
                    } label: {
                        Image(systemName: "chevron.left")
                    }
                }
                
                Menu {
                    ForEach((1...maxpage).reversed(), id: \.self) { pagenum in
                        Button("\(pagenum)") { page = pagenum }
                    }
                } label: {
                    Text("\(page)CV_PAGECOUNT\(maxpage)")
                }
                .padding(.horizontal, 5)
                
                if page < maxpage {
                    Button {
                        page += 1
                    } label: {
                        Image(systemName: "chevron.right")
                    }
                }
                
                if page < maxpage - 1 {
                    Button {
                        page = maxpage
                    } label: {
                        Image(systemName: "chevron.right.2")
                    }
                    .padding(.leading, 5)
                }
                
                Spacer()
            }
            .font(.title3)
        }
    }
        
    /// Parses an entire table, including the headers
    func parseEntireTable(_ doc: String) {
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
        
        self.table = rows
        self.maxpage = rows.count / ROWS_PER_PAGE
    }
    
    private struct SheetData: Identifiable {
        let id = UUID()
        var text: String
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
        let textDoc = """
||~ Subject Information ||~ SCP-3285-A Title Instance ||~ Summary ||~ Effects of SCP-3285-A Exposure ||
|| D-37245, standard subject taken from normal pool of D-Class. Subject is a 26-year old female with high school education and criminal convictions related to motor vehicle theft. || The Free Story of Mark Twain's Stupidity || An extended dialogue between writers Mark Twain and William Shakespeare, apparently located in an afterlife resembling the traditional Western version of Heaven. Shakespeare angrily criticizes Twain for questioning the authorship of his plays, punctuating his outbursts with passages read out loud from Twain's //Is Shakespeare Dead?// (1909). Mark Twain responds with characteristic humor and wit, asking for Shakespeare to produce ready evidence of his authorship and defending his support of the Baconian theory. The story ends with Francis Bacon entering the scene and denouncing both Twain and Shakespeare as "silly dreaming children," saying that he considered the theatre a waste of time and would never have written plays. Shakespeare laughs at Twain's expense as the dream ends.  || Subject expressed a strong desire to read novels and requested reading material from researchers, despite showing no great interest in literature prior to the test. No other long-term effects. ||
|| D-37245, same as previous experiment. || The Free Story of King Lear the Author || Adaptation of William Shakespeare's //King Lear// onto a modern setting, depicting Lear as a famous author who is in the terminal stages of pancreatic cancer. As he writes out the final version of his will, planning to divide his assets between his three daughters, he asks them what they plan to do with the rights to his works. Goneril and Regan proclaim their desire to sell the rights of film and television adaptations, whereas Cordelia expresses her desire to donate the rights to the Library of Congress in Washington, D.C. Angered by her attempts to give away his legacy without financial gain, Lear disinherits Cordelia and divides the rights to his works between the other two sisters. After firing his literary agent Kent for expressing disapproval at his disownment of Cordelia, Lear slowly begins to lose his mind, and the other main characters die as in the original play. Story ends with Lear's reputation ruined as his family's scandals and his daughters' plots to kill one another are exposed; he dies without a direct heir, and Goneril's widower Albany inherits his fortune. || Subject expressed extreme distaste for the works of author George R.R. Martin, and displayed in-depth knowledge of his //A Song of Ice and Fire// series despite not having previously read it. ||
|| Junior Researcher Adams. After lack of negative side effects in previous tests, consumption of SCP-3285-A instances by Foundation personnel for research purposes was provisionally approved. || The Free Story of Lawrence the Preserver || A medieval fantasy epic featuring a fictionalized version of Creative Commons founder Lawrence Lessig as the primary protagonist. Story begins as an army of antagonists referred to as the Suppressors sack Lawrence's hometown, destroying the library that Lawrence had previously worked in as a scribe. Vowing to avenge "the ink and the blood," Lawrence raises an army of peasants and other lower-class citizens to remove the Suppressors from their land. Climax of the story takes place in a battlefield referred to as Extentia, as Lawrence does battle with and defeats the nameless leader of the Suppressors, suffering a mortal wound in the process. The Suppressors are driven from the land, and Lawrence is idolized and immortalized as "Lawrence the Preserver." || Researcher Adams expressed a desire to "contribute to humanity's collective knowledge." After being placed in on-site lodging, logs of Researcher Adams' computer indicated numerous visits to the Wikimedia Commons image website, followed by uploads of public domain images collected from elsewhere on the Internet to the site. Full recovery from SCP-3285-A's effects was successfully achieved following Class-B Amnestic treatment. ||
|| Andrew Garcia, Foundation legal counsel. Subject had previously worked for ████████████ as an intellectual property attorney, representing the company in court when it brought suit against competitors for trademark infringement. Test cleared by Site Director. || [REDACTED] || [REDACTED - SEE ADDENDUM] || [REDACTED] ||
"""

        ArticleTable(article: placeHolderArticle, doc: textDoc).previewDisplayName("Text Style")
    }
}

