//
//  HomeView.swift
//  SCP Wiki Utility
//
//  Created by Maximus Harding on 12/25/22.
//

import SwiftUI
import Foundation


struct HomeView: View {
    @State private var path = NavigationPath()
    @State var query: String = ""
    @State var nextView: Bool = false
    var body: some View {
        NavigationStack {
            if nextView {
//                ArticleView(scpquery: query).navigationTitle(query)
            } else if !nextView {
                TextField("SEARCH_PROMPT", text: $query)
                    .border(.secondary)
                    .onSubmit {
                        nextView = true
                    }
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().previewDisplayName("Content View")
        HomeView()
    }
}

