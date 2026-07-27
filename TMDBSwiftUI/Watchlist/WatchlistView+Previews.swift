//
//  WatchlistView+Previews.swift
//  tmdb-app
//

import SwiftUI
import TMDBCore

// MARK: - Shared mock infrastructure

private struct MockWatchlistService: WatchlistServiceProtocol {
    
    var movieResults: [WatchlistMovie] = []
    var tvShowResults: [WatchlistTVShow] = []
    var totalPages: Int = 1
    var shouldFail = false
    var shouldHang = false

    func fetchMovies(accountId: Int, sessionId: String, page: Int) async throws -> (items: [WatchlistMovie], totalPages: Int) {
        if shouldHang { try await Task.sleep(nanoseconds: .max) }
        if shouldFail { throw URLError(.notConnectedToInternet) }
        return (movieResults, totalPages)
    }

    func fetchTVShows(accountId: Int, sessionId: String, page: Int) async throws -> (items: [WatchlistTVShow], totalPages: Int) {
        if shouldHang { try await Task.sleep(nanoseconds: .max) }
        if shouldFail { throw URLError(.notConnectedToInternet) }
        return (tvShowResults, totalPages)
    }

    func removeMovie(accountId: Int, movieId: Int, sessionId: String) async throws {}
    func removeTVShow(accountId: Int, seriesId: Int, sessionId: String) async throws {}
}

private struct MockFavoritesService: FavoritesServiceProtocol {
    var movieResults: [FavoriteMovie] = []
    var tvShowResults: [FavoriteTVShow] = []
    var totalPages: Int = 1
    var shouldFail = false
    var shouldHang = false

    func fetchMovies(accountId: Int, sessionId: String, page: Int) async throws -> (items: [FavoriteMovie], totalPages: Int) {
        if shouldHang { try await Task.sleep(nanoseconds: .max) }
        if shouldFail { throw URLError(.notConnectedToInternet) }
        return (movieResults, totalPages)
    }

    func fetchTVShows(accountId: Int, sessionId: String, page: Int) async throws -> (items: [FavoriteTVShow], totalPages: Int) {
        if shouldHang { try await Task.sleep(nanoseconds: .max) }
        if shouldFail { throw URLError(.notConnectedToInternet) }
        return (tvShowResults, totalPages)
    }

    func removeMovie(accountId: Int, movieId: Int, sessionId: String) async throws {}
    func removeTVShow(accountId: Int, seriesId: Int, sessionId: String) async throws {}
}

private struct MockAccountService: AccountServiceProtocol {
    func fetchAccountDetails(sessionId: String) async throws -> AccountProfile {
        AccountProfile(id: 1, displayName: "Preview", avatarURL: nil)
    }

    func fetchRatedMovies(accountId: Int, sessionId: String) async throws -> [RatedMovie] { [] }
    func fetchRatedTVShows(accountId: Int, sessionId: String) async throws -> [RatedTVShow] { [] }
}

private struct MockSessionManager: SessionManagerProtocol {
    func saveSession(id: String) {}
    func getSession() -> String? { "preview_session" }
    func clearSession() {}
    var isLoggedIn: Bool { true }
}

// MARK: - Sample data

private let sampleMovies: [WatchlistMovie] = [
    WatchlistMovie(
        id: 1, title: "Inception",
        overview: "A thief who steals corporate secrets through the use of dream-sharing technology is given the inverse task of planting an idea into the mind of a C.E.O.",
        posterURL: nil, voteAverage: 8.4, releaseDate: "2010-07-16"
    ),
    WatchlistMovie(
        id: 2, title: "The Dark Knight",
        overview: "When the menace known as the Joker wreaks havoc and chaos on the people of Gotham, Batman must accept one of the greatest psychological and physical tests of his ability to fight injustice.",
        posterURL: nil, voteAverage: 9.0, releaseDate: "2008-07-18"
    ),
    WatchlistMovie(
        id: 3, title: "Interstellar",
        overview: "A team of explorers travel through a wormhole in space in an attempt to ensure humanity's survival.",
        posterURL: nil, voteAverage: 8.7, releaseDate: "2014-11-07"
    )
]

