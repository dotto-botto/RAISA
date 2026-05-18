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
    @State private var totalImagesSize: Double = 0
    @State private var totalSubtitlesSize: Double = 0
    
    @State private var listConf = false
    @State private var articleConf = false
    @State private var allDataConf = false
    @State private var imagesConf = false
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
                HStack {
                    Text("IMAGES_SIZE")
                    Spacer()
                    let cacheStr = String(format: "%.1f", totalImagesSize)
                    Text("MB_SYMBOL\(cacheStr)")
                }
                
                HStack {
                    Text("SUBTITLES_SIZE")
                    Spacer()
                    let cacheStr = String(format: "%.1f", totalSubtitlesSize)
                    Text("MB_SYMBOL\(cacheStr)")
                }
                                
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
                        con.deleteAllArticles()
                    }
                }
                
                Button("DELETE_ALL_IMAGES") {
                    imagesConf = true
                }.confirmationDialog("ASSURANCE", isPresented: $imagesConf) {
                    Button("ASSURANCE", role: .destructive) {
                        Article.deleteAllImages()
                        totalImagesSize = 0
                    }
                }
                
                Button("DELETE_ALL_DATA") {
                    allDataConf = true
                }.confirmationDialog("ASSURANCE", isPresented: $allDataConf) {
                    Button("ASSURANCE", role: .destructive) {
                        con.deleteAllData()
                        Article.deleteAllImages()
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
            
            // Articles
            if let imagesDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
                .first?
                .appendingPathComponent("Articles") {
                
                let resourceKeys: Set<URLResourceKey> = [.fileSizeKey, .isRegularFileKey]
                
                let enumerator = FileManager.default.enumerator(
                    at: imagesDirectory,
                    includingPropertiesForKeys: Array(resourceKeys),
                    options: [],
                    errorHandler: { (url, error) -> Bool in
                        print("Error at \(url): \(error)")
                        return true
                    }
                )

                var totalSize: Int = 0
                
                if let enumerator {
                    for case let fileURL as URL in enumerator {
                        do {
                            let resourceValues = try fileURL.resourceValues(forKeys: resourceKeys)
                            if resourceValues.isRegularFile ?? false {
                                totalSize += Int(resourceValues.fileSize ?? 0)
                            }
                        } catch {
                            continue
                        }
                    }
                }
                
                totalImagesSize = Double(totalSize) / 1024 / 1024
            }
            
            // Subtitles
            if let imagesDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
                .first?
                .appendingPathComponent("Subtitles") {
                
                let resourceKeys: Set<URLResourceKey> = [.fileSizeKey, .isRegularFileKey]
                
                let enumerator = FileManager.default.enumerator(
                    at: imagesDirectory,
                    includingPropertiesForKeys: Array(resourceKeys),
                    options: [],
                    errorHandler: { (url, error) -> Bool in
                        print("Error at \(url): \(error)")
                        return true
                    }
                )

                var totalSize: Int = 0
                
                if let enumerator {
                    for case let fileURL as URL in enumerator {
                        do {
                            let resourceValues = try fileURL.resourceValues(forKeys: resourceKeys)
                            if resourceValues.isRegularFile ?? false {
                                totalSize += Int(resourceValues.fileSize ?? 0)
                            }
                        } catch {
                            continue
                        }
                    }
                }
                
                totalSubtitlesSize = Double(totalSize) / 1024 / 1024
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
        (PersistenceController.shared.getAllArticles() ?? [])
            .filter { $0.completed }
            .map { Article(fromEntity: $0)?.url.formatted() ?? "" }
    }
}

struct StorageView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            StorageView()
        }
    }
}
