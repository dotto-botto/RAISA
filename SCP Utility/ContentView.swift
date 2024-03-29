//
//  ContentView.swift
//  SCP Wiki Utility
//
//  Created by Maximus Harding on 12/25/22.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            ExploreView().tabItem { Label("TABBAR_EXPLORE", systemImage: "globe") }
            ListView().tabItem { Label("TABBAR_LIST", systemImage: "bookmark") }
            SearchView().tabItem { Label("TABBAR_SEARCH", systemImage: "magnifyingglass") }
            HistoryView().tabItem { Label("TABBAR_HISTORY", systemImage: "clock") }
        }
        .onAppear {
            // Change language if it was previously set to russian or korean
            if let lang: RAISALanguage = RAISALanguage(rawValue: UserDefaults.standard.integer(forKey: "chosenRaisaLanguage")),
               !RAISALanguage.allSupportedCases.contains(lang) {
                UserDefaults.standard.setValue(0, forKey: "chosenRaisaLanguage")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
