//
//  ProfileService.swift
//  tmdb-app
//

import Foundation

protocol ProfileServiceProtocol {
    func fetchAccountDetails(sessionId: String) async throws -> AccountProfile
    func fetchRatedMovies(accountId: Int, sessionId: String) async throws -> [RatedMovie]
    func fetchRatedTVShows(accountId: Int, sessionId: String) async throws -> [RatedTVShow]
    func fetchMovieGenres() async throws -> [GenreItem]
    func fetchTVGenres() async throws -> [GenreItem]
}

final class ProfileService: ProfileServiceProtocol {

    private let apiKey = Bundle.main.infoDictionary?["TMDB_API_KEY"] as? String ?? ""
    private let baseURL = "https://api.themoviedb.org/3"

    func fetchAccountDetails(sessionId: String) async throws -> AccountProfile {
        let url = URL(string: "\(baseURL)/account?api_key=\(apiKey)&session_id=\(sessionId)")!
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode(AccountProfile.self, from: data)
    }

    func fetchRatedMovies(accountId: Int, sessionId: String) async throws -> [RatedMovie] {
        let url = URL(string: "\(baseURL)/account/\(accountId)/rated/movies?api_key=\(apiKey)&session_id=\(sessionId)")!
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode(RatedResponse<RatedMovie>.self, from: data).results
    }

    func fetchRatedTVShows(accountId: Int, sessionId: String) async throws -> [RatedTVShow] {
        let url = URL(string: "\(baseURL)/account/\(accountId)/rated/tv?api_key=\(apiKey)&session_id=\(sessionId)")!
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode(RatedResponse<RatedTVShow>.self, from: data).results
    }

    func fetchMovieGenres() async throws -> [GenreItem] {
        let url = URL(string: "\(baseURL)/genre/movie/list?api_key=\(apiKey)")!
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode(GenreListResponse.self, from: data).genres
    }

    func fetchTVGenres() async throws -> [GenreItem] {
        let url = URL(string: "\(baseURL)/genre/tv/list?api_key=\(apiKey)")!
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode(GenreListResponse.self, from: data).genres
    }
}
