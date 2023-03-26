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
    @State var alertPresent: Bool = false
    @State var listTitlePresent: Bool = false
    @State var listSubtitlePresent: Bool = false
    
    @State var query: String = ""
    @State var oneList: Bool = false
    @State var currentList: SCPList = SCPList(listid: "Placeholder")
        
    var body: some View {
        let items = PersistenceController.shared.getAllLists()
        let con = PersistenceController.shared
        
        NavigationView {
            if items == nil {
                Text("NEW_LIST_PROMPT").foregroundColor(.gray)
            } else {
                List(items!) { item in
                    let newItem = SCPList(fromEntity: item)
                    
                    if (newItem != nil) {
                        NavigationLink(destination: OneListView(list: newItem!)) {
                            VStack(alignment: .leading) {
                                Text(newItem!.listid)
                                    .lineLimit(1)
                                if newItem!.subtitle != nil {
                                    Text(newItem!.subtitle!)
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
                                con.deleteListEntity(listitem: newItem!)
                            } label: { Image(systemName: "trash") }
                        }
                        .contextMenu {
                            Button(action: {
                                listTitlePresent = true
                                currentList = newItem!
                            }, label: {
                                Label("CHANGE_LIST_TITLE", systemImage: "pencil")
                            })
                            Button(action: {
                                listSubtitlePresent = true
                                currentList = newItem!
                            }, label: {
                                Label("CHANGE_LIST_SUBTITLE", systemImage: "pencil.line")
                            })
                        }
                    }
                }
                .navigationTitle("LIST_TITLE")
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        Button(action: {
                            alertPresent = true
                            
                        }, label: {
                            Image(systemName: "plus")
                        })
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
                        NavigationLink(destination: AllArticleView(mode: 0)) {
                            Label("ALL_SAVED_ARTICLES", systemImage: "bookmark")
                        }
                        NavigationLink(destination: AllArticleView(mode: 1)) {
                            Label("ALL_READ_ARTICLES", systemImage: "eye")
                        }
                        NavigationLink(destination: AllArticleView(mode: 2)) {
                            Label("ALL_UNREAD_ARTICLES", systemImage: "eye.slash")
                        }
                    }
                }
                // Change List Title
                .alert("CHANGE_LIST_TITLE", isPresented: $listTitlePresent) {
                    TextField("", text: $query)
                    
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
                    TextField("", text: $query)
                    
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
            }
        }
    }
}

// MARK: - Single List View
struct OneListView: View {
    @State var list: SCPList
    @State var query: String = ""
    @State var sort: Int = 0
    
    var searchResults: [String]? {
        if query.isEmpty {
            return list.contents
        } else {
            return list.contents?.filter { $0.contains(query) }
        }
    }
    
    var body: some View {
        let _ = PersistenceController(inMemory: false)
        if searchResults != nil {
            List {
                ForEach(searchResults!, id: \.self) { item in
                    let passedArticle = PersistenceController.shared.getArticleByID(id: item)
                    if passedArticle != nil {
                        ArticleRow(passedSCP: Article(fromEntity: passedArticle!)!, localArticle: true)
                    }
                }
            }
            .navigationTitle(list.listid)
            .searchable(text: $query, placement: .navigationBarDrawer(displayMode: .always))
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        Picker("Sort by...", selection: $sort) {
                            Label("Alphabetically", systemImage: "abc").tag(0)
                            Label("Date Added", systemImage: "clock").tag(1)
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
