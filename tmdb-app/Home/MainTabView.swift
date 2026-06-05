//
//  MainTabView.swift
//  tmdb-app
//

import SwiftUI

struct MainTabView: View {
    let homeViewModel: HomeViewModel

    var body: some View {
        TabView {
            NavigationStack {
                HomeView(viewModel: homeViewModel)
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
                WatchlistView()
            }
            .tabItem { Label("Watchlist", systemImage: "bookmark") }

            NavigationStack {
                SearchView()
            }
            .tabItem { Label("Search", systemImage: "magnifyingglass") }
        }
    }
}
