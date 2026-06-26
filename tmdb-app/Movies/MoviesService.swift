//
//  MoviesService.swift
//  tmdb-app
//

import Foundation
import TMDBCore

protocol MoviesServiceProtocol {
    func fetchPopularMovies(page: Int) async throws -> MoviesPage
}

final class MoviesService: MoviesServiceProtocol {

    private let httpClient: HttpClientProtocol

    init(httpClient: HttpClientProtocol) {
        self.httpClient = httpClient
    }

    func fetchPopularMovies(page: Int) async throws -> MoviesPage {
        let resource = Resource(url: Constants.Urls.popularMovies(page: page), modelType: PopularMoviesResponseDTO.self)
        return MoviesPage(try await httpClient.load(resource))
    }
}
