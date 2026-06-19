//
//  WatchlistService.swift
//  tmdb-app
//

import Foundation

protocol WatchlistServiceProtocol {
    func fetchAccountId(sessionId: String) async throws -> Int
    func fetchMovies(accountId: Int, sessionId: String) async throws -> [WatchlistMovie]
    func fetchTVShows(accountId: Int, sessionId: String) async throws -> [WatchlistTVShow]
}

final class WatchlistService: WatchlistServiceProtocol {

    private let httpClient: HttpClientProtocol

    init(httpClient: HttpClientProtocol) {
        self.httpClient = httpClient
    }

    func fetchAccountId(sessionId: String) async throws -> Int {
        let resource = Resource(url: Constants.Urls.account(sessionId: sessionId), modelType: AccountDetails.self)
        return try await httpClient.load(resource).id
    }

    func fetchMovies(accountId: Int, sessionId: String) async throws -> [WatchlistMovie] {
        let resource = Resource(url: Constants.Urls.watchlistMovies(accountId: accountId, sessionId: sessionId), modelType: WatchlistResponse<WatchlistMovie>.self)
        return try await httpClient.load(resource).results
    }

    func fetchTVShows(accountId: Int, sessionId: String) async throws -> [WatchlistTVShow] {
        let resource = Resource(url: Constants.Urls.watchlistTVShows(accountId: accountId, sessionId: sessionId), modelType: WatchlistResponse<WatchlistTVShow>.self)
        return try await httpClient.load(resource).results
    }
}
