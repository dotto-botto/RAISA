//
//  ArticleSpotlight.swift
//  SCP Utility
//
//  Created by Maximus Harding on 3/9/23.
//

import SwiftUI
import Kingfisher

struct ArticleSpotlight: View {
    @State var scp: Article
    var body: some View {
        VStack {
            Text(scp.title)
            HStack {
                Spacer()
                ZStack{
                    if scp.objclass != nil { Image(scp.objclass!.toImage()) }
                }

                ZStack{
                    if scp.esoteric != nil { Image(scp.esoteric!.toImage()) }
                }

                ZStack{
                    if scp.disruption != nil { Image(scp.disruption!.toImage()) }
                }

                ZStack{
                    if scp.risk != nil { Image(scp.risk!.toImage()) }
                }
//                ForEach([scp.objclass, scp.esoteric, scp.disruption, scp.risk]) { attr in
//                    ZStack {
//                        Image(attr!.toImage())
//                    }
//
//                }
                Spacer()
            }
        }
        .background {
            if scp.thumbnail != nil { KFImage(scp.thumbnail!) }
        }
    }
}

struct ArticleSpotlight_Previews: PreviewProvider {
    static var previews: some View {
        ArticleSpotlight(scp: Article(
            title: "SCP-5004",
            pagesource: "",
            thumbnail: URL(string: "https://scp-wiki.wdfiles.com/local--files/scp-5004/header.png"),
            objclass: .esoteric,
            esoteric: .thaumiel,
            clearance: "5",
            disruption: .ekhi,
            risk: .notice
        ))
    }
}
