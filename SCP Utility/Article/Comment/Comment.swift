//
//  Comment.swift
//  SCP Utility
//
//  Created by Maximus Harding on 4/29/23.
//

import Foundation

/// Struct that defines comments.
struct Comment: Hashable {
    let username: String
    let content: String
    let profilepic: URL?
    let date: Date?
    
    /// - Parameters:
    ///   - content: The content of the comment.
    ///   - profilepic: A link to the user's profile picture.
    ///   - date: The time the coment was made. (unused)
    init(
        username: String,
        content: String,
        profilepic: URL?,
        date: Date?
    ) {
        self.username = username
        self.content = content
        self.profilepic = profilepic
        self.date = date
    }
}

let placeHolderComment = Comment(
    username: "Zyn",
    content: """
Posting at the top of the discussion for visibility.

To anyone wondering why this page is locked:

Please see this Admin Post on how to propose additions to this page.

EDIT: New entries cannot be added to the original page, due to it reaching the Wikidot character limit. Further entries can be added to Experiment Log T-98816-OC108/682 (Extension) instead.

Staff may edit or remove any entries, at will.
""",
    profilepic: URL(string: "https://www.wikidot.com/avatar.php?userid=1404533"),
    date: Date()
)
