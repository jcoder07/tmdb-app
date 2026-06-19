//
//  MainTabView.swift
//  tmdb-app
//

import SwiftUI

struct MainTabView: View {
    let homeViewModel: HomeViewModel
    let watchlistViewModel: WatchlistViewModel
    let profileViewModel: ProfileViewModel

    var body: some View {
        TabView {
            NavigationStack {
                HomeView(viewModel: homeViewModel, profileViewModel: profileViewModel)
            }
            .tabItem { Label("Home", systemImage: "house") }

            NavigationStack {
                MoviesView()
            }
            .tabItem { Label("Movies", systemImage: "film") }

            NavigationStack {
                SeriesView()
            }
            .tabItem { Label("Series", systemImage: "tv") }

            NavigationStack {
                WatchlistView(viewModel: watchlistViewModel)
            }
            .tabItem { Label("Watchlist", systemImage: "bookmark") }

            NavigationStack {
                SearchView()
            }
            .tabItem { Label("Search", systemImage: "magnifyingglass") }
        }
    }
}
