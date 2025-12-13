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
    @State private var signInSheet: Bool = false
    
    @State private var connected: Bool = true
    @State private var userIntBranch = RAISALanguage(rawValue: UserDefaults.standard.integer(forKey: "chosenRaisaLanguage")) ?? .english
    @EnvironmentObject var networkMonitor: NetworkMonitor
    @EnvironmentObject var loginMonitor: LoginMonitor
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 40) {
                    if connected {
                        if RAISALanguage.allSupportedCases.contains(userIntBranch) {
                            RandomCard().clipped()
                        }
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
//                if loginMonitor.isLoggedIn {
//                    ToolbarItemGroup(placement: .navigationBarTrailing) {
//                        Button {
//                            
//                        } label: {
//                            Image(systemName: "person.crop.circle")
//                        }
//                    }
//                } else {
//                    ToolbarItemGroup(placement: .navigationBarTrailing) {
//                        Button {
//                            signInSheet = true
//                        } label: {
//                            Text("SIGN_IN")
//                        }
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
            .sheet(isPresented: $signInSheet) { NavigationStack { LoginView() } }
        }
    }
}

struct ExploreView_Previews: PreviewProvider {
    static let networkMonitor = NetworkMonitor()
    static let loginMonitor = LoginMonitor()
    static var previews: some View {
        ExploreView()
            .environmentObject(networkMonitor)
            .environmentObject(loginMonitor)
    }
}
