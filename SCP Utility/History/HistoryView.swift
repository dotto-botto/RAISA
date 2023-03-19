//
//  HistoryView.swift
//  SCP Wiki Utility
//
//  Created by Maximus Harding on 12/25/22.
//

import SwiftUI
import Foundation

struct HistoryView: View {
    var body: some View {
        NavigationView {
            var items = PersistenceController.shared.getAllHistory()
            let _ = PersistenceController(inMemory: false)
            if items != nil {
                let _ = items!.reverse()
                List(items!) { item in
                    HistoryRow(item: History(fromEntity: item)!)
                }
                .navigationTitle("HISTORY_TITLE")
            } else {
                Text("NO_HISTORY")
            }
        }
    }
}
