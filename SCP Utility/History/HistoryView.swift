//
//  HistoryView.swift
//  SCP Wiki Utility
//
//  Created by Maximus Harding on 12/25/22.
//

import SwiftUI
import Foundation

/// View that displays multiple HistoryRows, and adds deletion of history items.
struct HistoryView: View {
    @State var clearConfirmation: Bool = false
    @State private var items: [HistoryItem]? = nil
    @State private var query: String =  ""
    
    let con = PersistenceController.shared
    var body: some View {
        NavigationStack {
            ScrollView {
                if items != nil && items != [] {
                    LazyVStack {
                        ForEach(items!) { item in
                            let history = History(fromEntity: item)!
                            HistoryRow(item: history)
                                .contextMenu {
                                    Button(role: .destructive) {
                                        con.deleteHistoryFromId(id: history.id)
                                    } label: {
                                        Label("DELETE", systemImage: "trash")
                                    }
                                }
                            Divider()
                        }
                    }
                    .padding(.horizontal, 15)
                } else {
                    Text("NO_HISTORY").foregroundColor(.secondary)
                }
            }
            .navigationTitle("HISTORY_TITLE")
            .toolbar {
                Button {
                    clearConfirmation = true
                } label: {
                    Label("CLEAR_HISTORY_BUTTON", systemImage: "trash")
                }
                .confirmationDialog("ASSURANCE", isPresented: $clearConfirmation) {
                    Button("CLEAR_HISTORY_CONFIRMATION", role: .destructive) {
                        con.deleteAllHistory()
                        items = con.getAllHistory()?.reversed()
                    }
                }
            }
        }
        .searchable(text: $query)
        .onChange(of: query) { _ in
            if query == "" {
                items = con.getAllHistory()?.reversed()
            } else {
                items = con.getAllHistory()?.reversed().filter { $0.articletitle?.lowercased().contains(query.lowercased()) ?? false }
            }
        }
        .onAppear {
            items = con.getAllHistory()?.reversed()
        }
    }
}

struct HistoryView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryView()
    }
}
