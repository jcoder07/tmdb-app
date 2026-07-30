//
//  MainTabView.swift
//  tmdb-app

import SwiftUI
import TMDBCore

struct MainTabView: View {
    let homeViewModel: HomeViewModel
    let moviesViewModel: MoviesViewModel
    let seriesViewModel: SeriesViewModel
    let watchlistViewModel: WatchlistViewModel
    let favoritesViewModel: FavoritesViewModel
    let myStuffViewModel: MyStuffViewModel
    let profileViewModel: ProfileViewModel
    let searchViewModel: SearchViewModel
    let makeMovieDetailViewModel: (Int) -> MovieDetailViewModel
    let makeSeriesDetailViewModel: (Int) -> SeriesDetailViewModel
    let makePersonDetailViewModel: (Int) -> PersonDetailViewModel
    let makeGenreResultsViewModel: (GenreItem) -> GenreResultsViewModel
    let makeBrowseResultsViewModel: (BrowseKind) -> BrowseResultsViewModel
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                HomeView(viewModel: homeViewModel, profileViewModel: profileViewModel, onGoToWatchlist: {
                    selectedTab = 3
                })
            }
            .tabItem { Label("Home", systemImage: "house") }
            .tag(0)

            NavigationStack {
                MoviesView(
                    viewModel: moviesViewModel,
                    makeMovieDetailViewModel: makeMovieDetailViewModel
                )
            }
            .tabItem { Label("Movies", systemImage: "film") }
            .tag(1)

            NavigationStack {
                SeriesView(
                    viewModel: seriesViewModel,
                    makeSeriesDetailViewModel: makeSeriesDetailViewModel
                )
            }
            .tabItem { Label("Series", systemImage: "tv") }
            .tag(2)

            NavigationStack {
                MyStuffView(
                    watchlistViewModel: watchlistViewModel,
                    favoritesViewModel: favoritesViewModel,
                    myStuffViewModel: myStuffViewModel,
                    moviesViewModel: moviesViewModel,
                    seriesViewModel: seriesViewModel,
                    makeMovieDetailViewModel: makeMovieDetailViewModel,
                    makeSeriesDetailViewModel: makeSeriesDetailViewModel
                )
            }
            .tabItem { Label("My Stuff", systemImage: "bookmark") }
            .tag(3)

            NavigationStack {
                SearchView(
                    viewModel: searchViewModel,
                    makeMovieDetailViewModel: makeMovieDetailViewModel,
                    makeSeriesDetailViewModel: makeSeriesDetailViewModel,
                    makePersonDetailViewModel: makePersonDetailViewModel,
                    makeGenreResultsViewModel: makeGenreResultsViewModel,
                    makeBrowseResultsViewModel: makeBrowseResultsViewModel
                )
            }
            .tabItem { Label("Search", systemImage: "magnifyingglass") }
            .tag(4)
        }
    }
}
