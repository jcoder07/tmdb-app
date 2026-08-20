//
//  URLSessionHTTPClient.swift
//  Mvvm
//
//  Created by Juan Fernandez on 20-08-26.
//

import Foundation

struct URLSessionHTTPClient: HTTPClientProtocol {

    private let session: URLSessionProtocol
    private let decoder: JSONDecoder

    init(
        session: URLSessionProtocol,
        decoder: JSONDecoder
    ) {
        self.session = session
        self.decoder = decoder
    }

    func get<T: Decodable & Sendable>(
        url: URL,
        as type: T.Type
    ) async throws -> T {

        let (data, response) = try await session.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              200..<300 ~= httpResponse.statusCode else {
            throw URLError(.badServerResponse)
        }

        return try decoder.decode(
            T.self,
            from: data
        )
    }
}

