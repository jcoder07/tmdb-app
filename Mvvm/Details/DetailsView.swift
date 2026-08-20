//
//  DetailsView.swift
//  Mvvm
//
//  Created by Juan Fernandez on 18-08-26.
//

import SwiftUI

struct DetailsView: View {
    
    @StateObject var detailsViewModel: DetailsViewModel
    
    var body: some View {
        VStack {
            if let movie = detailsViewModel.movie {
                Text(movie.originalTitle)
                Text(movie.overview)
                Text(movie.popularity, format: .number)
            } else {
                Text("No Data")
            }
        }
        .padding()
        .task {
            await detailsViewModel.getDetails()
        }
    }
}

class MockDetails {
    
    class MockMovieDetaolRepository: MovieDetailRepository {
        
        func getMovieDetails() async throws -> Movie? {
            
            let movie = Movie(originalTitle: "Test2", overview: "Test2", popularity: 20)
            
            return movie
        }

    }
    
    static func makeDetailsViewModel() -> DetailsViewModel {
        let viewModel = DetailsViewModel(repository: MockMovieDetaolRepository())
        
        viewModel.movie = .init(originalTitle: "Test", overview: "Test", popularity: 10)
        return viewModel
    }
    
}

#Preview("Details-View") {
    
    NavigationStack {
        DetailsView(detailsViewModel: MockDetails.makeDetailsViewModel())
    }
}


