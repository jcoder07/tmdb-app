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
        let resource = Resource(url: Constants.Urls.movieGenres, modelType: GenreListResponse.self)
        return try await httpClient.load(resource).genres
    }

    func fetchTVGenres() async throws -> [GenreItem] {
        let resource = Resource(url: Constants.Urls.tvGenres, modelType: GenreListResponse.self)
        return try await httpClient.load(resource).genres
    }
}
