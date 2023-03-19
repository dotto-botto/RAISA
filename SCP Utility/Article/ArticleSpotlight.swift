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
                Spacer()
            }
        }
        .background {
            if scp.thumbnail != nil { KFImage(scp.thumbnail!) }
        }
    }
}
