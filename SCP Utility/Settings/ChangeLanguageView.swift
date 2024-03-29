//
//  ChangeLanguageView.swift
//  SCP Utility
//
//  Created by Maximus Harding on 5/23/23.
//

import SwiftUI

/// View that allows a user to change the language that articles display in as well as the default search setting.
/// This does not update the system or the app language.
struct ChangeLanguageView: View {
    @AppStorage("chosenRaisaLanguage") var chosenRaisaLanguage = RAISALanguage.english.rawValue
    var body: some View {
        NavigationStack {
            Group {
                Text("LANGUAGEVIEW_TOOLTIP1")
                Text("LANGUAGEVIEW_TOOLTIP2")
            }
            .font(.subheadline)
            .foregroundColor(.secondary)
            
            List(RAISALanguage.allSupportedCases) { lang in
                Button {
                    chosenRaisaLanguage = lang.rawValue
                } label: {
                    HStack {
                        Image(lang.toImage())
                            .resizable()
                            .scaledToFit()
                        Text(lang.toName())
                        Spacer()
                        if chosenRaisaLanguage == lang.rawValue {
                            Image(systemName: "checkmark")
                        }
                    }
                }
                .frame(height: 40)
            }
            .listStyle(.plain)
            .navigationTitle("LANGUAGEVIEW_TITLE")
        }
    }
}

struct ChangeLanguageView_Previews: PreviewProvider {
    static var previews: some View {
        ChangeLanguageView()
    }
}