private let sampleTVShows: [WatchlistTVShow] = [
    WatchlistTVShow(
        id: 1, name: "Breaking Bad",
        overview: "A high school chemistry teacher diagnosed with inoperable lung cancer turns to manufacturing and selling methamphetamine in order to secure his family's future.",
        posterURL: nil, voteAverage: 9.5, firstAirDate: "2008-01-20"
    ),
    WatchlistTVShow(
        id: 2, name: "The Last of Us",
        overview: "Joel, a hardened survivor, is hired to smuggle Ellie out of an oppressive quarantine zone. What starts as a small job soon becomes a brutal, heartbreaking journey.",
        posterURL: nil, voteAverage: 8.8, firstAirDate: "2023-01-15"
    )
]

private let sampleFavoriteMovies: [FavoriteMovie] = [
    FavoriteMovie(
        id: 10, title: "The Godfather",
        overview: "The aging patriarch of an organized crime dynasty transfers control of his clandestine empire to his reluctant son.",
        posterURL: nil, voteAverage: 9.2, releaseDate: "1972-03-24"
    ),
    FavoriteMovie(
        id: 11, title: "Pulp Fiction",
        overview: "The lives of two mob hitmen, a boxer, a gangster and his wife, and a pair of diner bandits intertwine in four tales of violence and redemption.",
        posterURL: nil, voteAverage: 8.9, releaseDate: "1994-10-14"
    )
]

private let sampleFavoriteTVShows: [FavoriteTVShow] = [
    FavoriteTVShow(
        id: 20, name: "Chernobyl",
        overview: "In April 1986, an explosion at the Chernobyl nuclear power plant in the USSR becomes one of the world's worst man-made catastrophes.",
        posterURL: nil, voteAverage: 9.4, firstAirDate: "2019-05-06"
    )
]

// MARK: - View model helpers

@MainActor
private func previewWatchlistViewModel(
    service: MockWatchlistService = MockWatchlistService(),
    selectedTab: WatchlistViewModel.Tab = .movies
) -> WatchlistViewModel {
    let vm = WatchlistViewModel(service: service, accountService: MockAccountService(), sessionManager: MockSessionManager())
    vm.selectedTab = selectedTab
    return vm
}

@MainActor
private func previewFavoritesViewModel(
    service: MockFavoritesService = MockFavoritesService(),
    selectedTab: FavoritesViewModel.Tab = .movies
) -> FavoritesViewModel {
    let vm = FavoritesViewModel(service: service, accountService: MockAccountService(), sessionManager: MockSessionManager())
    vm.selectedTab = selectedTab
    return vm
}

// MARK: - WatchlistView previews

#Preview("Watchlist – Movies") {
    NavigationStack {
        WatchlistView(viewModel: previewWatchlistViewModel(
            service: MockWatchlistService(movieResults: sampleMovies, tvShowResults: sampleTVShows)
        ))
    }
}

#Preview("Watchlist – TV Shows") {
    NavigationStack {
        WatchlistView(viewModel: previewWatchlistViewModel(
            service: MockWatchlistService(movieResults: sampleMovies, tvShowResults: sampleTVShows),
            selectedTab: .tvShows
        ))
    }
}

#Preview("Watchlist – Loading") {
    NavigationStack {
        WatchlistView(viewModel: previewWatchlistViewModel(
            service: MockWatchlistService(shouldHang: true)
        ))
    }
}

#Preview("Watchlist – Empty") {
    NavigationStack {
        WatchlistView(viewModel: previewWatchlistViewModel())
    }
}

#Preview("Watchlist – Error") {
    NavigationStack {
        WatchlistView(viewModel: previewWatchlistViewModel(
            service: MockWatchlistService(shouldFail: true)
        ))
    }
}

// MARK: - FavoritesView previews

#Preview("Favorites – Movies") {
    NavigationStack {
        FavoritesView(viewModel: previewFavoritesViewModel(
            service: MockFavoritesService(movieResults: sampleFavoriteMovies, tvShowResults: sampleFavoriteTVShows)
        ))
    }
}

#Preview("Favorites – Empty") {
    NavigationStack {
        FavoritesView(viewModel: previewFavoritesViewModel())
    }
}

