//
//  HomeView.swift
//  tmdb-app
//
//  Created by Juan Fernandez on 07-01-26.
//

import SwiftUI

struct HomeView: View {

    @ObservedObject var viewModel: HomeViewModel

    var body: some View {
        VStack(spacing: 20) {
            Text("🎬 Welcome to TMDB")
                .font(.system(size: 22, weight: .bold))

            Button("Logout") {
                viewModel.logout()
            }
            .buttonStyle(.borderedProminent)
        }
        .navigationTitle("Home")
    }
}
