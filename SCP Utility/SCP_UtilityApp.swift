//
//  SCP_UtilityApp.swift
//  SCP Utility
//
//  Created by Maximus Harding on 1/1/23.
//

import SwiftUI

@main
struct SCP_UtilityApp: App {
    @Environment(\.scenePhase) var scenePhase
    @Environment(\.managedObjectContext) var Context


    let con = PersistenceController.shared
    var body: some Scene {
        WindowGroup {
            ContentView().environment(\.managedObjectContext, con.container.viewContext)
        }
        .onChange(of: scenePhase) { _ in
            con.save()
        }
    }
}
