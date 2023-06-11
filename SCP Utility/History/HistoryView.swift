//
//  HistoryView.swift
//  SCP Wiki Utility
//
//  Created by Maximus Harding on 12/25/22.
//

import SwiftUI

/// View that displays multiple HistoryRows, and adds deletion of history items.
struct HistoryView: View {
    @State private var clearConfirmation: Bool = false
    @State private var items: [HistoryItem]? = nil
    @State private var query: String =  ""
    
    let con = PersistenceController.shared
    
    var timeIntervals: [Double] = [
         -86400, // day
         -604800, // week
         -2628000, // month
         -Double.infinity,
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                if items != nil && items != [] {
                    ForEach(Array(zip(timeIntervals, timeIntervals.indices)), id: \.1) { time, index in
                        let lastTime = time == timeIntervals[0] ? 0 : timeIntervals[index - 1]
                        let filteredItems = items!.filter {
                            // Item is younger than interval
                            ($0.date!.timeIntervalSinceNow > time) &&
                            // Item is older than last interval
                            ($0.date!.timeIntervalSinceNow < lastTime)
                        }
                        
                        if !filteredItems.isEmpty {
                            HStack {
                                switch index {
                                case 0: Text("TODAY")
                                case 1: Text("THIS_WEEK")
                                case 2: Text("THIS_MONTH")
                                default: Text("OLDER")
                                }
                                
                                Spacer()
                            }
                            .font(.title2)
                            .bold()
                            .padding(.vertical, 3)
                        }
                        
                        LazyVStack {
                            ForEach(filteredItems) { item in
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
                        .padding(.horizontal, 10)
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
