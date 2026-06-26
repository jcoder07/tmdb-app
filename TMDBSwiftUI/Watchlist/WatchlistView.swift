//
//  WatchlistView.swift
//  tmdb-app

import SwiftUI
import TMDBCore

struct WatchlistView: View {
    var viewModel: WatchlistViewModel

    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let error = viewModel.errorMessage {
                WatchlistErrorView(message: error) {
                    Task { await viewModel.load() }
                }
            } else {
                WatchlistContentView(viewModel: viewModel)
            }
        }
        .navigationTitle("Watchlist")
        .navigationBarTitleDisplayMode(.inline)
        .task { await viewModel.load() }
    }
}

private struct WatchlistContentView: View {
    @Bindable var viewModel: WatchlistViewModel

    var body: some View {
        VStack(spacing: 0) {
            Picker("Type", selection: $viewModel.selectedTab) {
                Text("Movies").tag(WatchlistViewModel.Tab.movies)
                Text("TV Shows").tag(WatchlistViewModel.Tab.tvShows)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            .padding(.vertical, 8)

            switch viewModel.selectedTab {
            case .movies:
                WatchlistListView(isEmpty: viewModel.movies.isEmpty, emptyLabel: "No movies in your watchlist") {
                    ForEach(viewModel.movies) { movie in
                        WatchlistItemRow(
                            title: movie.title,
                            overview: movie.overview,
                            posterURL: movie.posterURL,
                            voteAverage: movie.voteAverage,
                            year: movie.releaseDate.map { String($0.prefix(4)) }
                        )
                    }
                }
            case .tvShows:
                WatchlistListView(isEmpty: viewModel.tvShows.isEmpty, emptyLabel: "No TV shows in your watchlist") {
                    ForEach(viewModel.tvShows) { show in
                        WatchlistItemRow(
                            title: show.name,
                            overview: show.overview,
                            posterURL: show.posterURL,
                            voteAverage: show.voteAverage,
                            year: show.firstAirDate.map { String($0.prefix(4)) }
                        )
                    }
                }
            }
        }
    }
}

private struct WatchlistListView<Content: View>: View {
    let isEmpty: Bool
    let emptyLabel: LocalizedStringKey
    @ViewBuilder let content: () -> Content

    var body: some View {
        if isEmpty {
            WatchlistEmptyView(label: emptyLabel)
        } else {
            List { content() }
                .listStyle(.plain)
        }
    }
}

private struct WatchlistItemRow: View {
    let title: String
    let overview: String
    let posterURL: URL?
    let voteAverage: Double
    let year: String?

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            PosterImage(url: posterURL)
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .lineLimit(2)
                HStack(spacing: 8) {
                    if let year {
                        Text(year)
                            .foregroundStyle(.secondary)
                    }
                    RatingBadge(value: voteAverage)
                }
                .font(.subheadline)
                Text(overview)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(3)
            }
        }
        .padding(.vertical, 4)
    }
}

private struct PosterImage: View {
    let url: URL?

    var body: some View {
        AsyncImage(url: url) { image in
            image
                .resizable()
                .scaledToFill()
        } placeholder: {
            Rectangle()
                .foregroundStyle(.quaternary)
        }
        .frame(width: 60, height: 90)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

private struct RatingBadge: View {
    let value: Double

    var body: some View {
        HStack(spacing: 2) {
            Image(systemName: "star.fill")
                .foregroundStyle(.yellow)
            Text(value, format: .number.precision(.fractionLength(1)))
        }
    }
}

private struct WatchlistEmptyView: View {
    let label: LocalizedStringKey

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "bookmark.slash")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            Text(label)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct WatchlistErrorView: View {
    let message: String
    let onRetry: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            Text(message)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
            Button("Retry", action: onRetry)
                .buttonStyle(.bordered)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Previews

private struct MockWatchlistService: WatchlistServiceProtocol {
    var movieResults: [WatchlistMovie] = []
    var tvShowResults: [WatchlistTVShow] = []
    var shouldFail = false
    var shouldHang = false

    func fetchAccountId(sessionId: String) async throws -> Int { 1 }

    func fetchMovies(accountId: Int, sessionId: String) async throws -> [WatchlistMovie] {
        if shouldHang { try await Task.sleep(nanoseconds: .max) }
        if shouldFail { throw URLError(.notConnectedToInternet) }
        return movieResults
    }

    func fetchTVShows(accountId: Int, sessionId: String) async throws -> [WatchlistTVShow] {
        if shouldHang { try await Task.sleep(nanoseconds: .max) }
        if shouldFail { throw URLError(.notConnectedToInternet) }
        return tvShowResults
    }
}

private struct MockSessionManager: SessionManagerProtocol {
    func saveSession(id: String) {}
    func getSession() -> String? { "preview_session" }
    func clearSession() {}
    var isLoggedIn: Bool { true }
}

@MainActor
private func previewViewModel(
    service: MockWatchlistService = MockWatchlistService(),
    selectedTab: WatchlistViewModel.Tab = .movies
) -> WatchlistViewModel {
    let vm = WatchlistViewModel(service: service, sessionManager: MockSessionManager())
    vm.selectedTab = selectedTab
    return vm
}

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

#Preview("Movies") {
    NavigationStack {
        WatchlistView(viewModel: previewViewModel(
            service: MockWatchlistService(movieResults: sampleMovies, tvShowResults: sampleTVShows)
        ))
    }
}

#Preview("TV Shows") {
    NavigationStack {
        WatchlistView(viewModel: previewViewModel(
            service: MockWatchlistService(movieResults: sampleMovies, tvShowResults: sampleTVShows),
            selectedTab: .tvShows
        ))
    }
}

#Preview("Loading") {
    NavigationStack {
        WatchlistView(viewModel: previewViewModel(
            service: MockWatchlistService(shouldHang: true)
        ))
    }
}

#Preview("Empty") {
    NavigationStack {
        WatchlistView(viewModel: previewViewModel())
    }
}

#Preview("Error") {
    NavigationStack {
        WatchlistView(viewModel: previewViewModel(
            service: MockWatchlistService(shouldFail: true)
        ))
    }
}
