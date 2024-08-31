//
//  DomainModels.swift
//
//
//  Created by 김요한 on 8/31/24.
//

import Foundation

enum APIConstants {
    static let baseURL = "https://api-{application_id}.sendbird.com/v3"
}

struct Session {
    let applicationId: String
    let apiToken: String
}
