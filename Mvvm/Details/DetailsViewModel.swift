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
    
    @Published var movie: Movie?
    
    private let repository: MovieDetailRepository
    
    init(repository: MovieDetailRepository) {
        self.repository = repository
    }
    
    public func getDetails() async {
        
        do {
            let movie = try await repository.getMovieDetails()
            self.movie = movie
            
        } catch {
            print(error)
        }
    }
}
