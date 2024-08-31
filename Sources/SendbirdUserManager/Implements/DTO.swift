//
//  DTO.swift
//
//
//  Created by 김요한 on 8/31/24.
//

import Foundation

extension Request {
    func createRequestMaker() -> Requestable? {
        self as? Requestable
    }
}

protocol Requestable {
    func makeURLRequest(url: URL, headers: [String: String]) -> URLRequest?
}
