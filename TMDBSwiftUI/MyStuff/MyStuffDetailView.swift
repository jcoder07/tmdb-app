import SwiftUI
import TMDBCore

struct MyStuffDetailView: View {
    let destination: MyStuffDestination
    let watchlistViewModel: WatchlistViewModel
    let favoritesViewModel: FavoritesViewModel
    let myStuffViewModel: MyStuffViewModel
    let moviesViewModel: MoviesViewModel
    let seriesViewModel: SeriesViewModel

    var body: some View {
        Group {
            switch destination {
            case .favoriteMovies:
                FavoriteMoviesDetailList(viewModel: favoritesViewModel)
                    .task { await favoritesViewModel.load() }
                    .refreshable { await favoritesViewModel.load() }
            case .favoriteTVShows:
                FavoriteTVDetailList(viewModel: favoritesViewModel)
                    .task { await favoritesViewModel.load() }
                    .refreshable { await favoritesViewModel.load() }
            case .watchlistMovies:
                WatchlistMoviesDetailList(viewModel: watchlistViewModel)
                    .task { await watchlistViewModel.load() }
                    .refreshable { await watchlistViewModel.load() }
            case .watchlistTVShows:
                WatchlistTVDetailList(viewModel: watchlistViewModel)
                    .task { await watchlistViewModel.load() }
                    .refreshable { await watchlistViewModel.load() }
            case .listMovies(let listId):
                CustomListDetailList(listId: listId, mediaType: "movie", viewModel: myStuffViewModel)
                    .task { await myStuffViewModel.fetchListItems(listId: listId) }
            case .listTVShows(let listId):
                CustomListDetailList(listId: listId, mediaType: "tv", viewModel: myStuffViewModel)
                    .task { await myStuffViewModel.fetchListItems(listId: listId) }
            case .movieDetail, .seriesDetail:
                EmptyView()
            }
        }
        .navigationTitle(navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var navigationTitle: String {
        switch destination {
        case .favoriteMovies: return "Favorite Movies"
        case .favoriteTVShows: return "Favorite TV Series"
        case .watchlistMovies: return "Watchlist Movies"
        case .watchlistTVShows: return "Watchlist TV Series"
        case .listMovies(let listId):
            let base = myStuffViewModel.userLists.first(where: { $0.id == listId })
                .map { myStuffViewModel.displayName(for: $0) } ?? "List"
            return "\(base) — Movies"
        case .listTVShows(let listId):
            let base = myStuffViewModel.userLists.first(where: { $0.id == listId })
                .map { myStuffViewModel.displayName(for: $0) } ?? "List"
            return "\(base) — TV Series"
        case .movieDetail, .seriesDetail:
            return ""
        }
    }
}

// MARK: - Favorite Movies

private struct FavoriteMoviesDetailList: View {
    let viewModel: FavoritesViewModel

    var body: some View {
        Group {
            if viewModel.isLoading && viewModel.movies.isEmpty {
                ProgressView().frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if viewModel.movies.isEmpty {
                MediaEmptyView(label: "No movies in your favorites")
            } else {
                List {
                    ForEach(viewModel.movies) { movie in
                        NavigationLink(value: MyStuffDestination.movieDetail(id: movie.id)) {
                            MediaItemRow(
                                title: movie.title,
                                overview: movie.overview,
                                posterURL: movie.posterURL,
                                voteAverage: movie.voteAverage,
                                year: movie.releaseDate.map { String($0.prefix(4)) }
                            )
                        }
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                Task { await viewModel.removeMovie(id: movie.id) }
                            } label: {
                                Label("Remove", systemImage: "heart.slash")
                            }
                        }
                    }
                }
                .listStyle(.plain)
            }
        }
    }
}

// MARK: - Favorite TV Shows

private struct FavoriteTVDetailList: View {
    let viewModel: FavoritesViewModel

