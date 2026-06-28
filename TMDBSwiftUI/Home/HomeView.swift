//
//  HomeView.swift
//  tmdb-app
//
//  Created by Juan Fernandez on 07-01-26.
//

import SwiftUI
import TMDBCore

struct HomeView: View {

    let viewModel: HomeViewModel
    let profileViewModel: ProfileViewModel
    let onGoToWatchlist: () -> Void
    @State private var showingProfile = false

    var body: some View {
        Text("🎬 Welcome to TMDB")
            .font(.system(size: 22, weight: .bold))
            .navigationTitle("Home")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingProfile = true
                    } label: {
                        Image(systemName: "person.circle.fill")
                            .imageScale(.large)
                    }
                }
            }
            .sheet(isPresented: $showingProfile) {
                ProfileView(viewModel: profileViewModel, onGoToWatchlist: {
                    showingProfile = false
                    onGoToWatchlist()
                })
            }
    }
}
