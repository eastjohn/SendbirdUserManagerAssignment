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
