//
//  WatchlistViewModel.swift
//  tmdb-app
//

import Foundation

@MainActor
final class WatchlistViewModel: ObservableObject {

    enum Tab { case movies, tvShows }

    @Published var selectedTab: Tab = .movies
    @Published var movies: [WatchlistMovie] = []
    @Published var tvShows: [WatchlistTVShow] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let service: WatchlistServiceProtocol
    private let sessionManager: SessionManagerProtocol

    init(service: WatchlistServiceProtocol, sessionManager: SessionManagerProtocol) {
        self.service = service
        self.sessionManager = sessionManager
    }

    func load() async {
        guard let sessionId = sessionManager.getSession() else { return }
        isLoading = true
        errorMessage = nil
        do {
            let accountId = try await service.fetchAccountId(sessionId: sessionId)
            async let moviesTask = service.fetchMovies(accountId: accountId, sessionId: sessionId)
            async let tvShowsTask = service.fetchTVShows(accountId: accountId, sessionId: sessionId)
            (movies, tvShows) = try await (moviesTask, tvShowsTask)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
