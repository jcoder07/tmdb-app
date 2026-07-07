//
//  HttpClient2.swift
//  TMDBCore
//
//  Created by Juan Fernandez on 07-07-26.
//

import Foundation

// MARK: - HTTP Client Error

public enum HTTPClientError: Error {
    case invalidResponse
    case invalidStatusCode(Int)
}

// MARK: - HTTP Client

public struct HttpClient2: HttpClientProtocol {
    private let session: URLSession

    public init(session: URLSession = .shared) {
        self.session = session
    }

    public func load<T: Decodable>(_ resource: Resource<T>) async throws -> T {
        var request = URLRequest(url: resource.url)
        request.httpMethod = resource.method.name

        switch resource.method {
        case .get(let queryItems):
            guard var components = URLComponents(url: resource.url, resolvingAgainstBaseURL: false) else {
                throw HTTPClientError.invalidResponse
            }
            if !queryItems.isEmpty {
                components.queryItems = queryItems
            }
            guard let url = components.url else {
                throw HTTPClientError.invalidResponse
            }
            request.url = url

        case .post(let data):
            request.httpBody = data
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        case .delete:
            break
        }

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw HTTPClientError.invalidResponse
        }

        guard (200..<300).contains(httpResponse.statusCode) else {
            throw HTTPClientError.invalidStatusCode(httpResponse.statusCode)
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(resource.modelType, from: data)
    }
}
