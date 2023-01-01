//
//  ContentView.swift
//  SCP Wiki Utility
//
//  Created by Maximus Harding on 12/25/22.
//
// Inspired by The Wikipedia App
// https://github.com/wikimedia/wikipedia-ios/tree/main/Wikipedia/Code

import SwiftUI
import UIKit

struct ContentView: View {
    var body: some View {
        TabView(selection: .constant(1)) {
            HomeView().tabItem { Label("Home", systemImage: "house")  }.tag(1)
            ListView().tabItem { Label("Lists", systemImage: "bookmark")  }.tag(2)
            HistoryView().tabItem { Label("History", systemImage: "clock")  }.tag(3)
            SearchView().tabItem { Label("Search", systemImage: "magnifyingglass")  }.tag(4)
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
