//
//  TMDBAuthService.swift
//  tmdb-app
//

import Foundation
import TMDBCore

protocol TMDBAuthServiceProtocol {
    func createRequestToken() async throws -> RequestTokenResponse
    func validateLogin(username: String, password: String, requestToken: String) async throws
    func createSession(requestToken: String) async throws -> CreateSessionResponse
}

final class TMDBAuthService: TMDBAuthServiceProtocol {

    private let httpClient: HttpClientProtocol

    init(httpClient: HttpClientProtocol) {
        self.httpClient = httpClient
    }

    // MARK: - Step 1: Create Request Token

    func createRequestToken() async throws -> RequestTokenResponse {
        let resource = Resource(url: Constants.Urls.requestToken, modelType: RequestTokenResponse.self)
        return try await httpClient.load(resource)
    }

    // MARK: - Step 2: Validate Login

    func validateLogin(username: String, password: String, requestToken: String) async throws {
        let resource = try Resource(
            url: Constants.Urls.validateLogin,
            body: ValidateLoginRequest(username: username, password: password, requestToken: requestToken),
            modelType: RequestTokenResponse.self
        )
        _ = try await httpClient.load(resource)
    }

    // MARK: - Step 3: Create Session ID

    func createSession(requestToken: String) async throws -> CreateSessionResponse {
        let resource = try Resource(
            url: Constants.Urls.createSession,
            body: CreateSessionRequest(requestToken: requestToken),
            modelType: CreateSessionResponse.self
        )
        return try await httpClient.load(resource)
    }
}
