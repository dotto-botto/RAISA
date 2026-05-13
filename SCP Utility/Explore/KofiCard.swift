//
//  KofiCard.swift
//  SCP Utility
//
//  Created by Maximus Harding on 5/13/26.
//

import SwiftUI

struct KofiCard: View {
    var body: some View {
        Link(destination: URL(string: "https://ko-fi.com/dottobotto")!) {
            VStack {
                Divider()
                HStack {
                    Image("ko-fi-mug")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 50)
                    Text("SUPPORT_RAISA_PROMPT")
                        .font(.monospaced(.title2)())
                        .lineLimit(2)
                    Image(systemName: "arrow.forward")
                }
                Divider()
            }
        }
        .foregroundColor(.primary)
    }
}

#Preview {
    KofiCard()
}
