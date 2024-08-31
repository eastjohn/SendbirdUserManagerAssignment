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

typealias DTOModel = Request & Requestable & Responsible

struct CreateUserRequest: DTOModel, Encodable {
    typealias Response = UserResponse

    let userId: String
    let nickname: String
    let profileUrl: String?

    enum CodingKeys: String, CodingKey {
        case userId
        case nickname
        case profileUrl
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(userId, forKey: .userId)
        try container.encode(nickname, forKey: .nickname)
        try container.encode(profileUrl, forKey: .profileUrl)
    }

    struct UserResponse: Decodable {
        let userId: String
        let nickname: String
        let profileUrl: String?
    }

    func makeURLRequest(url: URL, headers: [String: String]) -> URLRequest? {
        var urlRequest = URLRequest(url: url.appendingPathComponent(APIConstants.createUserEndPoint))
        urlRequest.httpMethod = Method.post.rawValue
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        guard let body = try? encoder.encode(self) else { return nil }
        urlRequest.httpBody = body
        headers.forEach { key, value in
            urlRequest.addValue(value, forHTTPHeaderField: key)
        }
        return urlRequest
    }

    func makeResponse<Response>(data: Data) -> Response? {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try? decoder.decode(UserResponse.self, from: data) as? Response
    }
}

struct UpdateUserRequest: DTOModel {
    typealias Response = UpdateUserResponse

    let userId: String
    let nickname: String?
    let profileUrl: String?

    struct UpdateUserResponse: Decodable {
        let userId: String
        let nickname: String
        let profileUrl: String?
    }

    func makeURLRequest(url: URL, headers: [String: String]) -> URLRequest? {
        var urlRequest = URLRequest(url: url.appendingPathComponent(APIConstants.updateUserEndPoint.replacingOccurrences(of: "{user_id}", with: userId)))
        urlRequest.httpMethod = Method.put.rawValue
        var body: [String: String] = [:]
        if let nickname {
            body["nickname"] = nickname
        }
        if let profileUrl {
            body["profileUrl"] = profileUrl
        }
        guard let httpBody = try? JSONSerialization.data(withJSONObject: body) else { return nil }
        urlRequest.httpBody = httpBody
        headers.forEach { key, value in
            urlRequest.addValue(value, forHTTPHeaderField: key)
        }
        return urlRequest
    }

    func makeResponse<Response>(data: Data) -> Response? {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try? decoder.decode(UpdateUserResponse.self, from: data) as? Response
    }
}

struct GetUserRequest: DTOModel {
    typealias Response = GetUserResponse

    let userId: String

    struct GetUserResponse: Decodable {
        let userId: String
        let nickName: String
        let profileUrl: String?
    }

    func makeURLRequest(url: URL, headers: [String: String]) -> URLRequest? {
        var urlRequest = URLRequest(url: url.appendingPathComponent(APIConstants.getUserEndPoint.replacingOccurrences(of: "{user_id}", with: userId)))
        urlRequest.httpMethod = Method.get.rawValue
        headers.forEach { key, value in
            urlRequest.addValue(value, forHTTPHeaderField: key)
        }
        return urlRequest
    }

    func makeResponse<Response>(data: Data) -> Response? {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try? decoder.decode(GetUserResponse.self, from: data) as? Response
    }
}
