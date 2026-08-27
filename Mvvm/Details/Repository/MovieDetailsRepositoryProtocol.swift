//
//  MovieDetailsRepositoryProtocol.swift
//  Mvvm
//
//  Created by Juan Fernandez on 20-08-26.
//

import Foundation

public protocol MovieDetailRepositoryProtocol: Sendable {
    
    func getMovieDetails() async throws -> Movie
    
}
