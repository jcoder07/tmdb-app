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

    private let accountService: AccountServiceProtocol
    private let genreService: GenreServiceProtocol

    init(accountService: AccountServiceProtocol, genreService: GenreServiceProtocol) {
        self.accountService = accountService
        self.genreService = genreService
    }

    func fetchAccountDetails(sessionId: String) async throws -> AccountProfile {
        try await accountService.fetchAccountDetails(sessionId: sessionId)
    }

    func fetchRatedMovies(accountId: Int, sessionId: String) async throws -> [RatedMovie] {
        try await accountService.fetchRatedMovies(accountId: accountId, sessionId: sessionId)
    }

    func fetchRatedTVShows(accountId: Int, sessionId: String) async throws -> [RatedTVShow] {
        try await accountService.fetchRatedTVShows(accountId: accountId, sessionId: sessionId)
    }

    func fetchMovieGenres() async throws -> [GenreItem] {
        try await genreService.fetchMovieGenres()
    }

    func fetchTVGenres() async throws -> [GenreItem] {
        try await genreService.fetchTVGenres()
    }
}
