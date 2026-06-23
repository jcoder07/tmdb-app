//
//  MoviesViewModel.swift
//  tmdb-app
//

import SwiftUI

@MainActor
final class MoviesViewModel: ObservableObject {

    @Published var movies: [PopularMovie] = []
    @Published var displayedCount = 8
    @Published var isLoading = false
    @Published var isLoadingMore = false
    @Published var errorMessage: String?

    private var currentPage = 1
    private var totalPages = 1
    private let service: MoviesServiceProtocol
    let detailService: MovieDetailServiceProtocol

    init(service: MoviesServiceProtocol, detailService: MovieDetailServiceProtocol) {
        self.service = service
        self.detailService = detailService
    }

    var displayedMovies: [PopularMovie] { Array(movies.prefix(displayedCount)) }
    var canShowMore: Bool { displayedCount < movies.count || currentPage < totalPages }

    func load() async {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil
        do {
            let response = try await service.fetchPopularMovies(page: 1)
            movies = response.results
            totalPages = response.totalPages
            currentPage = 1
            displayedCount = min(8, response.results.count)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func showMore() async {
        let nextCount = displayedCount + 8
        if nextCount > movies.count && currentPage < totalPages {
            isLoadingMore = true
            do {
                let response = try await service.fetchPopularMovies(page: currentPage + 1)
                movies += response.results
                currentPage += 1
            } catch { }
            isLoadingMore = false
        }
        displayedCount = min(nextCount, movies.count)
    }
}
