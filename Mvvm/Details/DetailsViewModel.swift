//
//  DetailsViewModel.swift
//  Mvvm
//
//  Created by Juan Fernandez on 18-08-26.
//

import SwiftUI


@MainActor
@Observable
public final class DetailsViewModel {
    
    private(set) var state: ViewState<Movie> = .idle
    
    private let repository: MovieDetailRepositoryProtocol
    
    public init(repository: MovieDetailRepositoryProtocol) {
        self.repository = repository
    }
    
    public func getDetails() async {
        
        state = .loading
        
        do {
            let movie = try await repository.getMovieDetails()
            state = .loaded(movie)
            
        } catch {
            debugPrint(error)
            let errorMessage = error.localizedDescription
            state = .error(errorMessage)
        }
    }
}
