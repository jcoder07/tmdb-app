//
//  MovieDetailsRepository.swift
//  Mvvm
//
//  Created by Juan Fernandez on 20-08-26.
//

import Foundation

protocol MovieDetailRepository {
    
    func getMovieDetails() async throws -> Movie?
    
}
