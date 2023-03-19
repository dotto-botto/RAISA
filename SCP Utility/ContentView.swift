//
//  ContentView.swift
//  SCP Wiki Utility
//
//  Created by Maximus Harding on 12/25/22.
//

import SwiftUI

struct ContentView: View {
    
    enum Tab {
        case home
        case list
        case history
        case search
        case settings
    }
    
    @State private var selection: Tab = .home
    
    var body: some View {
        TabView(selection: $selection) {
            ExploreView()
            .tabItem { Label("TABBAR_EXPLORE", systemImage: "globe") }.tag(Tab.home)
            ListView()
            .tabItem { Label("TABBAR_LIST", systemImage: "bookmark")  }.tag(Tab.list)
            SearchView()
            .tabItem { Label("TABBAR_SEARCH", systemImage: "magnifyingglass")  }.tag(Tab.search)
            HistoryView()
            .tabItem { Label("TABBAR_HISTORY", systemImage: "clock")  }.tag(Tab.history)
            SettingsView()
            .tabItem { Label("TABBAR_SETTINGS", systemImage: "gearshape")  }.tag(Tab.settings)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
