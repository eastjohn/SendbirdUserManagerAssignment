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

    func createResponseMaker() -> Responsible? {
        self as? Responsible
    }
}

protocol Requestable {
    func makeURLRequest(url: URL, headers: [String: String]) -> URLRequest?
}

protocol Responsible {
    func makeResponse<Response>(data: Data) -> Response?
}

enum Method: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
}

struct ErrorMessageResponse: Decodable {
    let message: String
    let code: Int
    let error: Bool
}
