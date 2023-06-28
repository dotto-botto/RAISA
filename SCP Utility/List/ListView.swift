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
                AllArticleView().navigationTitle("ALL_SAVED_ARTICLES")
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
            .sheet(isPresented: $presentSheet) { AllArticleView() }
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
    
    @State private var listTitlePresent: Bool = false
    @State private var listSubtitlePresent: Bool = false
    @State private var updateQuery: String = ""
    
    var body: some View {
        if list.contents != nil {
            let con = PersistenceController.shared
            var articles = con.getAllListArticles(list: list)!
            
            VStack {
                List {
                    ForEach(articles, id: \.self) { article in
                        if let article = Article(fromEntity: article) {
                            let button = Button {
                                list.removeContent(id: article.id)
                            } label: {
                                Label("REMOVE_FROM_\(list.listid)", systemImage: "minus.circle")
                            }
                            
                            ArticleRow(passedSCP: article)
                                .swipeActions(edge: .leading) { button }
                        }
                    }
                }
            }
            .navigationTitle(list.listid)
            .searchable(text: $query, placement: .navigationBarDrawer(displayMode: .always))
            .onAppear {
                if let scplistentity = con.getListByID(id: list.id), let scplist = SCPList(fromEntity: scplistentity) {
                    list = scplist
                }
            }
            .onChange(of: query) { _ in
                articles = articles.filter{ query.isEmpty ? true : $0.title?.lowercased().contains(query.lowercased()) ?? false }
            }
            .toolbar {
                ToolbarItemGroup(placement: .secondaryAction) {
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
        } else {
            Spacer()
            Text("NO_ARTICLES_IN_LIST")
                .font(.largeTitle)
                .foregroundColor(.gray)
            Text("LIST_ADD_GUIDE")
                .foregroundColor(.gray)
            Spacer()
        }
    }
}

struct ListView_Previews: PreviewProvider {
    static var previews: some View {
        ListView()
    }
}
