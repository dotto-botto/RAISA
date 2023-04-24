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
            if items != nil {
                List(items!) { item in
                    HistoryRow(item: History(fromEntity: item)!)
                }
                .listStyle(.plain)
                .navigationTitle("HISTORY_TITLE")
                .toolbar {
                    ToolbarItem(placement: .secondaryAction) {
                        Button(action: {
                            clearConfirmation = true
                        }, label: {
                            Text("CLEAR_HISTORY_BUTTON")
                            Image(systemName: "clear")
                        })
                        .confirmationDialog("Are you sure?", isPresented: $clearConfirmation) {
                            Button("CLEAR_HISTORY_CONFIRMATION", role: .destructive) {
                                con.deleteAllHistory()
                            }
                        }
                    }
                }
            } else {
                Text("NO_HISTORY")
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
