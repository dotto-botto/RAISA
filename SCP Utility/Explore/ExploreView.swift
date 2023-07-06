//
//  ExploreView.swift
//  SCP Utility
//
//  Created by Maximus Harding on 3/9/23.
//

import SwiftUI

/// The first view that the user sees on app startup.
/// This view links to several other views, and allows the user to change the settings and language of the app.
struct ExploreView: View {
    @State private var settings: Bool = false
    @State private var language: Bool = false
    @State private var editor: Bool = false
    
    @State private var connected: Bool = true
    @EnvironmentObject var networkMonitor: NetworkMonitor
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 40) {
                    if connected {
                        RandomCard().clipped()
                        ResumeCard()
                        SeriesCard()
                        TopCard()
                    } else {
                        VStack {
                            Image(systemName: "wifi.slash")
                            Text("USER_OFFLINE")
                        }
                        .padding(.vertical, 300)
                        .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal, 40)
            }
            .onAppear { connected = networkMonitor.isConnected }
            .onChange(of: networkMonitor.isConnected) { bool in
                connected = bool
            }
            .navigationTitle("RAISA_HEADER")
            .toolbar {
//                ToolbarItemGroup(placement: .navigationBarLeading) {
//                    Button {
//                        editor = true
//                    } label: {
//                        Image(systemName: "plus")
//                    }
//                }
                
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button {
                        settings = true
                    } label: {
                        Image(systemName: "gear")
                    }
                }
            }
            .fullScreenCover(isPresented: $settings) { NavigationStack { SettingsView() } }
            .fullScreenCover(isPresented: $editor) { NavigationStack { EditorView() } }
        }
    }
}

struct ExploreView_Previews: PreviewProvider {
    static let networkMonitor = NetworkMonitor()
    static var previews: some View {
        ExploreView().environmentObject(networkMonitor)
    }
}
