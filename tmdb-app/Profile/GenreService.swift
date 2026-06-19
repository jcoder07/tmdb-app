//
//  GenreService.swift
//  tmdb-app
//

import Foundation

protocol GenreServiceProtocol {
    func fetchMovieGenres() async throws -> [GenreItem]
    func fetchTVGenres() async throws -> [GenreItem]
}

final class GenreService: GenreServiceProtocol {

    private let httpClient: HttpClientProtocol

    init(httpClient: HttpClientProtocol) {
        self.httpClient = httpClient
    }

    func fetchMovieGenres() async throws -> [GenreItem] {
        let data = try await httpClient.get(url: Constants.Urls.movieGenres)
        return try JSONDecoder().decode(GenreListResponse.self, from: data).genres
    }

    func fetchTVGenres() async throws -> [GenreItem] {
        let data = try await httpClient.get(url: Constants.Urls.tvGenres)
        return try JSONDecoder().decode(GenreListResponse.self, from: data).genres
    }
}
