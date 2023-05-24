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
    
    init(_ attr: ArticleAttribute) {
        componentClass = attr
    }
    
    var body: some View {
        HStack {
            Rectangle()
                .foregroundColor(componentClass.toColor())
                .frame(width: 20)
            // MARK: - Text
            VStack {
                Text(componentClass.toLocalString().uppercased())
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
                        Circle().foregroundColor(componentClass.toColor())
                            .frame(height: 80)
                        Image(componentClass.toImage())
                            .resizable()
                            .scaledToFit()
                            .frame(width: 65)
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
        }
    }
}
