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
    var body: some View {
        NavigationSplitView {
            ContentView()
        } detail: {
            NavigationStack(path: $path) {
                ArticleView(scpquery: "5000")
            }
        }
    }
//    @State var query: String
//    private var path: savedscps = []
//    var body: some View {
//        NavigationStack(path: HomeView) {
//            List {
////                Text("Search!")
////                TextField("SCP-2317, 2317, Tufto's Proposal", text: $query,).textFieldStyle(.roundedBorder)
//                NavigationLink("",value: <#T##P?#>)
//            }
//            .navigationDestination
//        }
//
//    }
}
