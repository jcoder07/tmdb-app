//
//  TMDBAuthService.swift
//  tmdb-app
//
//  Created by Juan Fernandez on 07-01-26.
//

import Foundation

protocol TMDBAuthServiceProtocol {
    func createRequestToken(completion: @escaping (Result<RequestTokenResponse, Error>) -> Void)
    func validateLogin(username: String, password: String, requestToken: String, completion: @escaping (Result<RequestTokenResponse, Error>) -> Void)
    func createSession(requestToken: String, completion: @escaping (Result<CreateSessionResponse, Error>) -> Void)
}

final class TMDBAuthService: TMDBAuthServiceProtocol {

    // MARK: - Step 1: Create Request Token

    func createRequestToken(
        completion: @escaping (Result<RequestTokenResponse, Error>) -> Void
    ) {

        let request = URLRequest(url: Constants.Urls.requestToken)

        URLSession.shared.dataTask(with: request) { data, response, error in

            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                return
            }

            // 🔍 Debug REAL
            print("📦 Request Token RAW:")
            print(String(data: data, encoding: .utf8) ?? "No data")

            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let decoded = try decoder.decode(RequestTokenResponse.self, from: data)
                completion(.success(decoded))
            } catch {
                print("❌ Decode error:", error)
                completion(.failure(error))
            }

        }.resume()
    }

    // MARK: - Step 2: Validate Login

    func validateLogin(
        username: String,
        password: String,
        requestToken: String,
        completion: @escaping (Result<RequestTokenResponse, Error>) -> Void
    ) {

        var request = URLRequest(url: Constants.Urls.validateLogin)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "username": username,
            "password": password,
            "request_token": requestToken
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, response, error in

            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                return
            }

            // 🔍 Debug REAL
            print("📦 Validate Login RAW:")
            print(String(data: data, encoding: .utf8) ?? "No data")

            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let decoded = try decoder.decode(RequestTokenResponse.self, from: data)
                completion(.success(decoded))
            } catch {
                print("❌ Decode error:", error)
                completion(.failure(error))
            }

        }.resume()
    }
    
    // MARK: - Step 3: Create Session ID

    func createSession(
        requestToken: String,
        completion: @escaping (Result<CreateSessionResponse, Error>) -> Void
    ) {

        var request = URLRequest(url: Constants.Urls.createSession)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "request_token": requestToken
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, response, error in

            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                return
            }

            // 🔍 Debug real
            print("📦 Create Session RAW:")
            print(String(data: data, encoding: .utf8) ?? "No data")

            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let decoded = try decoder.decode(CreateSessionResponse.self, from: data)
                completion(.success(decoded))
            } catch {
                completion(.failure(error))
            }

        }.resume()
    }
}
