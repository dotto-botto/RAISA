//
//  ListView.swift
//  SCP Wiki Utility
//
//  Created by Maximus Harding on 12/25/22.
//

import SwiftUI

// MARK: - Many List View

/// View that displays all stored lists in core data as ListRow views.
struct ListView: View {
    @State private var alertPresent: Bool = false
    @State private var presentSheet: Bool = false
    @State private var query: String = ""
    @State private var currentList: SCPList = SCPList(listid: "Placeholder")
    @State private var items = PersistenceController.shared.getAllLists()
    var body: some View {
        let con = PersistenceController.shared
        let builtInLists = {
            NavigationLink {
                OneListView(list: SCPList()).navigationTitle("ALL_SAVED_ARTICLES")
            } label: {
                HStack {
                    VStack(alignment: .leading) {
                        Text("ALL_SAVED_ARTICLES")
                            .foregroundColor(.accentColor)
                            .lineLimit(1)
                        Text("ALL_SAVED_ARTICLES_SUBTITLE")
                            .foregroundColor(.secondary)
                            .font(.system(size: 13))
                            .lineLimit(1)
                    }
                }
            }
        }
        
        NavigationStack {
            VStack {
                if items == nil || (items ?? []).isEmpty {
                    List { builtInLists() }
                }
                
                List(items ?? []) { item in
                    if item.identifier == items!.first!.identifier {
                        builtInLists()
                    }
                    
                    ListRow(fromEntity: item)
                }
            }
            .listStyle(.plain)
            .navigationTitle("LIST_TITLE")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        presentSheet = true
                    } label: {
                        Label("ALL_SAVED_ARTICLES", systemImage: "magnifyingglass")
                    }
                }
                
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        alertPresent = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    .alert("ADD_LIST_PROMPT", isPresented: $alertPresent) {
                        TextField("", text: $query)
                        
                        Button("ADD") {
                            con.createListEntity(list: SCPList(listid: query))
                            items = con.getAllLists()
                            alertPresent = false
                            query = ""
                        }
                        Button("CANCEL", role: .cancel) {
                            alertPresent = false
                            query = ""
                        }
                    }
                }

            }
            .sheet(isPresented: $presentSheet) { OneListView(list: SCPList()) }
            .onAppear {
                items = con.getAllLists()
            }
        }
    }
}


// MARK: - Single List View

/// View that displays the articles stored in an SCPList.
struct OneListView: View {
    @State var list: SCPList
    @State private var query: String = ""
    @State private var articles: [Article] = []
    
    @State private var listTitlePresent: Bool = false
    @State private var listSubtitlePresent: Bool = false
    @State private var updateQuery: String = ""
    
