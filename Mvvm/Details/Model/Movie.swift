//
//  MoviesDTO.swift
//  Mvvm
//
//  Created by Juan Fernandez on 18-08-26.
//

import Foundation

struct Movie: Identifiable {
    let id: UUID = UUID()
    let originalTitle: String
    let overview: String
    let popularity: Double
    
    init(originalTitle: String, overview: String, popularity: Double) {
        self.originalTitle = originalTitle
        self.overview = overview
        self.popularity = popularity
    }
}

extension Movie {
    init(_ dto: MovieDTO) {
        originalTitle = dto.originalTitle
        overview = dto.overview
        popularity = dto.popularity
    }
}
