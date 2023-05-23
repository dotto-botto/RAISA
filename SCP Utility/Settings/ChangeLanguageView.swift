//
//  ChangeLanguageView.swift
//  SCP Utility
//
//  Created by Maximus Harding on 5/23/23.
//

import SwiftUI

struct ChangeLanguageView: View {
    @AppStorage("chosenRaisaLanguage") var chosenRaisaLanguage = RAISALanguage.english.rawValue
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        NavigationStack {
            Group {
                Text("This changes the language articles will appear in.")
                Text("To change the app's language, go to your device settings.")
            }
            .font(.subheadline)
            .foregroundColor(.secondary)
            
            List(RAISALanguage.allCases) { lang in
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
            .navigationTitle("Language")
            .toolbar {
                Button { dismiss() } label: { Image(systemName: "xmark") }
            }
        }
    }
}

struct ChangeLanguageView_Previews: PreviewProvider {
    static var previews: some View {
        ChangeLanguageView()
    }
}
