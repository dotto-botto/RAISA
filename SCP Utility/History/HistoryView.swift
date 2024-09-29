//
//  HistoryView.swift
//  SCP Wiki Utility
//
//  Created by Maximus Harding on 12/25/22.
//

import SwiftUI

/// View that displays user article history, and allows filtering by time.
struct HistoryView: View {
    @State private var clearConfirmation: Bool = false
    @State private var items: [HistoryItem]? = nil
    @State private var query: String =  ""
    @State private var sheetPresent: Bool = false
    @State private var rangeSpecified: Bool = false
    @State private var startDate: Date = Date().onlyDate
    @State private var endDate: Date = Date().onlyDate
    
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
                if rangeSpecified {
                    HStack(alignment: .center) {
                        Button {
                            startDate = Date().onlyDate
                            endDate = Date().onlyDate
                            rangeSpecified = false
                            updateList()
                        } label: {
                            Text("RESET_FILTER")
                                .font(.title3)
                                .bold()
                                .padding(.vertical, 3)
                        }
                    }
                }
                
                if items != nil && items != [] {
                    ForEach(Array(zip(timeIntervals, timeIntervals.indices)), id: \.1) { time, index in
                        let lastTime = time == timeIntervals[0] ? 0 : timeIntervals[index - 1]
                        let filteredItems = items!.filter {
                            // Item is younger than interval
                            ($0.date!.timeIntervalSinceNow > time) &&
                            // Item is older than last interval
                            ($0.date!.timeIntervalSinceNow < lastTime)
                        }
                        
                        if !filteredItems.isEmpty && !rangeSpecified {
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
                                            updateList()
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
                Menu {
                    Button {
                        sheetPresent = true
                    } label: {
                        Label("SELECT_DATE", systemImage: "calendar")
                    }
                    
                    Button {
                        clearConfirmation = true
                    } label: {
                        Label("CLEAR_HISTORY_BUTTON", systemImage: "trash")
                    }
                    .confirmationDialog("ASSURANCE", isPresented: $clearConfirmation) {
                        Button("CLEAR_HISTORY_CONFIRMATION", role: .destructive) {
                            con.deleteAllHistory()
                            updateList()
                        }
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
            .sheet(isPresented: $sheetPresent) {
                VStack {
                    Text("SELECT_DATE")
                        .font(.title)
                        .bold()
                    DatePicker("START_DATE", selection: $startDate, in: ...Date(), displayedComponents: [.date])
                    DatePicker("END_DATE", selection: $endDate, in: ...Date(), displayedComponents: [.date])
                    
                    Button {
                        sheetPresent.toggle()
                        rangeSpecified = true
                    } label: {
                        Text("DONE")
                    }
                    .padding(.vertical, 10)
                    
                    Button {
                        sheetPresent.toggle()
                        rangeSpecified = false
                        updateList()
                    } label: {
                        Text("CANCEL")
                    }
                }
                .padding(.horizontal, 20)
                .onDisappear { updateList() }
                .presentationDetents([.medium])
            }
        }
        .searchable(text: $query)
        .onChange(of: query) { _ in
            rangeSpecified = false
            updateList()
            if query == "" {
                items = items?.reversed()
            } else {
                items = items?.reversed().filter { $0.articletitle?.lowercased().contains(query.lowercased()) ?? false }
            }
        }
        .onAppear {
            updateList()
        }
    }
    
    private func updateList() {
        items = con.getAllHistory()?.reversed()
        items?.sort { ($0.date ?? Date()) > ($1.date ?? Date()) }
        
        if rangeSpecified {
            if startDate > endDate { swap(&startDate, &endDate) }
            // Assume user wanted to see all values on a day if dates are equal
            if startDate == endDate { endDate += 86400 }
            
            items = (items ?? []).filter {
                $0.date! < endDate && $0.date! > startDate
            }
        }
    }
}

struct HistoryView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryView()
    }
}

extension Date {
    // https://stackoverflow.com/q/55688517/25654194
    /// Returns the date up to the day.
    var onlyDate: Date {
        get {
            let calendar = Calendar.current
            var dateComponents = calendar.dateComponents([.year, .month, .day], from: self)
            dateComponents.timeZone = NSTimeZone.system
            return calendar.date(from: dateComponents) ?? self
        }
    }

}
