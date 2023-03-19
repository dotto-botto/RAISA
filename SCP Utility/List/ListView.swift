//
//  ListView.swift
//  SCP Wiki Utility
//
//  Created by Maximus Harding on 12/25/22.
//

import SwiftUI
import Foundation

// defining a list of article lists

// MARK: - Many List View
struct ListView: View {
    @Environment(\.managedObjectContext) var Context
    @State var alertPresent: Bool = false
    @State var query: String = ""
    @State var oneList: Bool = false
        
    var body: some View {
        let items = PersistenceController.shared.getAllLists()
        let _ = PersistenceController(inMemory: false)
        
        NavigationView {
            if items == nil {
                (Text("Tap \"") + Text(Image(systemName: "plus")) + Text("\" to make a list")).foregroundColor(.gray)
            } else {
                List(items!) { item in
                    let newItem = SCPList(fromEntity: item)
                    
                    if (newItem != nil) {
                        NavigationLink(newItem!.listid) { OneListView(list: newItem!) }
                            .swipeActions {
                                Button(role: .destructive) {
                                    PersistenceController.shared.deleteListEntity(listitem: newItem!)
                                } label: { Image(systemName: "trash") }
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
                        .alert("Add new List", isPresented: $alertPresent) {
                            TextField("", text: $query)
                            
                            Button("Add") {
                                PersistenceController.shared.createListEntity(list: SCPList(listid: query))
                                alertPresent = false
                            }
                            Button("Cancel", role: .cancel) {
                                alertPresent = false
                            }
                        }
                    }
                    ToolbarItem(placement: .secondaryAction) {
                        NavigationLink("ALL_SAVED_ARTICLES") { AllArticleView() }
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
//        HStack {
//            Text("tlou2 is bad for multiple reasons")
//                .foregroundColor(.gray)
//                .padding(.leading)
//            Spacer()
//        }
        // Custom search bar, to be able to display a subtitle
        // Commented out becuase I think it looks better without
//        HStack {
//            Image(systemName: "magnifyingglass")
//            TextField("Search", text: $query)
//                .foregroundColor(.primary)
//        }
//        .padding(.vertical, 8)
//        .padding(.horizontal, 5)
//        .background(Color(.systemGray5))
//        .cornerRadius(10)
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
