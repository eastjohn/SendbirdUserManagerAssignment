//
//  MockNetworkClient.swift
//  SendbirdUserManagerTests
//
//  Created by Sendbird
//

import Foundation
import SendbirdUserManager

class MockNetworkClient: SBNetworkClient {
    var responses: [Any] = []
    
    required init() {
        
    }
    
    func request<R>(request: R, completionHandler: @escaping (Result<R.Response, Error>) -> Void) where R : Request {
        let nextResponse = responses.first
        
        let currentTimestamp = Date().timeIntervalSince1970
        requestTimestamps.append(currentTimestamp)
        
        // Check if the request violates rate limits
        requestTimestamps = requestTimestamps.filter { currentTimestamp - $0 <= rateLimitTimeWindow }
        if requestTimestamps.count > rateLimitCount {
            completionHandler(.failure(NetworkError.rateLimitExceeded))
            return
        }
        
        switch nextResponse {
        case let response as R.Response:
            completionHandler(.success(response))
        case let error as Error:
            completionHandler(.failure(error))
        default:
            completionHandler(.failure(NSError(domain: "aa", code: 1)))
        }
    }
    
    // For rate limiting
    private var requestTimestamps: [TimeInterval] = []
    let rateLimitCount = 10
    let rateLimitTimeWindow: TimeInterval = 1.0  // 1 second
}
