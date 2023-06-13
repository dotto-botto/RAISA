//
//  SyntaxGuideView.swift
//  SCP Utility
//
//  Created by Maximus Harding on 6/11/23.
//

import SwiftUI

struct SyntaxGuideView: View {
    var guides: [(Image, Text, Text)] = [
        (Image(systemName: "bold"), Text("\\*\\*this text is bold\\*\\*"), Text("**this text is bold**")),
        (Image(systemName: "italic"), Text("//this text is italic//"), Text("*this text is italic*")),
        (Image(systemName: "strikethrough"), Text("--this text is struck--"), Text("~~this text is struck~~")),
    ]
    var body: some View {
        VStack {
            let imFrame: CGFloat = 90
            ForEach(0..<guides.count, id: \.self) { index in
                let image = guides[index].0
                let raw = guides[index].1
                let displayed = guides[index].2
                
                HStack {
                    image
                        .resizable()
                        .frame(width: imFrame - 10, height: imFrame)
                        .scaledToFill()
                    
                    VStack {
                        raw.font(.title3)
                        displayed.font(.title3)
                    }
                    .padding(.leading, 10)
                }
                .padding(.bottom, 40)
            }
        }
    }
}

struct SyntaxGuideView_Previews: PreviewProvider {
    static var previews: some View {
        SyntaxGuideView()
    }
}
