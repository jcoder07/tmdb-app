//
//  MovieDetailViewModel.swift
//  tmdb-app
//

import SwiftUI
import Observation

@MainActor
@Observable
final class MovieDetailViewModel {

    var detail: MovieDetail?
    private(set) var cast: [CastMember] = []       { didSet { recomputeDisplayedCast() } }
    private(set) var displayedCast: [CastMember] = []
    var reviews: [Review] = []
    var isLoading = false
    var errorMessage: String?
    var showFullCast = false                        { didSet { recomputeDisplayedCast() } }

    private let movieId: Int
    private let service: MovieDetailServiceProtocol

    init(movieId: Int, service: MovieDetailServiceProtocol) {
        self.movieId = movieId
        self.service = service
    }

    func load() async {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil
        do {
            async let detailTask  = service.fetchMovieDetail(id: movieId)
            async let creditsTask = service.fetchCredits(id: movieId)
            async let reviewsTask = service.fetchReviews(id: movieId)
            (detail, cast, reviews) = try await (detailTask, creditsTask, reviewsTask)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    private func recomputeDisplayedCast() {
        displayedCast = showFullCast ? cast : Array(cast.prefix(6))
    }
}
