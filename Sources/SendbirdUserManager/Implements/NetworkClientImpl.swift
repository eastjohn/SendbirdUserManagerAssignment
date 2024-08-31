//
//  NetworkClientImpl.swift
//
//
//  Created by 김요한 on 8/31/24.
//

import Foundation

final class NetworkClientImpl: SBNetworkClient {
    private let urlSession: URLSession
    private var session: Session?
    private var headers: [String: String] {
        guard let session else { return [:] }
        return [
            "Content-Type": "application/json; charset=utf8",
            "Api-Token": session.apiToken
        ]
    }
    private var baseURL: URL? {
        guard let session else { return  nil }
        return URL(string: APIConstants.baseURL.replacingOccurrences(of: "{application_id}", with: session.applicationId))
    }
    private var lastRequestTime: TimeInterval = 0

    init(urlSession: URLSession = .shared) {
        self.urlSession = urlSession
    }

    func initialize(session: Session) {
        self.session = session
    }

    func request<R: Request>(
        request: R,
        completionHandler: @escaping (Result<R.Response, Error>) -> Void
    ) {
        guard let baseURL else {
            completionHandler(.failure(SBNetworkClientError.notInitialized))
            return
        }
        guard let requestMaker = request.createRequestMaker(),
              let urlRequest = requestMaker.makeURLRequest(url: baseURL, headers: headers) else {
            completionHandler(.failure(SBNetworkClientError.failedToEncoding))
            return
        }
        guard let responseMaker = request.createResponseMaker() else {
            completionHandler(.failure(SBNetworkClientError.notImplementResponsible))
            return
        }
        guard canRequest() else {
            completionHandler(.failure(SBNetworkClientError.rateLimitExceeded))
            return
        }
        lastRequestTime = Date().timeIntervalSinceReferenceDate

        let task = urlSession.dataTask(with: urlRequest) { data, response, error in
            if let error {
                completionHandler(.failure(SBNetworkClientError.networkError(description: error.localizedDescription)))
                return
            }
            guard let httpResponse = response as? HTTPURLResponse,
                  200..<300 ~= httpResponse.statusCode else {
                let errorMessage = Self.makeErrorMeesage(data: data, response: response)
                completionHandler(.failure(SBNetworkClientError.networkError(description: errorMessage)))
                return
            }
            guard let data,
                  let response: R.Response = responseMaker.makeResponse(data: data) else {
                completionHandler(.failure(SBNetworkClientError.failedToDecoding))
                return
            }
            completionHandler(.success(response))
        }
        task.resume()
    }
}

extension NetworkClientImpl {
    private func canRequest() -> Bool {
        return Date().timeIntervalSinceReferenceDate - lastRequestTime > 1
    }

    private static func makeErrorMeesage(data: Data?, response: URLResponse?) -> String {
        if let data,
           let errorResponse = try? JSONDecoder().decode(ErrorMessageResponse.self, from: data) {
            return errorResponse.description
        } else {
            let statusCode = if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                "\(statusCode)"
            } else {
                "UNKNOWN"
            }
            return "statusCode: \(statusCode)"
        }
    }
}

extension ErrorMessageResponse {
    var description: String {
        "errorCode: \(code), message: \(message)"
    }
}
