//
//  URLSessionHTTPClient.swift
//  Mvvm
//
//  Created by Juan Fernandez on 20-08-26.
//

import Foundation

final class URLSessionHTTPClient: HttpClientProtocol {

    func get(url: URL) async throws -> Data {
        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              200..<300 ~= httpResponse.statusCode else {
            throw URLError(.badServerResponse)
        }

        return data
    }
}
