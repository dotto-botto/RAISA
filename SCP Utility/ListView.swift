//
//  ListView.swift
//  SCP Wiki Utility
//
//  Created by Maximus Harding on 12/25/22.
//

import SwiftUI
import Foundation

struct ListView: View {
    var listeditems: ArticleDefiner // eventaully switch to reading from file
    
    var body: some View {
        ScrollViewReader { proxy in
            List{
                ForEach(listeditems) {_ in 
                    //                    NavigationLink(tag: )
                }
                
                
                //                VStack{
                //                    // Header
                //                    VStack {
                //                        TextField("Search", text: /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Value@*/.constant("")/*@END_MENU_TOKEN@*/).textFieldStyle(.roundedBorder)
                //                    }
                //                    // Start of actual list
                //                    List{
                //
                //                    }
                //                }
                //                .navigationTitle("Lists")
            }
        }
    }
}
