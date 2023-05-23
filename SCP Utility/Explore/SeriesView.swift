//
//  SeriesView.swift
//  SCP Utility
//
//  Created by Maximus Harding on 5/21/23.
//

import SwiftUI

struct SeriesView: View {
    @State var startingNum: Int

    init(series: Int) {
        self.startingNum = (series == 1) ? 1 : (series - 1) * 1000
    }

    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(startingNum...startingNum + 999, id: \.self) { num in
                    OnlineArticleRow(
                        // %03d - adds leading zeroes up to 3 digits
                        title: "SCP-" + String(format: "%03d", num),
                        url: URL(string: "http://scp-wiki.wikidot.com/scp-\(String(format: "%03d", num))")!
                    )
                }
            }
        }
        .navigationTitle("SERIES_TITLE\(startingNum == 1 ? startingNum : startingNum / 1000 + 1)")
        .toolbar {
            Menu {
                ForEach(1...8, id: \.self) { series in
                    Button("SERIES_TITLE\(series)") {
                        startingNum = (series == 1) ? 1 : (series - 1) * 1000
                    }
                }
            } label: {
                Image(systemName: "arrow.left.arrow.right")
            }
        }
    }
}

struct SeriesView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack { SeriesView(series: 1) }
    }
}
