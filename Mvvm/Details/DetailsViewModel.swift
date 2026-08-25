//
//  DetailsViewModel.swift
//  Mvvm
//
//  Created by Juan Fernandez on 18-08-26.
//

import SwiftUI
import Combine

@MainActor
class DetailsViewModel: ObservableObject {
    
    @Published private(set) var state: ViewState = .idle
    
    private let repository: MovieDetailRepository
    
    init(repository: MovieDetailRepository) {
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
