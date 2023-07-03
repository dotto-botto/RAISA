//
//  ACSCellView.swift
//  SCP Utility
//
//  Created by Maximus Harding on 5/5/23.
//

import SwiftUI

/// Container for the attribute icons used in ACSView.
struct ACSCellView: View {
    @State var componentClass: ArticleAttribute
    @State var customIcon: [String:URL?] = [:]
    
    init(_ attr: ArticleAttribute) {
        componentClass = attr
    }
    
    init?(secondaryname: String, secondaryIconURL url: URL?) {
        customIcon = [secondaryname:url]
        componentClass = .object(.unknown)
    }
    
    var body: some View {
        HStack {
            Rectangle()
                .foregroundColor(componentClass.toColor())
                .frame(width: 20)
            // MARK: - Text
            VStack {
                Text(customIcon.first?.key.uppercased() ?? componentClass.toLocalString().uppercased())
                    .font(.title)
                    .bold()
            }
            Spacer()
            
            // MARK: - Capsule
            ZStack {
                Capsule()
                    .foregroundColor(.black)
                    .frame(width: 150, height: 100)
                HStack {
                    Circle()
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .font(.largeTitle)
                        .bold()
                        .frame(width: 40)
                    
                    
                    ZStack {
                        Circle()
                            .foregroundColor(
                                componentClass.toColor() == Color("Pending Black") ? .white : componentClass.toColor()
                            )
                            .frame(height: 80)
                        
                        if let url = customIcon.first?.value {
                            AsyncImage(url: url) {
                                $0
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 65)
                            } placeholder: {}
                        } else {
                            Image(componentClass.toImage())
                                .resizable()
                                .scaledToFit()
                                .frame(width: 65)
                        }
                    }
                }
                .scaledToFit()
            }
        }
        .frame(height: 110)
        .background(componentClass.toColor().opacity(0.3))
    }
}

struct ACSCellView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            ACSCellView(.object(.keter))
            ACSCellView(.risk(.caution))
            ACSCellView(.esoteric(.apollyon))
            ACSCellView(secondaryname: "enochian", secondaryIconURL: URL(string: "https://scp-sandbox-3.wdfiles.com/local--files/collab%3Acalibri-bold-and-omega-fallon/enochian.png"))
        }
    }
}
