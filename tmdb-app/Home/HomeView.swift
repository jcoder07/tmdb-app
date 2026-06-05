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
        Text("🎬 Welcome to TMDB")
            .font(.system(size: 22, weight: .bold))
            .navigationTitle("Home")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        viewModel.logout()
                    } label: {
                        Image(systemName: "person.circle.fill")
                            .imageScale(.large)
                    }
                }
            }
    }
}
