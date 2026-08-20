//
//  URLSessionProtocol.swift
//  Mvvm
//
//  Created by Juan Fernandez on 20-08-26.
//

import Foundation

protocol URLSessionProtocol {
    
    func data(
        from url: URL,
        delegate: (any URLSessionTaskDelegate)?
    ) async throws -> (Data, URLResponse)
    
}

extension URLSessionProtocol {
    
    func data(
        from url: URL,
        delegate: (any URLSessionTaskDelegate)? = nil
    ) async throws -> (Data, URLResponse) {
        try await self.data(from: url, delegate: delegate)
    }
    
}
