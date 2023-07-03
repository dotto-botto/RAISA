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
    @State private var completedConf: Bool = false
    @State private var completed: [String] = UserDefaults.standard.stringArray(forKey: "completedArticles") ?? []
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
                NavigationLink("MANAGE_READ_ARTICLES") {
                    VStack {
                        if completed.isEmpty {
                            VStack {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 40))
                                    .padding(.bottom, 10)
                                Text("NO_READ_ARTICLES")
                            }
                            .foregroundColor(.secondary)
                        } else {
                            List(completed, id: \.self) { url in
                                Text(url)
                                    .swipeActions {
                                        Button(role: .destructive) {
                                            completed = completed.filter { $0 != url }
                                        } label: {
                                            Image(systemName: "trash")
                                        }
                                    }
                            }
                            .toolbar {
                                ToolbarItem(placement: .bottomBar) {
                                    Button("DELETE_ALL") {
                                        completedConf = true
                                    }
                                    .confirmationDialog("ASSURANCE", isPresented: $completedConf) {
                                        Button("ASSURANCE", role: .destructive) {
                                            completed = []
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .navigationTitle("COMPLETED_ARTICLES")
                    .onChange(of: completed) {
                        UserDefaults.standard.set($0, forKey: "completedArticles")
                    }
                }
                
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
