import SwiftUI
import TMDBCore

struct FavoritesView: View {
    let viewModel: FavoritesViewModel

    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let error = viewModel.errorMessage {
                MediaErrorView(message: error) {
                    Task { await viewModel.load() }
                }
            } else {
                FavoritesContentView(viewModel: viewModel)
            }
        }
        .task { await viewModel.load() }
        .refreshable { await viewModel.load() }
    }
}

private struct FavoritesContentView: View {
    @Bindable var viewModel: FavoritesViewModel

    var body: some View {
        VStack(spacing: 0) {
            Picker("Type", selection: $viewModel.selectedTab) {
                Text("Movies").tag(FavoritesViewModel.Tab.movies)
                Text("TV Shows").tag(FavoritesViewModel.Tab.tvShows)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            .padding(.vertical, 8)

            switch viewModel.selectedTab {
            case .movies:
                MediaListView(
                    isEmpty: viewModel.movies.isEmpty,
                    emptyLabel: "No movies in your favorites",
                    canLoadMore: viewModel.canLoadMoreMovies,
                    isLoadingMore: viewModel.isLoadingMore,
                    onLoadMore: { Task { await viewModel.loadMore() } }
                ) {
                    ForEach(viewModel.movies) { movie in
                        MediaItemRow(
                            title: movie.title,
                            overview: movie.overview,
                            posterURL: movie.posterURL,
                            voteAverage: movie.voteAverage,
                            year: movie.releaseDate.map { String($0.prefix(4)) }
                        )
                    }
                }
            case .tvShows:
                MediaListView(
                    isEmpty: viewModel.tvShows.isEmpty,
                    emptyLabel: "No TV shows in your favorites",
                    canLoadMore: viewModel.canLoadMoreTVShows,
                    isLoadingMore: viewModel.isLoadingMore,
                    onLoadMore: { Task { await viewModel.loadMore() } }
                ) {
                    ForEach(viewModel.tvShows) { show in
                        MediaItemRow(
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
