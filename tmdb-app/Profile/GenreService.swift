//
//  GenreService.swift
//  tmdb-app
//

import Foundation
import TMDBCore

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
        let resource = Resource(url: Constants.Urls.movieGenres, modelType: GenreListResponseDTO.self)
        return try await httpClient.load(resource).genres.map(GenreItem.init)
    }

    func fetchTVGenres() async throws -> [GenreItem] {
        let resource = Resource(url: Constants.Urls.tvGenres, modelType: GenreListResponseDTO.self)
        return try await httpClient.load(resource).genres.map(GenreItem.init)
    }
}
