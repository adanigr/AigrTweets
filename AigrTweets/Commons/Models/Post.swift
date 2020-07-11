//
//  Post.swift
//  AigrTweets
//
//  Created by Adan Reséndiz on 25/06/20.
//  Copyright © 2020 Adan Reséndiz. All rights reserved.
//

import Foundation

struct Post: Codable {
    let id: String
    let author: User
    let imageUrl: String
    let text: String
    let videoUrl: String
    let location: PostLocation
    let hasVideo: Bool
    let hasImage: Bool
    let hasLocation: Bool
    let createdAt: String
}
