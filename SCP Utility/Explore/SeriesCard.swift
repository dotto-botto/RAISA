//
//  SeriesCard.swift
//  SCP Utility
//
//  Created by Maximus Harding on 5/21/23.
//

import SwiftUI

struct SeriesCard: View {
    var body: some View {
        VStack {
            HStack {
                Text("SERIES_CARD")
                    .font(.headline)
                    .fontWeight(.bold)
                    .padding(.leading)
                Spacer()
            }
            Grid(horizontalSpacing: 0, verticalSpacing: 0) {
                GridRow {
                    ForEach(1...4, id: \.self) { series in
                        SeriesButton(series: series)
                    }
                }
                GridRow {
                    ForEach(5...8, id: \.self) { series in
                        SeriesButton(series: series)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: 250)
    }
}

struct SeriesButton: View {
    let series: Int
    @State private var presentSheet: Bool = false
    var body: some View {
        Button {
            presentSheet = true
        } label: {
            Group {
                switch series {
                case 1: Text("I")
                case 2: Text("II")
                case 3: Text("III")
                case 4: Text("IV")
                case 5: Text("V")
                case 6: Text("VI")
                case 7: Text("VII")
                case 8: Text("VIII")
                // Unused
                case 9: Text("IX")
                case 10: Text("X")
                case 11: Text("XI")
                default: EmptyView()
                }
            }
            .font(.custom("", size: 60))
            .foregroundColor(.white)
            .fontWeight(.black)
        }
        .frame(width: 100, height: 100)
        .background {
            Image("Series\(series)")
                .resizable()
                .scaledToFill()
                .opacity(0.7)
        }
        .sheet(isPresented: $presentSheet) {
            NavigationStack { SeriesView(series: series) }
        }
    }
}

struct SeriesCard_Previews: PreviewProvider {
    static var previews: some View {
        SeriesCard()
    }
}
