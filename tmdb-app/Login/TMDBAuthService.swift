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

    // MARK: - Constants

    private let apiKey = Bundle.main.infoDictionary?["TMDB_API_KEY"] as? String ?? ""
    private let baseURL = "https://api.themoviedb.org/3"

    // MARK: - Step 1: Create Request Token

    func createRequestToken(
        completion: @escaping (Result<RequestTokenResponse, Error>) -> Void
    ) {

        let urlString = "\(baseURL)/authentication/token/new?api_key=\(apiKey)"
        guard let url = URL(string: urlString) else {
            return
        }

        let request = URLRequest(url: url)

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
                let decoded = try JSONDecoder().decode(RequestTokenResponse.self, from: data)
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

        let urlString = "\(baseURL)/authentication/token/validate_with_login?api_key=\(apiKey)"
        guard let url = URL(string: urlString) else {
            return
        }

        var request = URLRequest(url: url)
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
                let decoded = try JSONDecoder().decode(RequestTokenResponse.self, from: data)
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

        let urlString = "\(baseURL)/authentication/session/new?api_key=\(apiKey)"
        guard let url = URL(string: urlString) else {
            return
        }

        var request = URLRequest(url: url)
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
                let decoded = try JSONDecoder().decode(CreateSessionResponse.self, from: data)
                completion(.success(decoded))
            } catch {
                completion(.failure(error))
            }

        }.resume()
    }
}
