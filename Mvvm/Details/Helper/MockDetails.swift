//
//  MockDetails.swift
//  Mvvm
//
//  Created by Juan Fernandez on 20-08-26.
//

#if DEBUG
import Foundation

struct MockDetails {
    
   final class MockMovieDetaolRepository: MovieDetailRepositoryProtocol {
        
        func getMovieDetails() async throws -> Movie {
            
            let movie = Movie(originalTitle: "Test2", overview: "Test2", popularity: 20)
            
            return movie
        }

    }
    
    @MainActor static func makeDetailsViewModel() -> DetailsViewModel {
        let viewModel = DetailsViewModel(repository: MockMovieDetaolRepository())
        
        return viewModel
    }
    
}
#endif
