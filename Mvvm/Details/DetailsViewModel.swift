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
    
    @Published private(set) var isLoading: Bool = false
    @Published var movie: Movie?
    
    private let repository: MovieDetailRepository
    
    init(repository: MovieDetailRepository) {
        self.repository = repository
    }
    
    public func getDetails() async {
        
        isLoading = true
        
        defer {
            isLoading = false
        }
        
        do {
            self.movie = try await repository.getMovieDetails()
            
        } catch {
            print(error)
        }
    }
}
