//
//  User.swift
//  SCP Utility
//
//  Created by Maximus Harding on 7/1/23.
//

import Foundation

struct User {
    let username: String?
    let about: String?
    let wikidotID: String?
    let thumbnail: URL?
    let realname: String?
    let from: String?
    let website: URL?
    let creation: Date?
    let karma: Int? // 0-5
    
    init(
        username: String? = nil,
        about: String? = nil,
        wikidotID: String? = nil,
        thumbnail: URL? = nil,
        realname: String? = nil,
        from: String? = nil,
        website: URL? = nil,
        creation: Date? = nil,
        karma: Int? = nil
    ) {
        self.username = username
        self.about = about
        self.wikidotID = wikidotID
        self.thumbnail = thumbnail
        self.realname = realname
        self.from = from
        self.website = website
        self.creation = creation
        self.karma = karma
    }
}

let placeholderUser = User(
    username: "Zyn",
    about: "This user likes to keep an air of mystery about themselves.",
    wikidotID: "99999",
    thumbnail: URL(string: "https://www.wikidot.com/avatar.php?userid=1404533"),
    realname: "Zynny boy",
    from: "the world.",
    website: URL(string: "https://www.google.com"),
    creation: Date(),
    karma: 5
)
