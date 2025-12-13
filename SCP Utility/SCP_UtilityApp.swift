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
    @StateObject var subtitlesStore = SubtitlesStore()
    @StateObject var loginMonitor = LoginMonitor()
    let con = PersistenceController.shared
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, con.container.viewContext)
                .environmentObject(networkMonitor)
                .environmentObject(subtitlesStore)
                .environmentObject(loginMonitor)
                .onAppear {
                    RaisaReq.scrapeSubtitles(store: subtitlesStore, series: LATEST_SERIES)
                    
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
                        
                        // Scrape all subtitles
                        RaisaReq.scrapeSubtitles(store: subtitlesStore)
                    }
                    isFirstLaunch = false
                }
                .sheet(isPresented: $showSheet) {
                    WelcomeView()
                        .interactiveDismissDisabled()
                        .environmentObject(subtitlesStore)
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

class SubtitlesStore: ObservableObject {
    var seriesSubtitles: [String:String] = [:]
    init() {
        loadsubtitles()
    }
    
    func loadsubtitles() {
        // Load all subtitles into memory
        do {
            guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
            
            guard let lang = RAISALanguage(rawValue: UserDefaults.standard.integer(forKey: "chosenRaisaLanguage")) else { return }
            
            let subtitledir = documentsDirectory
                .appendingPathComponent("Subtitles")
                .appendingPathComponent(lang.toAbbr())
            
            let contents = try FileManager.default.contentsOfDirectory(at: subtitledir, includingPropertiesForKeys: nil)
            for file in contents {
                let subtitlelist = try Dictionary(uniqueKeysWithValues: String(contentsOf: file)
                    .components(separatedBy: .newlines)
                    .compactMap { item in
                        let components = item.split(separator: ", ", maxSplits: 1)
                        guard components.count == 2 else { return ("","") }
                        // Remove end quotes
                        let subtitle: String = String(String(components[1])
                                .dropFirst()
                                .dropLast())
                        return (String(components[0]), subtitle)
                    })
                                                  
                seriesSubtitles.merge(subtitlelist, uniquingKeysWith: {_, newvalue in newvalue})
            }
        } catch {
            print("Error retrieving subtitles: \(error.localizedDescription)")
        }
    }
}

class LoginMonitor: ObservableObject {
    @Published var isLoggedIn: Bool = false
    
    init() {
        
    }
}
