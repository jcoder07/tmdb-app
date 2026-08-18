import SwiftUI
import TMDBCore

struct SearchView: View {
    @Bindable var viewModel: SearchViewModel
    let makeMovieDetailViewModel: (Int) -> MovieDetailViewModel
    let makeSeriesDetailViewModel: (Int) -> SeriesDetailViewModel
    let makePersonDetailViewModel: (Int) -> PersonDetailViewModel
    let makeGenreResultsViewModel: (GenreItem) -> GenreResultsViewModel
    let makeBrowseResultsViewModel: (BrowseKind) -> BrowseResultsViewModel

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        Group {
            if viewModel.query.isEmpty {
                idleView
            } else if viewModel.isSearching && viewModel.suggestions.isEmpty {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if !viewModel.query.isEmpty && viewModel.suggestions.isEmpty && !viewModel.isSearching {
                emptyResultsView
            } else {
                suggestionsList
            }
        }
        .navigationTitle("Search")
        .searchable(text: $viewModel.query, prompt: "Movies, shows, people...")
        .onChange(of: viewModel.query) {
            viewModel.search()
        }
        .navigationDestination(for: SearchRoute.self) { route in
            switch route {
            case .movie(let id):
                MovieDetailView(viewModel: makeMovieDetailViewModel(id))
            case .series(let id):
                SeriesDetailView(viewModel: makeSeriesDetailViewModel(id))
            case .person(let id):
                PersonDetailView(
                    viewModel: makePersonDetailViewModel(id),
                    makeMovieDetailViewModel: makeMovieDetailViewModel,
                    makeSeriesDetailViewModel: makeSeriesDetailViewModel
                )
            case .genre(let genre):
                GenreResultsView(
                    viewModel: makeGenreResultsViewModel(genre),
                    makeMovieDetailViewModel: makeMovieDetailViewModel,
                    makeSeriesDetailViewModel: makeSeriesDetailViewModel
                )
            case .browse(let kind):
                BrowseResultsView(
                    viewModel: makeBrowseResultsViewModel(kind),
                    makeMovieDetailViewModel: makeMovieDetailViewModel,
                    makeSeriesDetailViewModel: makeSeriesDetailViewModel,
                    makePersonDetailViewModel: makePersonDetailViewModel
                )
            }
        }
        .task { await viewModel.loadGenres() }
    }

    // MARK: - Idle (empty query)

    private var idleView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Discover section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Discover")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.horizontal, 16)

                    LazyVGrid(columns: columns, spacing: 12) {
                        NavigationLink(value: SearchRoute.browse(.movies)) {
                            DiscoverCard(
                                title: "Movies",
                                symbol: "film",
                                color: SearchPalette.discoverColors[0]
                            )
                        }
                        .buttonStyle(.plain)
                        .accessibilityIdentifier("search.discover.movies")

                        NavigationLink(value: SearchRoute.browse(.tv)) {
                            DiscoverCard(
                                title: "TV Series",
                                symbol: "tv",
                                color: SearchPalette.discoverColors[1]
                            )
                        }
                        .buttonStyle(.plain)
                        .accessibilityIdentifier("search.discover.tv")

                        NavigationLink(value: SearchRoute.browse(.people)) {
                            DiscoverCard(
                                title: "Actors",
                                symbol: "person.2",
                                color: SearchPalette.discoverColors[2]
                            )
                        }
                        .buttonStyle(.plain)
                        .accessibilityIdentifier("search.discover.people")
                    }
                    .padding(.horizontal, 16)
                }

                // Categories section
                if !viewModel.genres.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Categories")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal, 16)

                        LazyVGrid(columns: columns, spacing: 12) {
                            ForEach(Array(viewModel.genres.enumerated()), id: \.element.id) { index, genre in
                                NavigationLink(value: SearchRoute.genre(genre)) {
                                    CategoryCard(
                                        name: genre.name,
                                        color: SearchPalette.categoryColors[index % SearchPalette.categoryColors.count]
                                    )
                                }
                                .buttonStyle(.plain)
                                .accessibilityIdentifier("search.category.\(genre.id)")
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                } else if viewModel.isLoadingGenres {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding(.top, 20)
                }
            }
            .padding(.vertical, 16)
        }
    }

    // MARK: - Suggestions list

    private var suggestionsList: some View {
        List(viewModel.suggestions) { result in
            NavigationLink(value: searchRoute(for: result)) {
                SuggestionRow(result: result)
            }
            .accessibilityIdentifier("search.suggestion.\(result.id)")
        }
        .listStyle(.plain)
    }

    // MARK: - Empty results

    private var emptyResultsView: some View {
        VStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 44))
                .foregroundStyle(.secondary)
            Text("No results for \"\(viewModel.query)\"")
                .font(.headline)
            Text("Try a different search term.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityIdentifier("search.emptyResults")
    }

    private func searchRoute(for result: SearchResult) -> SearchRoute {
        switch result {
        case .movie(let m):  return .movie(m.id)
        case .series(let s): return .series(s.id)
        case .person(let p): return .person(p.id)
        }
    }
}
