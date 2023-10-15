//
//  NetworkClient.swift
//  
//
//  Created by Sendbird
//

import Foundation

public protocol Request {
    associatedtype Response
}

public protocol SBNetworkClient {
    init()
    
    func request<R: Request>(
        request: R,
        completionHandler: @escaping (Result<R.Response, Error>) -> Void
    )
}

public protocol SBNetworkClientTestable: SBNetworkClient {
     
}
