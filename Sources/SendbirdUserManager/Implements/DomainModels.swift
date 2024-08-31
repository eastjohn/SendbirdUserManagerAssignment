//
//  DomainModels.swift
//
//
//  Created by 김요한 on 8/31/24.
//

import Foundation

enum APIConstants {
    static let baseURL = "https://api-{application_id}.sendbird.com/v3"
    static let createUserEndPoint = "/users"
    static let updateUserEndPoint = "/users/{user_id}"
    static let getUserEndPoint = "/users/{user_id}"
    static let getUsersEndPoint = "/users"
}

struct Session {
    let applicationId: String
    let apiToken: String
}