    @State private var sort: Int = 0
    @State private var ascending: Bool = false
    // 0 - Default (Every saved article)
    // 1 - Every article that the user has marked as complete.
    // 2 - Every article that the user hasn't marked as complete.
    @State private var mode: Int = 0
    var body: some View {
        VStack {
            if articles.isEmpty {
                VStack {
                    Spacer()
                    Text("NO_ARTICLES_IN_LIST")
                        .font(.title)
                        .foregroundColor(.secondary)
                    Text("LIST_ADD_GUIDE")
                        .foregroundColor(.secondary)
                    Spacer()
                }
                .padding(.horizontal, 30)
                
            } else {
                List(articles) { article in
                    ArticleRow(passedSCP: article)
                        .swipeActions(edge: .leading) {
                            Button(role: .destructive) {
                                list.removeContent(id: article.id)
                            } label: {
                                Label("REMOVE_FROM_\(list.listid)", systemImage: "minus.circle")
                            }
                        }
                }
            }
        }
        .navigationTitle(list.listid)
        .task { updateArticles() }
        .searchable(text: $query, placement: .navigationBarDrawer(displayMode: .always))
        .onAppear {
            if let scplistentity = PersistenceController.shared.getListByID(id: list.id), let scplist = SCPList(fromEntity: scplistentity) {
                list = scplist
            }
        }
        .onChange(of: query) { _ in
            updateArticles()
            articles = articles.filter{ query.isEmpty ? true : $0.title.lowercased().contains(query.lowercased()) }
        }
        .onChange(of: mode) { _ in
            updateArticles()
            self.articles = articles
                .filter {
                    switch mode {
                    case 0: return true
                    case 1: return $0.completed ?? false
                    case 2: return !($0.completed ?? false)
                    default: return true
                    }
                }
        }
        .onChange(of: sort) { _ in
            updateArticles()
            self.articles = articles
                .sorted {
                    if sort == 0 {
                        return true
                    } else if sort == 1 {
                        return $0.title.lowercased() < $1.title.lowercased()
                    } else {
                        return true
                    }
                }
        }
        .onChange(of: ascending) { _ in
            self.articles.reverse()
        }
        .toolbar {
            ToolbarItemGroup(placement: .secondaryAction) {
                Menu {
                    Button {
                        mode = 0
                    } label: {
                        HStack {
                            Text("ALL_SAVED_ARTICLES")
                            Spacer()
                            if mode == 0 {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                    Button {
                        mode = 1
                    } label: {
                        HStack {
                            Text("ALL_READ_ARTICLES")
                            Spacer()
                            if mode == 1 {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                    Button {
                        mode = 2
                    } label: {
                        HStack {
                            Text("ALL_UNREAD_ARTICLES")
                            Spacer()
                            if mode == 2 {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                } label: {
                    Text("FILTER")
                }
                                
                if list.contents != SCPList().contents {
                    Divider()

                    Button {
                        listTitlePresent = true
                    } label: {
                        Label("CHANGE_LIST_TITLE", systemImage: "pencil")
                    }
                    Button {
                        listSubtitlePresent = true
                    } label: {
                        Label("CHANGE_LIST_SUBTITLE", systemImage: "pencil.line")
                    }
                }
            }
            
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Menu {
                    Button {
                        sort = 0
                    } label: {
                        Text("DATE_ADDED")
                        if sort == 0 {
                            Image(systemName: "checkmark")
                        }
                    }
                    
                    Button {
                        sort = 1
                    } label: {
                        Text("ALPHABETICAL")
                        if sort == 1 {
                            Image(systemName: "checkmark")
                        }
                    }
                } label: {
                    Image(systemName: "line.3.horizontal.decrease")
                }
                
                Button {
                    ascending.toggle()
                } label: {
                    Image(systemName: ascending ? "arrow.up" : "arrow.down")
                }
            }
        }
        .alert("CHANGE_LIST_TITLE", isPresented: $listTitlePresent) {
            TextField(list.listid, text: $updateQuery)
            
            Button("CHANGE") {
                list.updateTitle(newTitle: updateQuery)
                listTitlePresent = false
                query = ""
            }
            Button("CANCEL", role: .cancel) {
                listTitlePresent = false
                query = ""
            }
        }
        .alert("CHANGE_LIST_SUBTITLE", isPresented: $listSubtitlePresent) {
            TextField(list.subtitle ?? "", text: $updateQuery)
            
            Button("CHANGE") {
                list.updateSubtitle(newTitle: updateQuery)
                listSubtitlePresent = false
                query = ""
            }
            Button("CANCEL", role: .cancel) {
                listSubtitlePresent = false
                query = ""
            }
        }
        Spacer()
    }
    
    private func updateArticles() {
        var articlelist: [Article] = []
        for article in PersistenceController.shared.getAllListArticles(list: self.list) ?? [] {
            if let article = Article(fromEntity: article) {
                articlelist.append(article)
            }
        }
        
        self.articles = articlelist
    }
}

struct ListView_Previews: PreviewProvider {
    static var previews: some View {
        ListView()
        
        NavigationStack {
            OneListView(list: SCPList(listid: "Hollow Purple"))
        }
    }
}
