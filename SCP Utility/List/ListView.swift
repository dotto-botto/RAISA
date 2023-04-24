//
//  ListView.swift
//  SCP Wiki Utility
//
//  Created by Maximus Harding on 12/25/22.
//

import SwiftUI
import Foundation

// MARK: - Many List View
struct ListView: View {
    @State private var alertPresent: Bool = false
    @State private var listTitlePresent: Bool = false
    @State private var listSubtitlePresent: Bool = false
    @State private var presentSheet: Bool = false
    @State private var mode: Int = 0
    @State private var query: String = ""
    @State private var currentList: SCPList = SCPList(listid: "Placeholder")
        
    var body: some View {
        let items = PersistenceController.shared.getAllLists()
        let con = PersistenceController.shared
        
        NavigationStack {
            List(items!) { item in
                if let newItem = SCPList(fromEntity: item) {
                    NavigationLink(destination: OneListView(list: newItem)) {
                        VStack(alignment: .leading) {
                            Text(newItem.listid)
                                .lineLimit(1)
                            if newItem.subtitle != nil {
                                Text(newItem.subtitle!)
                                    .foregroundColor(.gray)
                                    .font(.system(size: 13))
                                    .lineLimit(1)
                            } else {
                                Text("SUBTITLE_PLACEHOLDER")
                                    .foregroundColor(.gray)
                                    .font(.system(size: 13))
                                    .lineLimit(1)
                            }
                        }
                    }
                    .swipeActions(allowsFullSwipe: false) {
                        Button(role: .destructive) {
                            con.deleteListEntity(listitem: newItem)
                        } label: { Image(systemName: "trash") }
                    }
                    .contextMenu {
                        Button {
                            listTitlePresent = true
                            currentList = newItem
                        } label: {
                            Label("CHANGE_LIST_TITLE", systemImage: "pencil")
                        }
                        Button {
                            listSubtitlePresent = true
                            currentList = newItem
                        } label: {
                            Label("CHANGE_LIST_SUBTITLE", systemImage: "pencil.line")
                        }
                    }
                }
            }
            .navigationTitle("LIST_TITLE")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        mode = 0
                        if mode == 0 { presentSheet = true }
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
                            alertPresent = false
                            query = ""
                        }
                        Button("CANCEL", role: .cancel) {
                            alertPresent = false
                            query = ""
                        }
                    }
                }
                ToolbarItemGroup(placement: .secondaryAction) {
                    Button {
                        mode = 1
                        if mode == 1 { presentSheet = true }
                    } label: {
                        Label("ALL_READ_ARTICLES", systemImage: "eye")
                    }
                    Button {
                        mode = 2
                        if mode == 2 { presentSheet = true }
                    } label: {
                        Label("ALL_UNREAD_ARTICLES", systemImage: "eye.slash")
                    }
                }
            }
            // Change List Title
            .alert("CHANGE_LIST_TITLE", isPresented: $listTitlePresent) {
                TextField(currentList.listid, text: $query)
                
                Button("CHANGE") {
                    con.updateListTitle(newTitle: query, list: currentList)
                    listTitlePresent = false
                    query = ""
                }
                Button("CANCEL", role: .cancel) {
                    listTitlePresent = false
                    query = ""
                }
            }
            // Change List Subtitle
            .alert("CHANGE_LIST_SUBTITLE", isPresented: $listSubtitlePresent) {
                TextField(currentList.subtitle ?? "", text: $query)
                
                Button("CHANGE") {
                    con.updateListSubtitle(newTitle: query, list: currentList)
                    listSubtitlePresent = false
                    query = ""
                }
                Button("CANCEL", role: .cancel) {
                    listSubtitlePresent = false
                    query = ""
                }
            }
            .sheet(isPresented: $presentSheet) { AllArticleView(mode: mode) }
        }
    }
}


// MARK: - Single List View
struct OneListView: View {
    @State var list: SCPList
    @State private var query: String = ""
    @State private var objFilter: ObjectClass? = nil
    @State private var esoFilter: EsotericClass? = nil
    
    var body: some View {
        if list.contents != nil {
            let con = PersistenceController.shared
            var articles = con.getAllListArticles(list: list)!
            let _ = articles = articles.filter{ query.isEmpty ? true: $0.title?.lowercased().contains(query.lowercased()) ?? false }
            if objFilter != nil { let _ = articles = articles.filter{ $0.objclass == objFilter!.rawValue } }
            if esoFilter != nil { let _ = articles = articles.filter{ $0.esoteric == esoFilter!.rawValue } }
            
            List {
                ForEach(articles, id: \.self) { article in
                    ArticleRow(passedSCP: Article(fromEntity: article)!, localArticle: true)
                        .swipeActions(edge: .leading) {
                            Button {
                                
                            } label: {
                                Image(systemName: "text.badge.minus")
                            }
                        }
                }
            }
            .navigationTitle(list.listid)
            .searchable(text: $query, placement: .navigationBarDrawer(displayMode: .always))
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        Menu("Filter by Object Class") {
                            Picker("", selection: $objFilter) {
                                Label("SAFE", image: "safe-icon").tag(0)
                                Label("EUCLID", image: "euclid-icon").tag(1)
                                Label("KETER", image: "keter-icon").tag(2)
                                Label("NEUTRALIZED", image: "neutralized-icon").tag(3)
                                Label("PENDING", image: "pending-icon").tag(4)
                                Label("EXPLAINED", image: "explained-icon").tag(5)
                                Label("ESOTERIC", image: "esoteric-icon").tag(6)
                            }
                        }
                        Menu("Filter by Esoteric Class") {
                            Picker("", selection: $objFilter) {
                                Label("APOLLYON", image: "apollyon-icon").tag(0)
                                Label("ARCHON", image: "archon-icon").tag(1)
                                Label("CERNUNNOS", image: "cernunnos-icon").tag(2)
                                Label("DECOMMISSIONED", image: "decommissioned-icon").tag(3)
                                Label("HIEMAL", image: "hiemal-icon").tag(4)
                                Label("TIAMAT", image: "tiamat-icon").tag(5)
                                Label("TICONDEROGA", image: "ticonderoga-icon").tag(6)
                                Label("THAUMIEL", image: "thaumiel-icon").tag(7)
                                Label("UNCONTAINED", image: "uncontained-icon").tag(8)
                            }
                        }
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease")
                    }
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
