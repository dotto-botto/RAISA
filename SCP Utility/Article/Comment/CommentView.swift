//
//  CommentView.swift
//  SCP Utility
//
//  Created by Maximus Harding on 4/29/23.
//

import SwiftUI
import Kingfisher

/// Displays a single comment.
/// inset - How deeply nested the comment is.
struct CommentView: View {
    @State var comment: Comment
    @State var inset: Int? = nil
    @State private var folded: Bool = false
    var body: some View {
        
        let Guide = {
            Rectangle()
                .frame(height: 0.5)
                .foregroundColor(.secondary)
        }
        
        HStack {
            if inset != nil {
                ForEach(0...inset!, id: \.self) { _ in
                    Divider()
                }
            }
            
            VStack(alignment: .leading) {
                HStack {
                    KFImage(comment.profilepic)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 30, height: 30)
                        .clipped()
                    Text(comment.username)
                        .font(.system(size: 16))
                        .bold()
                    if comment.date != nil {
                        Guide()
                        Text(comment.date!
                            .formatted(date: .long, time: .shortened)
                            .replacingOccurrences(of: "at", with: "")
                        )
                            .font(.system(size: 14))
                            .bold()
                    }
                    Spacer()
                }
                
                HStack {
                    Text(comment.subject ?? "")
                        .font(.system(size: 18))
                        .bold()
                    
                    Spacer()
                    
                    Button(folded ? "CV_UNFOLD" : "CV_FOLD") {
                        folded.toggle()
                    }
                }
                .padding(.bottom, 3)
                
                if !folded {
                    Text(comment.content)
                }
            }
        }
    }
}

struct CommentView_Previews: PreviewProvider {
    static var previews: some View {
        CommentView(comment: placeHolderComment, inset: 3)
    }
}
