//
//  SeriesCard.swift
//  SCP Utility
//
//  Created by Maximus Harding on 5/21/23.
//

import SwiftUI

/// ExploreView card that displays the 8 series.
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
            
            if UIDevice.current.userInterfaceIdiom == .phone {
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
            } else {
                HStack {
                    ForEach(1...8, id: \.self) { series in
                        SeriesButton(series: series)
                    }
                }
            }
        }
    }
}

/// View that displays an SCP Series.
/// A roman numeral on top of the corresponding series background.
struct SeriesButton: View {
    let series: Int
    @State private var presentSheet: Bool = false
    var body: some View {
        Button {
            presentSheet = true
        } label: {
            Group {
                switch series {
                case 1: Text("ROMAN_1")
                case 2: Text("ROMAN_2")
                case 3: Text("ROMAN_3")
                case 4: Text("ROMAN_4")
                case 5: Text("ROMAN_5")
                case 6: Text("ROMAN_6")
                case 7: Text("ROMAN_7")
                case 8: Text("ROMAN_8")
                // Unused
                case 9: Text("ROMAN_9")
                case 10: Text("ROMAN_10")
                case 11: Text("ROMAN_11")
                default: EmptyView()
                }
            }
            .font(.custom("", size: 60))
            .foregroundColor(.white)
            .fontWeight(.black)
            .dynamicTypeSize(.xSmall ... .large)
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
