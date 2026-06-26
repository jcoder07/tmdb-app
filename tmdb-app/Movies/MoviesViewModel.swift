//
//  MoviesViewModel.swift
//  tmdb-app
//

import SwiftUI

@MainActor
final class MoviesViewModel: ObservableObject {

    @Published var movies: [Movie] = []
    @Published var displayedCount = 8
    @Published var isLoading = false
    @Published var isLoadingMore = false
    @Published var errorMessage: String?

    private var currentPage = 1
    private var totalPages = 1
    private let service: MoviesServiceProtocol
    private let detailService: MovieDetailServiceProtocol
    private var detailViewModels: [Int: MovieDetailViewModel] = [:]

    init(service: MoviesServiceProtocol, detailService: MovieDetailServiceProtocol) {
        self.service = service
        self.detailService = detailService
    }

    func makeDetailViewModel(for movieId: Int) -> MovieDetailViewModel {
        if let existing = detailViewModels[movieId] { return existing }
        let vm = MovieDetailViewModel(movieId: movieId, service: detailService)
        detailViewModels[movieId] = vm
        return vm
    }

    var displayedMovies: [Movie] { Array(movies.prefix(displayedCount)) }
    var canShowMore: Bool { displayedCount < movies.count || currentPage < totalPages }

    func load() async {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil
        do {
            let page = try await service.fetchPopularMovies(page: 1)
            movies = page.movies
            totalPages = page.totalPages
            currentPage = 1
            displayedCount = min(8, page.movies.count)
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
                let page = try await service.fetchPopularMovies(page: currentPage + 1)
                movies += page.movies
                currentPage += 1
            } catch { }
            isLoadingMore = false
        }
        displayedCount = min(nextCount, movies.count)
    }
}
