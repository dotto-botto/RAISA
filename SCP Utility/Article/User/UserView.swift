//
//  UserView.swift
//  SCP Utility
//
//  Created by Maximus Harding on 7/1/23.
//

import SwiftUI

struct UserView: View {
    @State var user: User
    @Environment(\.dismiss) var dismiss
    var body: some View {
        let Block = {
            Rectangle()
                .frame(width: 4)
                .foregroundColor(.secondary)
        }
        
        let Guide = {
            Rectangle()
                .frame(height: 0.5)
                .foregroundColor(.secondary)
        }
        
        NavigationStack {
            VStack(alignment: .center) {
                VStack {
                    AsyncImage(url: user.thumbnail) {
                        $0
                            .resizable()
                            .scaledToFit()
                            .border(Color.accentColor, width: 5)
                            .frame(width: 200, height: 200)
                    } placeholder: {
                        Image("image-placeholder")
                            .resizable()
                            .scaledToFit()
                            .border(Color.accentColor, width: 5)
                            .frame(width: 200, height: 200)
                    }
                    Text(user.username ?? "")
                        .font(.system(size: 40))
                        .lineLimit(2)
                        .bold()
                }
                
                HStack {
                    Block()
                    Spacer()
                    VStack {
                        HStack {
                            KarmaView(karma: user.karma)
                            Text(LocalizedStringKey(stringLiteral: "\(user.karma ?? 0)_KARMA"))
                        }
                        
                        if user.website != nil {
                            Link("USER_WEBSITE", destination: user.website!)
                        }
                        
                        if user.creation != nil {
                            HStack {
                                Text("USER_SINCE").bold()
                                Guide()
                                Text(
                                    user.creation!
                                        .formatted(date: .long, time: .shortened)
                                        .replacingOccurrences(of: "at", with: "")
                                )
                            }
                        }
                        
                        if user.from != nil {
                            HStack {
                                Text("USER_FROM").bold()
                                Guide()
                                Text(user.from!)
                            }
                        }
                        
                        if user.realname != nil {
                            HStack {
                                Text("USER_REALNAME").bold()
                                Guide()
                                Text(user.realname!)
                            }
                        }
                    }
                    Spacer()
                }
            }
            .padding(.horizontal, 10)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
            }
        }
    }
}

struct KarmaView: View {
    @State var karma: Int
    
    init?(karma: Int? = nil) {
        guard let k = karma else { return nil }
        self.karma = k
    }
    
    let colors: [Color] = [
        Color(hex: "FF2C2C"),
        Color(hex: "EC800E"),
        Color(hex: "FFF10B"),
        Color(hex: "61F328"),
        Color(hex: "61F3A7"),
    ]
    
    var body: some View {
        VStack(spacing: 2) {
            ForEach(colors[0..<karma], id: \.self) { color in
                Rectangle()
                    .foregroundColor(color)
                    .frame(width: 13, height: 4)
            }
        }
        .padding(.all, 2)
        .background {
            Color(hex: "2C2C2C")
        }
    }
}

struct UserView_Previews: PreviewProvider {
    static var previews: some View {
        UserView(user: placeholderUser)
    }
}
