//
//  HistoryView.swift
//  SCP Wiki Utility
//
//  Created by Maximus Harding on 12/25/22.
//

import SwiftUI
import Foundation

struct HistoryView: View {
    @State var clearConfirmation: Bool = false
    @State private var items: [HistoryItem]? = nil
    
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
                                        Label("Delete", systemImage: "trash")
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
                    Label("CLEAR_HISTORY_BUTTON", systemImage: "multiply.circle")
                }
                .confirmationDialog("Are you sure?", isPresented: $clearConfirmation) {
                    Button("CLEAR_HISTORY_CONFIRMATION", role: .destructive) {
                        con.deleteAllHistory()
                        items = con.getAllHistory()?.reversed()
                    }
                }
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
