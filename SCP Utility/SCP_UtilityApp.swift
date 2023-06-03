//
//  SCP_UtilityApp.swift
//  SCP Utility
//
//  Created by Maximus Harding on 1/1/23.
//

import SwiftUI
import Kingfisher

@main
struct SCP_UtilityApp: App {
    @Environment(\.scenePhase) var scenePhase
    @Environment(\.managedObjectContext) var Context
    @AppStorage("isFirstLaunch") var isFirstLaunch = true
    let con = PersistenceController.shared
    var body: some Scene {
        WindowGroup {
            ContentView().environment(\.managedObjectContext, con.container.viewContext)
                .onAppear {
                    if isFirstLaunch {
                        // Don't cache images on disk
                        ImageCache.default.diskStorage.config.sizeLimit = 1
                        
                        UserDefaults.standard.register(defaults: [
                            "trackHistory" : true,
                            "articleViewSetting" : 0,
                            "showImages" : true,
                            "defaultOpen" : 0,
                            "storeIcloud" : true,
                            "autoScroll" : true,
                            "showComponentPrompt" : true,
                        ])
                    }
                    isFirstLaunch = false
                }
        }
        .onChange(of: scenePhase) { _ in
            con.save()
        }
    }
}
