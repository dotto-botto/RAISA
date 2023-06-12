//
//  TabViewComponent.swift
//  SCP Utility
//
//  Created by Maximus Harding on 4/26/23.
//

import SwiftUI
import MarkdownUI

/// Component to be displayed in RAISAText
/// given a "[[tabview]]" component from wikidot.
struct TabViewComponent: View {
    @State var article: Article
    @State var text: String
    @State var currentKey: String = ""
    @State private var showText: Bool = false
    @State private var contentKeys: [String] = []
    @State private var contentValues: [String] = []
    var body: some View {
        VStack {
            HStack {
                Image(systemName: "chevron.left.2").foregroundColor(.secondary)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(Array(zip(contentKeys, contentValues)), id: \.0) { key, value in
                            Button {
                                currentKey = key
                                showText = true
                            } label: {
                                VStack(spacing: 5) {
                                    Text(key)
                                    if currentKey == key {
                                        Rectangle().frame(height: 1)
                                    }
                                }
                                .foregroundColor(.accentColor)
                            }
                        }
                    }
                }
                Image(systemName: "chevron.right.2").foregroundColor(.secondary)
            }
            
            ForEach(Array(zip(contentKeys, contentValues)), id: \.0) { key, value in
                if key == currentKey {
                    RAISAText(article: article, text: value)
                }
            }
            
            HStack {
                Text("TAB_END_INDICATOR").foregroundColor(.secondary)
                Image(systemName: "chevron.right.2").foregroundColor(.secondary)
                Rectangle()
                    .frame(height: 0.5)
                    .foregroundColor(.secondary)
                Image(systemName: "chevron.left.2").foregroundColor(.secondary)
            }
        }
        .onAppear {
            let content = parseTabView(text)
            contentKeys = content.map { $0.0 }
            contentValues = content.map { $0.1 }
            
            currentKey = contentKeys.first ?? ""
        }
    }
}

fileprivate func parseTabView(_ doc: String) -> [(String,String)] {
    var returnDict: [(String,String)] = []
    var content = doc
    for index in doc.indicesOf(string: "[[tab ") {
        var tabContent = ""
        let header = content.slice(from: "[[tab ", to: "]]")
        if header != nil {
            tabContent = content.slice(from: "[[tab " + header! + "]]", to: "[[/tab]]") ?? ""
        } else {
            tabContent = content.slice(from: "[[tab]]", to: "[[/tab]]") ?? ""
        }
        returnDict.append((header ?? (index + 1).formatted(), tabContent))
        content.removeText(from: "[[tab", to: "[[/tab]]")
    }
    return returnDict
}

struct TabViewComponent_Previews: PreviewProvider {
    static var previews: some View {
        TabViewComponent(article: placeHolderArticle, text: """
[[tabview]]
[[tab Scenarios With Multiple Uses]]
Each of these letter combinations have been used at least twice on the wiki. They are presented alphabetically by K-Class followed by non-K designations and oddities. (GH gets to be special by seniority).

For one-off scenarios and versions seen only in -Js, scroll down.

Scenarios with *'s have appeared at least 5 times with a consistent definition.
Scenarios with ©'s have appeared at least 10 times with a consistent definition, and could be considered "well-established." --Also you have to pay me 5¢ to use them.--
[[/tab]]
[[tab AK©]]
**Most Common: AK-class end-of-the-world scenario**
**Used in:** 10 SCPs, 1 Tales, # Other
**Primary definition:** Related to a memetically spread behavior or "madness." Could be apocalyptic (e.g., people prioritize the behavior over eating/survival) or just radically reorient society around the behavior.

Some of these links just say "AK-class end of the world" without defining it.
**Alternative titles:** AK-class "madness" end of the world scenario

**SCPs:** [[[SCP-571]]], [[[SCP-1101]]], [[[SCP-1985]]], [[[SCP-3060]]], [[[SCP-3443]]], [[[SCP-4547]]], [[[SCP-5586]]], [[[SCP-6174]]], [[[http://scp-int.wikidot.com/scp-pl-200|SCP-PL-200]]], [[[http://scpfoundation.net/scp-1118-ru|SCP-1118-RU]]]
**Tales and other articles:** [[[http://www.scp-wiki.net/reboot-or-how-i-learned-to-stop-worrying-and-love-the-apocal|Reboot or: How I Learned to Stop Worrying and Love the Apocalypses]]]


**Inconsistent Uses**
||~ Title ||~ Definition ||~ Articles ||
|| AK-class scenario (Agricultural breakdown) || An unknown number of SCP-1623-1 and SCP-1623-2  projections remain and complete an unknown activity to cause crops to fail. || [[[SCP-1623]]] ||
[[/tab]]
[[tab ADK]]
**Most Common: ADK-Class "Complete Anomalous Destabilization" Scenario**
**Used in:** 2 SCPs, 1 Tale, 0 Other
**Primary definition:** A general scenario which occurs when the "anomalous" reclaims the Earth. Typically occurs 1 to 3 years after an unspecified human extinction event or SK-Class Dominance Shift.
**Alternative titles:** N/A

**SCPs:** [[[SCP-3309]]], [[[SCP-6016]]]
**Tales and other articles:** [[[umbral-migratory-sequence|UMBRAL_MIGRATORY_SEQUENCE.txt]]]
[[/tab]]
[[/tabview]]
""")
    }
}
