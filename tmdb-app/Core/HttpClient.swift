//
//  HttpClient.swift
//  tmdb-app
//

import Foundation

protocol HttpClientProtocol {
    func get(url: URL) async throws -> Data
    func post(url: URL, body: [String: Any]) async throws -> Data
}

final class HttpClient: HttpClientProtocol {

    func get(url: URL) async throws -> Data {
        let (data, _) = try await URLSession.shared.data(from: url)
        return data
    }

    func post(url: URL, body: [String: Any]) async throws -> Data {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        let (data, _) = try await URLSession.shared.data(for: request)
        return data
    }
}
