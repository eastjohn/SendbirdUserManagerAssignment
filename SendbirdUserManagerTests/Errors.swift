//
//  Errors.swift
//  
//
//  Created by Sendbird
//

import Foundation

enum UserManagerError: Error {
    case exceededMaximumUsers
}

enum NetworkError: Error {
    case rateLimitExceeded
}
