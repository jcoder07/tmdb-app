//
//  MainTabView.swift
//  tmdb-app
//

import SwiftUI

struct MainTabView: View {
    let homeViewModel: HomeViewModel
    let watchlistViewModel: WatchlistViewModel
    let profileViewModel: ProfileViewModel
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

            NavigationStack { MoviesView() }
            .tabItem { Label("Movies", systemImage: "film") }
            .tag(1)

            NavigationStack { SeriesView() }
            .tabItem { Label("Series", systemImage: "tv") }
            .tag(2)

            NavigationStack { WatchlistView(viewModel: watchlistViewModel) }
            .tabItem { Label("Watchlist", systemImage: "bookmark") }
            .tag(3)

            NavigationStack { SearchView() }
            .tabItem { Label("Search", systemImage: "magnifyingglass") }
            .tag(4)
        }
    }
}
