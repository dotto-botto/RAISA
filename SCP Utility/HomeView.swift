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
    @State var query: String
    @State var nextView: Bool = false
    var body: some View {
        NavigationView {
            Text("TODO")
            
            if nextView {
                ArticleView(scpquery: query)
            }
        }
        .navigationTitle("Home")
        .searchable(text: $query)
        .onSubmit {
            nextView = true
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(query: "1000")
    }
}

