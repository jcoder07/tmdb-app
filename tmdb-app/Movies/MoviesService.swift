//
//  MoviesService.swift
//  tmdb-app
//

import Foundation

protocol MoviesServiceProtocol {
    func fetchPopularMovies(page: Int) async throws -> PopularMoviesResponse
}

final class MoviesService: MoviesServiceProtocol {

    private let httpClient: HttpClientProtocol

    init(httpClient: HttpClientProtocol) {
        self.httpClient = httpClient
    }

    func fetchPopularMovies(page: Int) async throws -> PopularMoviesResponse {
        let resource = Resource(url: Constants.Urls.popularMovies(page: page), modelType: PopularMoviesResponse.self)
        return try await httpClient.load(resource)
    }
}
