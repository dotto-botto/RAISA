//
//  ExploreView.swift
//  SCP Utility
//
//  Created by Maximus Harding on 3/9/23.
//

import SwiftUI

struct ExploreView: View {
    @State private var settings: Bool = false
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 40) {
                    RandomCard()
                    ResumeCard().clipped()
                }
                .frame(width: 400)
                .navigationTitle("RAISA_HEADER")
                .toolbar {
                    Button {
                        settings = true
                    } label: {
                        Image(systemName: "gear")
                    }
                }
                .fullScreenCover(isPresented: $settings) { NavigationStack { SettingsView() } }
            }
        }
    }
}

struct ExploreView_Previews: PreviewProvider {
    static var previews: some View {
        ExploreView()
    }
}
