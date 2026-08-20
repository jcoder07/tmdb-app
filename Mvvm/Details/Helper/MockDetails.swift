//
//  MockDetails.swift
//  Mvvm
//
//  Created by Juan Fernandez on 20-08-26.
//

import Foundation

class MockDetails {
    
    class MockMovieDetaolRepository: MovieDetailRepository {
        
        func getMovieDetails() async throws -> Movie {
            
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
