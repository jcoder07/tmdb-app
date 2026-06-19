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

    func fetchAccountId(sessionId: String) async throws -> Int {
        let (data, _) = try await URLSession.shared.data(from: Constants.Urls.account(sessionId: sessionId))
        return try JSONDecoder().decode(AccountDetails.self, from: data).id
    }

    func fetchMovies(accountId: Int, sessionId: String) async throws -> [WatchlistMovie] {
        let (data, _) = try await URLSession.shared.data(from: Constants.Urls.watchlistMovies(accountId: accountId, sessionId: sessionId))
        return try JSONDecoder().decode(WatchlistResponse<WatchlistMovie>.self, from: data).results
    }

    func fetchTVShows(accountId: Int, sessionId: String) async throws -> [WatchlistTVShow] {
        let (data, _) = try await URLSession.shared.data(from: Constants.Urls.watchlistTVShows(accountId: accountId, sessionId: sessionId))
        return try JSONDecoder().decode(WatchlistResponse<WatchlistTVShow>.self, from: data).results
    }
}
