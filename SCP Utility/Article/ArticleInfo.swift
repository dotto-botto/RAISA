//
//  ArticleInfo.swift
//  SCP Utility
//
//  Created by Maximus Harding on 4/3/23.
//

import Foundation

/// Struct made to store info about articles from the Crom API.
struct ArticleInfo: Codable {
    let rating: Int
    let tags: [String]
    let createdAt: String
    let createdBy: String
    let userRank: Int
    let userTotalRating: Int
    let userMeanRating: Int
    let userPageCount: Int
    
    init(
        rating: Int,
        tags: [String],
        createdAt: String,
        createdBy: String,
        userRank: Int,
        userTotalRating: Int,
        userMeanRating: Int,
        userPageCount: Int
    ) {
        self.rating = rating
        self.tags = tags
        self.createdAt = createdAt
        self.createdBy = createdBy
        self.userRank = userRank
        self.userTotalRating = userTotalRating
        self.userMeanRating = userMeanRating
        self.userPageCount = userPageCount
    }
}
