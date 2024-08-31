//
//  NetworkClientImpl.swift
//
//
//  Created by 김요한 on 8/31/24.
//

import Foundation

final class NetworkClientImpl: SBNetworkClient {
    func request<R: Request>(
        request: R,
        completionHandler: @escaping (Result<R.Response, Error>) -> Void
    ) {
    }
}
