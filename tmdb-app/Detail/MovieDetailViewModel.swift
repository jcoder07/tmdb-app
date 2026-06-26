//
//  MovieDetailViewModel.swift
//  tmdb-app
//

import SwiftUI

@MainActor
final class MovieDetailViewModel: ObservableObject {

    @Published var detail: MovieDetail?
    @Published var cast: [CastMember] = []
    @Published var reviews: [Review] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showFullCast = false

    private let movieId: Int
    private let service: MovieDetailServiceProtocol

    init(movieId: Int, service: MovieDetailServiceProtocol) {
        self.movieId = movieId
        self.service = service
    }

    var displayedCast: [CastMember] { showFullCast ? cast : Array(cast.prefix(6)) }

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
}
