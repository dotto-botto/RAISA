//
//  SettingsView.swift
//  SCP Utility
//
//  Created by Maximus Harding on 3/9/23.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("trackHistory") var trackHistory = true
    @AppStorage("articleViewSetting") var articleViewSetting = 0
    @AppStorage("showImages") var showImages = true
    
    let con = PersistenceController.shared
    var body: some View {
        Form {
            Section(header: Text("READER_OPTIONS")) {
                Picker("DEFAULT_READER_SETTING", selection: $articleViewSetting) {
                    Text("PARSED_SOURCE_SETTING").tag(0)
                    Text("RAW_SOURCE_SETTING").tag(1)
                    Text("SAFARI_SETTING").tag(2)
                }
                Toggle("SHOW_IMAGES", isOn: $showImages)
            }
            
            Section(header: Text("HISTORY_OPTIONS")) {
                Toggle("TRACK_HISTORY", isOn: $trackHistory)
                Button("DELETE_ALL_HISTORY") { con.deleteAllHistory() }
            }
            
            Section(header: Text("DATA_OPTIONS")) {
                Button("DELETE_ALL_LISTS") { con.deleteAllLists() }
                Button("DELETE_ALL_ARTICLES") { con.deleteAllArticles() }
                Button("DELETE_ALL_DATA") { con.deleteAllData() }
            }
        }
        .navigationTitle("SETTINGS_TITLE")
    }
}


struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
