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
    @AppStorage("defaultOpen") var defaultOpen = 0
    @AppStorage("storeIcloud") var storeIcloud = true
    @AppStorage("autoOpen") var autoOpen = true
    
    @State private var historyConf = false
    @State private var listConf = false
    @State private var articleConf = false
    @State private var allDataConf = false
    @State private var raisaView = false
    @State private var cromView = false
    @Environment(\.dismiss) private var dismiss

    let con = PersistenceController.shared
    let defaults = UserDefaults.standard
    var body: some View {
        Form {
            Section("Support") {
                HStack {
                    Button("Support the RAISA Creator") {
                        raisaView = true
                    }.foregroundColor(.primary)
                    Spacer()
                    Image(systemName: "chevron.right").foregroundColor(.secondary)
                }
                
                HStack {
                    Button("Support the CROM Creator") {
                        cromView = true
                    }.foregroundColor(.primary)
                    Spacer()
                    Image(systemName: "chevron.right").foregroundColor(.secondary)
                }
            }
            
            Section("GENERAL_OPTIONS") {
                Toggle("OPEN_LAST_READ_OPTION", isOn: $autoOpen)
            }
            
            Section("READER_OPTIONS") {
                Picker("Open Articles In", selection: $defaultOpen) {
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
                Button("Remove All Bar Items") {
                    defaults.set("", forKey: "articleBarIds")
                }
            }
            
            Section("ICLOUD") {
                Toggle("UPLOAD_ICLOUD", isOn: $storeIcloud)
            }
            
            Section("HISTORY_OPTIONS") {
                Toggle("TRACK_HISTORY", isOn: $trackHistory)
                Button("DELETE_ALL_HISTORY") {
                    historyConf = true
                }.confirmationDialog("ASSURANCE", isPresented: $historyConf) {
                    Button("ASSURANCE", role: .destructive) {
                        con.deleteAllHistory()
                    }
                }
            }
            
            Section("DATA_OPTIONS") {
                Button("DELETE_ALL_LISTS") {
                    listConf = true
                }.confirmationDialog("DELETE_LIST_TOOLTIP", isPresented: $listConf, titleVisibility: .visible) {
                    Button("DELETE", role: .destructive) {
                        con.deleteAllLists()
                    }
                }
                Button("DELETE_ALL_ARTICLES") {
                    articleConf = true
                }.confirmationDialog("ASSURANCE", isPresented: $articleConf) {
                    Button("ASSURANCE", role: .destructive) {
                        con.deleteAllLists()
                    }
                }
                   
                Button("DELETE_ALL_DATA") {
                    allDataConf = true
                }.confirmationDialog("ASSURANCE", isPresented: $allDataConf) {
                    Button("ASSURANCE", role: .destructive) {
                        con.deleteAllData()
                    }
                }
            }
        }
        .navigationTitle("SETTINGS_TITLE")
        .alert("You can't donate yet.", isPresented: $raisaView) {
        } message: {
            Text("Thank you for downloading the app!")
        }
        .toolbar {
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
            }
        }
        .fullScreenCover(isPresented: $cromView) {
            SFSafariViewWrapper(url: URL(string: "https://www.patreon.com/crombird")!)
        }
    }
}


struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack { SettingsView() }
    }
}
