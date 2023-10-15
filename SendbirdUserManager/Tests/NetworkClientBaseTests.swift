//
//  NetworkClientBaseTests.swift
//  SendbirdUserManager
//
//  Created by Sendbird
//

import Foundation
import XCTest

struct TestRequest: Request {
    typealias Response = Data
}

class NetworkClientBaseTests: XCTestCase {
    func networkClientType() -> SBNetworkClient.Type! {
        return nil
    }
    
    func testMockNetworkClientRateLimiting() {
        let mockClient = networkClientType().init()
        
        // Define a request
        let request = TestRequest()
        
        // Concurrently send 11 requests
        let dispatchGroup = DispatchGroup()
        var responses: [Result<Data, Error>] = []
        
        for _ in 0..<11 {
            dispatchGroup.enter()
            mockClient.request(request: request) { response in
                responses.append(response)
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.wait()
        
        // Expect 10 successful and 1 rateLimitExceeded response
        let successResponses = responses.filter {
            if case .success = $0 { return true }
            return false
        }
        let rateLimitResponses = responses.filter {
            if case .failure(let error) = $0 { return true }
            return false
        }
        
        XCTAssertEqual(successResponses.count, 10)
        XCTAssertEqual(rateLimitResponses.count, 1)
    }
}
