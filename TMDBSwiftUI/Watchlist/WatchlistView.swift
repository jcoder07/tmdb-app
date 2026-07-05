//
//  WatchlistView.swift
//  tmdb-app

import SwiftUI
import TMDBCore

struct WatchlistView: View {
    let viewModel: WatchlistViewModel

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
        .refreshable { await viewModel.load() }
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
                WatchlistListView(
                    isEmpty: viewModel.movies.isEmpty,
                    emptyLabel: "No movies in your watchlist",
                    canLoadMore: viewModel.canLoadMoreMovies,
                    isLoadingMore: viewModel.isLoadingMore,
                    onLoadMore: { Task { await viewModel.loadMore() } }
                ) {
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
                WatchlistListView(
                    isEmpty: viewModel.tvShows.isEmpty,
                    emptyLabel: "No TV shows in your watchlist",
                    canLoadMore: viewModel.canLoadMoreTVShows,
                    isLoadingMore: viewModel.isLoadingMore,
                    onLoadMore: { Task { await viewModel.loadMore() } }
                ) {
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
    let canLoadMore: Bool
    let isLoadingMore: Bool
    let onLoadMore: () -> Void
    @ViewBuilder let content: () -> Content

    var body: some View {
        if isEmpty {
            WatchlistEmptyView(label: emptyLabel)
        } else {
            List {
                content()
                if canLoadMore {
                    Button(action: onLoadMore) {
                        if isLoadingMore {
                            HStack {
                                Spacer()
                                ProgressView()
                                Spacer()
                            }
                        } else {
                            Text("Load More")
                                .fontWeight(.semibold)
                                .foregroundStyle(Color(hex: "01B4E4"))
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .buttonStyle(.plain)
                    .padding(.vertical, 8)
                }
            }
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
        AsyncImage(url: url) { phase in
            switch phase {
            case .success(let image):
                image
                    .resizable()
                    .scaledToFill()
            default:
                Rectangle()
                    .foregroundStyle(.quaternary)
                    .overlay {
                        Image(systemName: "film")
                            .foregroundStyle(.tertiary)
                    }
            }
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


