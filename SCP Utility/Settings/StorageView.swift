//
//  StorageView.swift
//  SCP Utility
//
//  Created by Maximus Harding on 6/9/23.
//

import SwiftUI
import Kingfisher

struct StorageView: View {
    @State private var diskCacheSize: Double = 0
    
    @State private var listConf = false
    @State private var articleConf = false
    @State private var allDataConf = false
    let con = PersistenceController.shared
    var body: some View {
        Form {
            Section("CACHE") {
                HStack {
                    Text("CACHE_SIZE")
                    Spacer()
                    let cacheStr = String(format: "%.1f", diskCacheSize)
                    Text("MB_SYMBOL\(cacheStr)")
                }
                
                Button("CLEAR_CACHE") {
                    ImageCache.default.clearDiskCache()
                    diskCacheSize = 0
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
        .navigationTitle("SV_TITLE")
        .onAppear {
            ImageCache.default.calculateDiskStorageSize { result in
                switch result {
                case .success(let size):
                    diskCacheSize = Double(size) / 1024 / 1024
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
}

struct StorageView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            StorageView()
        }
    }
}
