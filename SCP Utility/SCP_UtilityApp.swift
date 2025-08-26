//
//  SCP_UtilityApp.swift
//  SCP Utility
//
//  Created by Maximus Harding on 1/1/23.
//

import SwiftUI
import Kingfisher
import Network

@main
struct SCP_UtilityApp: App {
    @State private var showSheet: Bool = false
    @Environment(\.scenePhase) var scenePhase
    @Environment(\.managedObjectContext) var Context
    @AppStorage("isFirstLaunch") var isFirstLaunch = true
    @StateObject var networkMonitor = NetworkMonitor()
    let con = PersistenceController.shared
    var body: some Scene {
        WindowGroup {
            ContentView().environment(\.managedObjectContext, con.container.viewContext)
                .environmentObject(networkMonitor)
                .onAppear {
                    if isFirstLaunch {
                        showSheet = true // tutorial sheet
                        
                        // Don't cache images on disk
                        ImageCache.default.diskStorage.config.sizeLimit = 1
                        let defaults = UserDefaults.standard
                        defaults.set(true, forKey: "trackHistory")
                        defaults.set(true, forKey: "showAVWallpaper")
                        defaults.set(true, forKey: "bookmarkAlert")
                        defaults.set(true, forKey: "downloadImages")
                        defaults.set(true, forKey: "trackSearchHistory")
                        defaults.set(RAISALanguage.english.rawValue, forKey: "chosenRaisaLanguage")
                        
                    }
                    isFirstLaunch = false
                }
                .sheet(isPresented: $showSheet) {
                    WelcomeView().interactiveDismissDisabled()
                }
        }
        .onChange(of: scenePhase) { _ in
            con.save()
        }
    }
}

class NetworkMonitor: ObservableObject {
    private let networkMonitor = NWPathMonitor()
    private let workerQueue = DispatchQueue(label: "Monitor")
    var isConnected = false

    init() {
        networkMonitor.pathUpdateHandler = { path in
            self.isConnected = path.status == .satisfied
            Task {
                await MainActor.run {
                    self.objectWillChange.send()
                }
            }
        }
        networkMonitor.start(queue: workerQueue)
    }
}
