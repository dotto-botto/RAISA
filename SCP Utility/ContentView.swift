//
//  ContentView.swift
//  SCP Wiki Utility
//
//  Created by Maximus Harding on 12/25/22.
//

import SwiftUI

struct ContentView: View {
    @State private var tabSelection = 1
    @EnvironmentObject var networkMonitor: NetworkMonitor
    var body: some View {
        TabView(selection: $tabSelection) {
            ExploreView()
                .tabItem { Label("TABBAR_EXPLORE", systemImage: "globe") }
                .tag(1)
            
            ListView()
                .tabItem { Label("TABBAR_LIST", systemImage: "bookmark") }
                .tag(2)

            SearchView()
                .tabItem { Label("TABBAR_SEARCH", systemImage: "magnifyingglass") }
                .tag(3)

            HistoryView()
                .tabItem { Label("TABBAR_HISTORY", systemImage: "clock") }
                .tag(4)
        }
        .onAppear {
            // Change language if it was previously set to russian or korean
            if let lang: RAISALanguage = RAISALanguage(rawValue: UserDefaults.standard.integer(forKey: "chosenRaisaLanguage")),
               !RAISALanguage.allSupportedCases.contains(lang) {
                UserDefaults.standard.setValue(0, forKey: "chosenRaisaLanguage")
            }
            
            if !networkMonitor.isConnected {
                tabSelection = 2
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
