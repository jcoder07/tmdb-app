//
//  MovieTests.swift
//  MvvmTests
//
//  Created by Juan Fernandez on 30-08-26.
//

import Testing
import Foundation
@testable import Mvvm


struct MovieTests {
    
    @Test
    func decodesMovieDTOFromJSON() throws {
        let json = """
        {
            "original_title": "Interstellar",
            "overview": "Una odisea espacial",
            "popularity": 90.5
        }
        """.data(using: .utf8)!
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        let dto = try decoder.decode(MovieDTO.self, from: json)
        
        #expect(dto.originalTitle == "Interstellar")
        #expect(dto.overview == "Una odisea espacial")
        #expect(dto.popularity == 90.5)
    }
    
    @Test
    func decodingFailsWhenPopularityIsMissing() {
        let json = """
        {
            "original_title": "Interstellar",
            "overview": "Una odisea espacial"
        }
        """.data(using: .utf8)!

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        #expect(throws: (any Error).self) {
            try decoder.decode(MovieDTO.self, from: json)
        }
    }
    
    @Test
    func mapsMovieDTOToMovie() {
        let dto = MovieDTO(originalTitle: "Dune", overview: "El desierto lo cambia todo", popularity: 75.2)
        
        let movie = Movie(dto)
        
        #expect(movie.originalTitle == dto.originalTitle)
        #expect(movie.overview == dto.overview)
        #expect(movie.popularity == dto.popularity)
    }
    
    @Test
    func mappingTheSameDTOTwiceProducesDifferentIds() {
        let dto = MovieDTO(originalTitle: "Dune", overview: "...", popularity: 75.2)
        
        let movie1 = Movie(dto)
        let movie2 = Movie(dto)
        
        #expect(movie1.id != movie2.id)
    }	
        
}
