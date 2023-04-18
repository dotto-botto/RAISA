//
//  ExploreView.swift
//  SCP Utility
//
//  Created by Maximus Harding on 3/9/23.
//

import SwiftUI

struct ExploreView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 40) {
                    RandomCard()
                    ResumeCard().clipped()
                }
                .frame(width: 400)
                .navigationTitle("RAISA_HEADER")
            }
        }
    }
}

struct ExploreView_Previews: PreviewProvider {
    static var previews: some View {
        ExploreView()
    }
}
