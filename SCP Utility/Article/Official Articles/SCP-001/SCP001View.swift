//
//  SCP001View.swift
//  SCP Utility
//
//  Created by Maximus Harding on 5/11/23.
//

import SwiftUI

// https://scp-wiki.wikidot.com/scp-001

/// Built in SCP Article of SCP-001.
struct SCP001View: View {
    var body: some View {
        VStack(alignment: .center) {
            Text("THE FOLLOWING FILES HAVE BEEN CLASSIFIED")
            Text("TOP SECRET")
                .font(.largeTitle)
                .foregroundColor(.accentColor)
                .bold()
            Text("BY ORDER OF THE ADMINISTRATOR")
            Divider()
            Text(.init("**GENERAL NOTICE 001-Alpha:** In order to prevent knowledge of SCP-001 from being leaked, several/no false SCP-001 files have been created alongside the true file/files. All files concerning the nature of SCP-001, including the decoy/decoys, are protected by a memetic kill agent designed to immediately cause cardiac arrest in any nonauthorized personnel attempting to access the file. Revealing the true nature/natures of SCP-001 to the general public is cause for execution, except as required under ████-███-██████."))
            Divider()
            Text("WARNING:")
                .font(.largeTitle)
                .foregroundColor(.accentColor)
                .bold()
            Text(.init("ANY NON-AUTHORIZED PERSONNEL ACCESSING THIS FILE WILL BE IMMEDIATELY TERMINATED THROUGH **BERRYMAN-LANGFORD** MEMETIC KILL AGENT. SCROLLING DOWN WITHOUT PROPER MEMETIC INOCULATION WILL RESULT IN IMMEDIATE CARDIAC ARREST FOLLOWED BY DEATH."))
            Text("YOU HAVE BEEN WARNED.")
                .font(.largeTitle)
                .foregroundColor(.accentColor)
                .bold()
            Divider()
                .padding(.bottom, 2000)
        }
        .padding(.top, 20)
        
        VStack(alignment: .center, spacing: 5) {
            Image("fractal-mka")
                .resizable()
                .scaledToFit()
            
            Text("MEMETIC KILL AGENT ACTIVATED").bold()
            Text("CONTINUED LIFE SIGNS CONFIRMED").bold()
            Text("REMOVING SAFETY INTERLOCKS").bold()
            Text("Welcome, authorized personnel. Please select your desired file.").italic()
            Divider()
            
            OneProposalsView()
        }
    }
}

struct SCP001View_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView { SCP001View() }
            .previewDisplayName("SCP-001")
    }
}
