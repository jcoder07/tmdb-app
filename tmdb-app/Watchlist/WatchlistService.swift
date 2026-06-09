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

    private let apiKey = Bundle.main.infoDictionary?["TMDB_API_KEY"] as? String ?? ""
    private let baseURL = "https://api.themoviedb.org/3"

    func fetchAccountId(sessionId: String) async throws -> Int {
        let url = URL(string: "\(baseURL)/account?api_key=\(apiKey)&session_id=\(sessionId)")!
        let (data, _) = try await URLSession.shared.data(from: url)
        let account = try JSONDecoder().decode(AccountDetails.self, from: data)
        return account.id
    }

    func fetchMovies(accountId: Int, sessionId: String) async throws -> [WatchlistMovie] {
        let url = URL(string: "\(baseURL)/account/\(accountId)/watchlist/movies?api_key=\(apiKey)&session_id=\(sessionId)")!
        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(WatchlistResponse<WatchlistMovie>.self, from: data)
        return response.results
    }

    func fetchTVShows(accountId: Int, sessionId: String) async throws -> [WatchlistTVShow] {
        let url = URL(string: "\(baseURL)/account/\(accountId)/watchlist/tv?api_key=\(apiKey)&session_id=\(sessionId)")!
        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(WatchlistResponse<WatchlistTVShow>.self, from: data)
        return response.results
    }
}
