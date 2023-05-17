//
//  001ProposalsView.swift
//  SCP Utility
//
//  Created by Maximus Harding on 5/11/23.
//

import SwiftUI

struct OneProposalsView: View {
    @State private var showSheet: Bool = false
    var body: some View {
        var proposal: Article = placeHolderArticle
        VStack {
            ForEach(SCP001Proposals.sorted(by: <), id: \.key) { key, value in
                Button {
                    cromGetSourceFromTitle(title: value) { article in
                        proposal = article
                        showSheet = true
                    }
                } label: {
                    HStack {
                        Text(key)
                        Text(value)
                    }
                }
            }
        }
        .fullScreenCover(isPresented: $showSheet) {
            NavigationStack { ArticleView(scp: proposal) }
        }
    }
}

private let SCP001Proposals: [String:String] = [
    "Jonathan Ball" : "Sheaf of Papers",
    "Dr.Gears" : "The Prototype",
    "Dr.Clef" : "The Gate Guardian",
    "qntm" : "The Lock",
    "Dr.Bright" : "The Factory",
    "Dr.Mann" : "The Spiral Path",
    "Dr.Mackenzie" : "The Legacy",
    "S. Andrew Swann" : "The Database",
    "Scantron" : "The Foundation",
    "Djoric-Dmatix" : "Thirty-Six",
    "Djkaktus/TwistedGears" : "Ouroboros",
    "Kate McTiriss" : "A Record",
    "Kalinin" : "Past and Future",
    "Wrong" : "The Consensus",
    "S. D. Locke" : "When Day Breaks",
    "Spike Brennan" : "God's Blind Spot",
    "WJS" : "Normalcy",
    "BILLITH" : "The World at Large",
    "Tanhony" : "Dead Men",
    "Lily" : "The World's Gone Beautiful",
    "Tufto" : "The Scarlet King",
    "Jim North" : "A Simple Toymaker",
    "I. H. Pinkman" : "Story of Your Life",
    "The Great Hippo ft. PeppersGhost" : "Hippo’s Proposal", // "A Good Boy" brings up a diff article
    "WWMD" : "Project Palisade",
    "Captain Kirby" : "O5-13",
    "Pedantique" : "Fishhook",
    "notgull" : "The Sky Above the Port",
    "Jack Ike" : "The Solution",
    "Jack Ike II" : "Tindalos Trinity",
    "Tanhony II" : "The Black Moon",
    "Harmony" : "The Conspiracy",
    "Arbelict" : "You Are The Anomaly, Tumor Of The Worlds",
    "McDoctorate" : "The Placeholder",
    "Rounderhouse" : "MEMENTO MORI",
    "Dr. Eates" : "A Test of Character",
    "Ihp/Locke" : "Keter Duty",
    "Pinkman/Blank" : "The Frontispiece",
    "Rounderhouse Gold" : "AMONI-RAM",
    "Ralliston" : "The Queen's Gambit",
    "D. Ulysses Foole's" : "Last Ride of the Day",
    "Nagiros" : "R ¦ A ¦ G ¦ E",
    "Rounderhouse Jade" : "MAMJUL & KORAR",
    "Plague" : "The Ones That Got Away"
]

struct OneProposalsView_Previews: PreviewProvider {
    static var previews: some View {
        OneProposalsView()
    }
}