    var body: some View {
        Group {
            if viewModel.isLoading && viewModel.tvShows.isEmpty {
                ProgressView().frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if viewModel.tvShows.isEmpty {
                MediaEmptyView(label: "No TV shows in your favorites")
            } else {
                List {
                    ForEach(viewModel.tvShows) { show in
                        NavigationLink(value: MyStuffDestination.seriesDetail(id: show.id)) {
                            MediaItemRow(
                                title: show.name,
                                overview: show.overview,
                                posterURL: show.posterURL,
                                voteAverage: show.voteAverage,
                                year: show.firstAirDate.map { String($0.prefix(4)) }
                            )
                        }
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                Task { await viewModel.removeTVShow(id: show.id) }
                            } label: {
                                Label("Remove", systemImage: "heart.slash")
                            }
                        }
                    }
                }
                .listStyle(.plain)
            }
        }
    }
}

// MARK: - Watchlist Movies

private struct WatchlistMoviesDetailList: View {
    let viewModel: WatchlistViewModel

    var body: some View {
        Group {
            if viewModel.isLoading && viewModel.movies.isEmpty {
                ProgressView().frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if viewModel.movies.isEmpty {
                MediaEmptyView(label: "No movies in your watchlist")
            } else {
                List {
                    ForEach(viewModel.movies) { movie in
                        NavigationLink(value: MyStuffDestination.movieDetail(id: movie.id)) {
                            MediaItemRow(
                                title: movie.title,
                                overview: movie.overview,
                                posterURL: movie.posterURL,
                                voteAverage: movie.voteAverage,
                                year: movie.releaseDate.map { String($0.prefix(4)) }
                            )
                        }
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                Task { await viewModel.removeMovie(id: movie.id) }
                            } label: {
                                Label("Remove", systemImage: "bookmark.slash")
                            }
                        }
                    }
                }
                .listStyle(.plain)
            }
        }
    }
}

// MARK: - Watchlist TV Shows

private struct WatchlistTVDetailList: View {
    let viewModel: WatchlistViewModel

    var body: some View {
        Group {
            if viewModel.isLoading && viewModel.tvShows.isEmpty {
                ProgressView().frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if viewModel.tvShows.isEmpty {
                MediaEmptyView(label: "No TV shows in your watchlist")
            } else {
                List {
                    ForEach(viewModel.tvShows) { show in
                        NavigationLink(value: MyStuffDestination.seriesDetail(id: show.id)) {
                            MediaItemRow(
                                title: show.name,
                                overview: show.overview,
                                posterURL: show.posterURL,
                                voteAverage: show.voteAverage,
                                year: show.firstAirDate.map { String($0.prefix(4)) }
                            )
                        }
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                Task { await viewModel.removeTVShow(id: show.id) }
                            } label: {
                                Label("Remove", systemImage: "bookmark.slash")
                            }
                        }
                    }
                }
                .listStyle(.plain)
            }
        }
    }
}

// MARK: - Custom List Items

private struct CustomListDetailList: View {
    let listId: Int
    let mediaType: String
    let viewModel: MyStuffViewModel

    private var items: [ListItem] {
        (viewModel.listItems[listId] ?? []).filter { $0.mediaType == mediaType }
    }

    private var isLoaded: Bool {
        viewModel.listItems[listId] != nil
    }

    var body: some View {
        Group {
            if !isLoaded {
                ProgressView().frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if items.isEmpty {
                MediaEmptyView(label: mediaType == "movie" ? "No movies in this list" : "No TV shows in this list")
            } else {
                List {
                    ForEach(items) { item in
                        NavigationLink(
                            value: item.mediaType == "movie"
                                ? MyStuffDestination.movieDetail(id: item.id)
                                : MyStuffDestination.seriesDetail(id: item.id)
                        ) {
                            MediaItemRow(
                                title: item.displayTitle,
                                overview: "",
                                posterURL: item.posterURL,
                                voteAverage: item.voteAverage,
                                year: nil
                            )
                        }
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                Task { await viewModel.removeFromList(listId: listId, mediaId: item.id) }
                            } label: {
                                Label("Remove", systemImage: "minus.circle")
                            }
                        }
                    }
                }
                .listStyle(.plain)
            }
        }
    }
}
