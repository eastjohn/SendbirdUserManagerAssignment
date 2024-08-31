//
//  Errors.swift
//
//
//  Created by 김요한 on 8/31/24.
//

import Foundation

enum SBNetworkClientError: Error {
    case networkError(description: String)
    case notInitialized
    case failedToEncoding
    case failedToDecoding
    case notImplementResponsible
    case rateLimitExceeded
}

extension SBNetworkClientError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .networkError(description: let description):
            "networkError: \(description)"

        case .notInitialized:
            "notInitialized"

        case .failedToEncoding:
            ".failedToEncoding"

        case .failedToDecoding:
            ".failedToDecoding"

        case .notImplementResponsible:
            ".notImplementResponsible"

        case .rateLimitExceeded:
            ".rateLimitExceeded"
        }
    }
}

enum SBUserManagerError: Error {
    case nilSelf
    case notInitialized
    case invalidSession
    case userIdLengthExceeded
    case nicknameLengthExceeded
    case profileUrlLengthExcceded
    case emptyUserId
    case emptyNickname
    case alreadyExistUser
    case creatingUsersExceeded
    case failedContinueCreateUsers(createdUsers: [SBUser], failedUsers: [(user: SBUser, reason: Error)])
}

extension SBUserManagerError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .nilSelf:
            "The object has been destroyed."

        case .notInitialized:
            "Not initialized."

        case .invalidSession:
            "The session is invalid."

        case .userIdLengthExceeded:
            "The userId exceeded the limited length."

        case .nicknameLengthExceeded:
            "The nickname exceeded the limited length."

        case .profileUrlLengthExcceded:
            "The profile url exceeded the limited length."

        case .emptyUserId:
            "The userId is an empty string."

        case .emptyNickname:
            "The nickname is an empty string."

        case .alreadyExistUser:
            "The user already exists."

        case .creatingUsersExceeded:
            "The number of users you tried to create exceeded the limit."

        case let .failedContinueCreateUsers(createdUsers, failedUsers):
            "Partially completed user creation. (Success: \(createdUsers.count), Failure: \(failedUsers.count)"
        }
    }
}
