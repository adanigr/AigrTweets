//
//  LoginResponse.swift
//  AigrTweets
//
//  Created by Adan Reséndiz on 25/06/20.
//  Copyright © 2020 Adan Reséndiz. All rights reserved.
//

import Foundation

struct LoginResponse: Codable {
    let user: User
    let token: String
}
