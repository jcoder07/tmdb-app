//
//  AccountService.swift
//  tmdb-app
//

import Foundation

protocol AccountServiceProtocol {
    func fetchAccountDetails(sessionId: String) async throws -> AccountProfile
    func fetchRatedMovies(accountId: Int, sessionId: String) async throws -> [RatedMovie]
    func fetchRatedTVShows(accountId: Int, sessionId: String) async throws -> [RatedTVShow]
}

final class AccountService: AccountServiceProtocol {

    private let httpClient: HttpClientProtocol

    init(httpClient: HttpClientProtocol) {
        self.httpClient = httpClient
    }

    func fetchAccountDetails(sessionId: String) async throws -> AccountProfile {
        let data = try await httpClient.get(url: Constants.Urls.account(sessionId: sessionId))
        return try JSONDecoder().decode(AccountProfile.self, from: data)
    }

    func fetchRatedMovies(accountId: Int, sessionId: String) async throws -> [RatedMovie] {
        let data = try await httpClient.get(url: Constants.Urls.ratedMovies(accountId: accountId, sessionId: sessionId))
        return try JSONDecoder().decode(RatedResponse<RatedMovie>.self, from: data).results
    }

    func fetchRatedTVShows(accountId: Int, sessionId: String) async throws -> [RatedTVShow] {
        let data = try await httpClient.get(url: Constants.Urls.ratedTVShows(accountId: accountId, sessionId: sessionId))
        return try JSONDecoder().decode(RatedResponse<RatedTVShow>.self, from: data).results
    }
}
