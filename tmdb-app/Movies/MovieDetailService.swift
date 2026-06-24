//
//  MovieDetailService.swift
//  tmdb-app
//

import Foundation

protocol MovieDetailServiceProtocol {
    func fetchMovieDetail(id: Int) async throws -> MovieDetail
    func fetchCredits(id: Int) async throws -> CreditsResponse
    func fetchReviews(id: Int) async throws -> ReviewsResponse
}

final class MovieDetailService: MovieDetailServiceProtocol {

    private let httpClient: HttpClientProtocol

    init(httpClient: HttpClientProtocol = HttpClient()) {
        self.httpClient = httpClient
    }

    func fetchMovieDetail(id: Int) async throws -> MovieDetail {
        let resource = Resource(url: Constants.Urls.movieDetail(id: id), modelType: MovieDetail.self)
        return try await httpClient.load(resource)
    }

    func fetchCredits(id: Int) async throws -> CreditsResponse {
        let resource = Resource(url: Constants.Urls.movieCredits(id: id), modelType: CreditsResponse.self)
        return try await httpClient.load(resource)
    }

    func fetchReviews(id: Int) async throws -> ReviewsResponse {
        let resource = Resource(url: Constants.Urls.movieReviews(id: id), modelType: ReviewsResponse.self)
        return try await httpClient.load(resource)
    }
}
