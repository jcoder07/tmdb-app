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
        let resource = Resource(url: Constants.Urls.account(sessionId: sessionId), modelType: AccountProfile.self)
        return try await httpClient.load(resource)
    }

    func fetchRatedMovies(accountId: Int, sessionId: String) async throws -> [RatedMovie] {
        let resource = Resource(url: Constants.Urls.ratedMovies(accountId: accountId, sessionId: sessionId), modelType: RatedResponse<RatedMovie>.self)
        return try await httpClient.load(resource).results
    }

    func fetchRatedTVShows(accountId: Int, sessionId: String) async throws -> [RatedTVShow] {
        let resource = Resource(url: Constants.Urls.ratedTVShows(accountId: accountId, sessionId: sessionId), modelType: RatedResponse<RatedTVShow>.self)
        return try await httpClient.load(resource).results
    }
}
