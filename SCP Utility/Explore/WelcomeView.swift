//
//  WelcomeView.swift
//  SCP Utility
//
//  Created by Maximus Harding on 8/25/25.
//

import SwiftUI

struct WelcomeView: View {
    @Environment(\.dismiss) var dismiss
    var body: some View {
        VStack {
            Image("RAISA-icon")
                .resizable()
                .scaledToFit()
                .cornerRadius(25)
                .frame(width: 150)
                .padding(.bottom, 50)
                .dynamicTypeSize(.xSmall ... .xxxLarge)
            
            VStack(alignment: .leading) {
                Text("WELCOME_TITLE")
                    .bold()
                    .font(.title)
                    .padding(.bottom, 10)
                
                WelcomeCardView(card: 0)
                WelcomeCardView(card: 1)
                WelcomeCardView(card: 2)
            }
            .padding(.horizontal, 20)
            
            Button {
                dismiss()
            } label: {
                HStack {
                    Text("START_READING")
                    Image(systemName: "arrow.right")
                }
                .padding(12)
                .foregroundColor(.white)
                .background(.tint, in: RoundedRectangle(cornerRadius: 12))
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
        }
    }
}

struct WelcomeCardView: View {
    @State var card: Int
    
    private let icons: [Image] = [
        Image("foundation-emblem-accent-color"),
        Image(systemName: "questionmark.app"),
        Image(systemName: "book")
    ]
    private let headlines: [String] = [
        String(localized: "WELCOME_HEADLINE_WIKI"),
        String(localized: "WELCOME_HEADLINE_RAISA"),
        String(localized: "WELCOME_HEADLINE_START")
    ]
    private let subheadlines: [String] = [
        String(localized: "WELCOME_SUBHEADLINE_WIKI"),
        String(localized: "WELCOME_SUBHEADLINE_RAISA"),
        String(localized: "WELCOME_SUBHEADLINE_START")
    ]

    var body: some View {
        HStack(alignment: .top) {
            icons[card]
                .resizable()
                .scaledToFit()
                .foregroundColor(.accentColor)
                .frame(width: 30, height: 30)
            
            VStack(alignment: .leading) {
                Text(headlines[card])
                    .font(.title3)
                RTMarkdown(article: placeHolderArticle, text: subheadlines[card])
            }
            .padding(.leading, 10)
        }
        .padding(.vertical, 5)
    }
}


#Preview {
    WelcomeView()
}
