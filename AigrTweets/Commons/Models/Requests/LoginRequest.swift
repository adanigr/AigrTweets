//
//  LoginRequest.swift
//  AigrTweets
//
//  Created by Adan Reséndiz on 25/06/20.
//  Copyright © 2020 Adan Reséndiz. All rights reserved.
//

import Foundation

struct LoginRequest: Codable {
    let email: String
    let password: String
}
