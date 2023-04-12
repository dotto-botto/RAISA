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
        NavigationLink(destination: ArticleView(scp: scp)) {
            VStack {
                HStack {
                    Text(scp.title)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.leading)
                    Spacer()
                }
                HStack {
                    Spacer()
                    ZStack{
                        if scp.objclass != nil {
                            Image(scp.objclass!.toImage())
                        }
                    }
                    
                    ZStack{
                        if scp.esoteric != nil {
                            Image(scp.esoteric!.toImage())
                        }
                    }
                    
                    ZStack{
                        if scp.disruption != nil {
                            Image(scp.disruption!.toImage())
                        }
                    }
                    
                    ZStack{
                        if scp.risk != nil {
                            Image(scp.risk!.toImage())
                        }
                    }
                    Spacer()
                }
            }
            .padding(10)
            .cornerRadius(15)
            .background {
                if scp.thumbnail != nil {
                    KFImage(scp.thumbnail!)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .opacity(0.5)
                        .frame(width: 400)
                    // https://stackoverflow.com/a/69092800
                        .mask(LinearGradient(gradient: Gradient(stops: [
                            .init(color: .black, location: 0),
                            .init(color: .clear, location: 1),
                            .init(color: .black, location: 1),
                            .init(color: .clear, location: 1)
                        ]), startPoint: .top, endPoint: .bottom))
                }
            }
        }
    }
}

struct ArticleSpotlight_Previews: PreviewProvider {
    static var previews: some View {
        ArticleSpotlight(scp: Article(
            title: "SCP-5004",
            pagesource: "Page source here...",
            url: placeholderURL,
            thumbnail: URL(string: "https://scp-wiki.wdfiles.com/local--files/scp-5004/header.png"),
            objclass: .esoteric,
            esoteric: .thaumiel,
            clearance: "5",
            disruption: .ekhi,
            risk: .notice
        ))
    }
}
