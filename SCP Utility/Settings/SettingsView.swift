//
//  SettingsView.swift
//  SCP Utility
//
//  Created by Maximus Harding on 3/9/23.
//

import SwiftUI
import Kingfisher

/// View that displays a settings menu to the user.
struct SettingsView: View {
    @AppStorage("trackHistory") var trackHistory = true
    @AppStorage("trackSearchHistory") var trackSearchHistory = true
    @AppStorage("articleViewSetting") var articleViewSetting = 0
    @AppStorage("showImages") var showImages = true
    @AppStorage("defaultOpen") var defaultOpen = 0
    @AppStorage("storeIcloud") var storeIcloud = true
    @AppStorage("autoScroll") var autoScroll = true
    @AppStorage("showComponentPrompt") var showComponentPrompt = true
    
    @State private var historyConf = false
    @Environment(\.dismiss) private var dismiss

    let con = PersistenceController.shared
    let defaults = UserDefaults.standard
    var body: some View {
        Form {
            Section("SUPPORT_OPTIONS") {
                HStack {
                    Link("SUPPORT_RAISA_PROMPT", destination: URL(string: "https://patreon.com/RAISAapp")!)
                    Spacer()
                    Image(systemName: "chevron.right").foregroundColor(.secondary)
                }
                .foregroundColor(.primary)

                HStack {
                    Link("SUPPORT_CROM_PROMPT", destination: URL(string: "https://www.patreon.com/crombird")!)
                    Spacer()
                    Image(systemName: "chevron.right").foregroundColor(.secondary)
                }
                .foregroundColor(.primary)
            }
            
            Section("GENERAL_OPTIONS") {
                NavigationLink("MANAGE_STORAGE") {
                    StorageView()
                }
            }
            
            Section("READER_OPTIONS") {
                Picker("DEFAULT_OPEN_SETTING", selection: $defaultOpen) {
                    Text("BAR_SETTING").tag(0)
                    Text("READER_SETTING").tag(1)
                    Text("BOTH").tag(2)
                }
                Picker("DEFAULT_READER_SETTING", selection: $articleViewSetting) {
                    Text("PARSED_SOURCE_SETTING").tag(0)
                    Text("RAW_SOURCE_SETTING").tag(1)
                    Text("SAFARI_SETTING").tag(2)
                }
                Toggle("SHOW_IMAGES", isOn: $showImages)
                Toggle("AUTO_SCROLL_SETTING", isOn: $autoScroll)
                Toggle("DETECT_COMPONENTS_SETTING", isOn: $showComponentPrompt)
                Button("REMOVE_BAR_ITEMS_SETTING") {
                    defaults.set("", forKey: "articleBarIds")
                }
            }
            
            Section("ICLOUD") {
                Toggle("UPLOAD_ICLOUD", isOn: $storeIcloud)
            }
            
            Section("HISTORY_OPTIONS") {
                Toggle("TRACK_HISTORY", isOn: $trackHistory)
                Toggle("TRACK_SEARCH_HISTORY", isOn: $trackSearchHistory)
                Button("DELETE_ALL_HISTORY") {
                    historyConf = true
                }.confirmationDialog("ASSURANCE", isPresented: $historyConf) {
                    Button("ASSURANCE", role: .destructive) {
                        con.deleteAllHistory()
                    }
                }
            }
        }
        .navigationTitle("SETTINGS_TITLE")
        .toolbar {
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
            }
        }
    }
}


struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack { SettingsView() }
    }
}
