//
//  ExploreView.swift
//  SCP Utility
//
//  Created by Maximus Harding on 3/9/23.
//

import SwiftUI

/// The first view that the user sees on app startup.
/// This view links to several other views, and allows the user to change the settings and language of the app.
struct ExploreView: View {
    @State private var settings: Bool = false
    @State private var language: Bool = false
    @State private var editor: Bool = false
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 40) {
                    RandomCard().clipped()
                    ResumeCard()
                    SeriesCard()
                    TopCard()
                }
                .padding(.horizontal, 60)
            }
            .navigationTitle("RAISA_HEADER")
            .toolbar {
//                ToolbarItemGroup(placement: .navigationBarLeading) {
//                    Button {
//                        editor = true
//                    } label: {
//                        Image(systemName: "plus")
//                    }
//                }
                
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button {
                        language = true
                    } label: {
                        Image(systemName: "globe")
                    }
                    
                    Button {
                        settings = true
                    } label: {
                        Image(systemName: "gear")
                    }
                }
            }
            .fullScreenCover(isPresented: $settings) { NavigationStack { SettingsView() } }
            .fullScreenCover(isPresented: $editor) { NavigationStack { EditorView() } }
            .fullScreenCover(isPresented: $language) { NavigationStack { ChangeLanguageView() } }
        }
    }
}

struct ExploreView_Previews: PreviewProvider {
    static var previews: some View {
        ExploreView()
    }
}
