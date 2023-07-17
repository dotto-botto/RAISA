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
                CompletedArticlesView()
                
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

struct CompletedArticlesView: View {
    @State private var completedConf: Bool = false
    @State private var completed: [String] = []
    @State private var query: String = ""
    var body: some View {
        NavigationLink("MANAGE_READ_ARTICLES") {
            VStack {
                if completed.isEmpty && query.isEmpty {
                    VStack {
                        Image(systemName: "checkmark")
                            .font(.system(size: 40))
                            .padding(.bottom, 10)
                        Text("NO_READ_ARTICLES")
                    }
                    .foregroundColor(.secondary)
                } else {
                    if completed.isEmpty && !query.isEmpty {
                        Text("NO_RESULTS_FOR_\(query)")
                            .bold()
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 10)
                    }
                    
                    List(completed, id: \.self) { url in
                        Text(url)
                            .swipeActions {
                                Button(role: .destructive) {
                                    completed = completed.filter { $0 != url }
                                    UserDefaults.standard.set(completed, forKey: "completedArticles")
                                } label: {
                                    Image(systemName: "trash")
                                }
                            }
                    }
                    .searchable(text: $query, placement: .navigationBarDrawer(displayMode: .always))
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("DELETE_ALL") {
                                completedConf = true
                            }
                            .confirmationDialog("ASSURANCE", isPresented: $completedConf) {
                                Button("ASSURANCE", role: .destructive) {
                                    completed = []
                                    UserDefaults.standard.set(completed, forKey: "completedArticles")
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("COMPLETED_ARTICLES")
            .task { updateCompleted() }
            .onChange(of: query) { _ in
                updateCompleted()
                if query != "" {
                    completed = completed.filter { $0.contains(query.lowercased()) }
                }
            }
        }
    }
    
    func updateCompleted() {
        self.completed =
        (UserDefaults.standard.stringArray(forKey: "completedArticles") ?? []) +
        (PersistenceController.shared.getAllArticles() ?? []).map { Article(fromEntity: $0)?.url.formatted() ?? "" }
    }
}

struct StorageView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            StorageView()
        }
    }
}
