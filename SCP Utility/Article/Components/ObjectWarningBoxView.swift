//
//  ObjectWarningBoxView.swift
//  SCP Utility
//
//  Created by Maximus Harding on 6/2/23.
//

import SwiftUI

struct ObjectWarningBoxView: View {
    var bgImage: URL
    var textTop: String
    var textBottom: String
    var objectNumber: String
    
    init(source: String) {
        self.bgImage = URL(string: source.slice(from: "bg-image=", to: "\n")?.replacingOccurrences(of: "http:", with: "https:") ?? "") ?? URL(string: "https://scp-wiki.wikidot.com/local--files/component:object-warning-box-source/scp-logo.svg")!
        self.textTop = source.slice(from: "text-top=", to: "|") ?? "BY ORDER OF THE OVERSEER COUNCIL"
        self.textBottom = source.slice(from: "text-bottom=", to: "|") ?? "The following file is Classified\nUnauthorized access is forbidden."
        self.objectNumber = source.slice(from: "object-number=", to: "]]") ?? ""
    }
    
    var body: some View {
        VStack {
            HStack(alignment: .center) {
                Text(textTop).font(.largeTitle).bold()
            }
            HStack(alignment: .center) {
                Text(textBottom)
            }
            HStack(alignment: .center) {
                Text(objectNumber).monospaced().font(.title2)
            }
        }
        .background {
            AsyncImage(url: bgImage) { image in
                image
                .resizable()
                .scaledToFit()
                .opacity(0.15)
            } placeholder: {}
        }
    }
}

struct ObjectWarningBoxView_Previews: PreviewProvider {
    static var previews: some View {
        ObjectWarningBoxView(source: """
[[include :scp-wiki:component:object-warning-box-source
|bg-image=http://scpdsandbox.wdfiles.com/local--files/bigslothonmyface-s-sandbox-1/7000%20logo%201.png
|bg-opacity=0.15
|text-top=BY ORDER OF THE OVERSEER COUNCIL
|text-bottom=**This document describes an ongoing EK-Class "Scorched Earth" Event.**
Upon accessing the file, Foundation Cognitomole catcher_77 will embed within your subconscious, and may track your biosignature for up to 72 hours.
|object-number= L4-7002
]]
""")
    }
}
