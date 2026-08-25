//
//  DetailsView.swift
//  Mvvm
//
//  Created by Juan Fernandez on 18-08-26.
//

import SwiftUI

struct DetailsView: View {
    
    @StateObject var viewModel: DetailsViewModel
    
    var body: some View {
        VStack {
            if viewModel.isLoading {
                ProgressView("Loading")
            } else if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                Button("Retry") {
                    Task {
                        await viewModel.getDetails()
                    }
                }
            } else if let movie = viewModel.movie {
                Text(movie.originalTitle)
                Text(movie.overview)
                Text(movie.popularity, format: .number)
            }
        }
        .padding()
        .task {
            await viewModel.getDetails()
        }
    }
}


#Preview("Details-View") {
    
    NavigationStack {
        DetailsView(viewModel: MockDetails.makeDetailsViewModel())
    }
}


