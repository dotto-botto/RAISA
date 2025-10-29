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
                VStack(spacing: 0) {
                    HStack(spacing: 0) {
                        GridRow {
                            ForEach(1...5, id: \.self) { series in
                                SeriesButton(series: series)
                            }
                        }
                    }
                    HStack(spacing: 0) {
                        GridRow {
                            ForEach(6...10, id: \.self) { series in
                                SeriesButton(series: series)
                            }
                        }
                    }
                }
            } else {
                HStack(spacing: 0) {
                    ForEach(1...10, id: \.self) { series in
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
            ZStack {
                Image("Series\(series)")
                    .resizable()
                    .scaledToFill()
                    .opacity(0.7)
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
                    case 9: Text("ROMAN_9")
                    case 10: Text("ROMAN_10")
                    case 11: Text("ROMAN_11")
                    case 12: Text("ROMAN_12")
                    case 13: Text("ROMAN_13")
                    case 14: Text("ROMAN_14")
                    case 15: Text("ROMAN_15")
                    default: EmptyView()
                    }
                }
                .font(.custom("", size: 40))
                .foregroundColor(.white)
                .fontWeight(.black)
                .dynamicTypeSize(.xSmall ... .large)
            }
        }
        .frame(width: 80, height: 80)
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
