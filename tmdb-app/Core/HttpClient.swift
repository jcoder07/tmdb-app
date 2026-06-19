//
//  HttpClient.swift
//  tmdb-app
//

import Foundation

// MARK: - Errors

enum NetworkError: Error {
    case badRequest
    case serverError(String)
    case decodingError
    case invalidResponse
}

extension NetworkError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .badRequest:
            return NSLocalizedString("Unable to perform request", comment: "badRequestError")
        case .serverError(let message):
            return NSLocalizedString(message, comment: "serverError")
        case .decodingError:
            return NSLocalizedString("Unable to decode successfully.", comment: "decodingError")
        case .invalidResponse:
            return NSLocalizedString("Invalid response", comment: "invalidResponse")
        }
    }
}

// MARK: - HTTP Method

enum HTTPMethod {
    case get([URLQueryItem])
    case post(Data?)
    case delete

    var name: String {
        switch self {
        case .get:    return "GET"
        case .post:   return "POST"
        case .delete: return "DELETE"
        }
    }
}

// MARK: - Resource

struct Resource<T: Decodable> {
    let url: URL
    var method: HTTPMethod = .get([])
    var modelType: T.Type
}

// MARK: - Protocol

protocol HttpClientProtocol {
    func load<T: Decodable>(_ resource: Resource<T>) async throws -> T
}

// MARK: - Data Extension

private extension Data {
    var prettyPrintedJSON: String {
        guard let object = try? JSONSerialization.jsonObject(with: self),
              let pretty = try? JSONSerialization.data(withJSONObject: object, options: .prettyPrinted),
              let string = String(data: pretty, encoding: .utf8) else {
            return String(data: self, encoding: .utf8) ?? ""
        }
        return string
    }
}

// MARK: - Implementation

struct HttpClient: HttpClientProtocol {

    private var defaultHeaders: [String: String] {
        ["Content-Type": "application/json"]
    }

    func load<T: Decodable>(_ resource: Resource<T>) async throws -> T {
        var request: URLRequest

        switch resource.method {
        case .get(let queryItems):
            if queryItems.isEmpty {
                request = URLRequest(url: resource.url)
            } else {
                var components = URLComponents(url: resource.url, resolvingAgainstBaseURL: false)
                let existing = components?.queryItems ?? []
                components?.queryItems = existing + queryItems
                guard let url = components?.url else { throw NetworkError.badRequest }
                request = URLRequest(url: url)
            }

        case .post(let data):
            request = URLRequest(url: resource.url)
            request.httpMethod = HTTPMethod.post(nil).name
            request.httpBody = data

        case .delete:
            request = URLRequest(url: resource.url)
            request.httpMethod = HTTPMethod.delete.name
        }

        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = defaultHeaders
        let session = URLSession(configuration: configuration)

        let (data, response) = try await session.data(for: request)

        guard response is HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let result: T
        do {
            result = try decoder.decode(resource.modelType, from: data)
            
            #if DEBUG
            let allHeaders = defaultHeaders.merging(request.allHTTPHeaderFields ?? [:]) { _, requestValue in requestValue }
            print("🟢 URL: \(request.url?.absoluteString ?? "")",
                  "Headers: \(allHeaders)",
                  "Method: \(request.httpMethod ?? "")",
                  "Request: \(request.httpBody?.prettyPrintedJSON ?? "")",
                  "Response: \(data.prettyPrintedJSON)",
                  separator: "\n",
                  terminator: "\n"
            )
            #endif
        } catch(let error) {
            #if DEBUG
            print("🔴 Error: \(error)")
            #endif
            throw NetworkError.decodingError
        }

        return result
    }
}
