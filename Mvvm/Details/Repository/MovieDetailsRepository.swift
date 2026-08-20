//
//  MovieDetailsRepository.swift
//  Mvvm
//
//  Created by Juan Fernandez on 20-08-26.
//

import Foundation

protocol MovieDetailRepository: Sendable {
    
    func getMovieDetails() async throws -> Movie
    
}
