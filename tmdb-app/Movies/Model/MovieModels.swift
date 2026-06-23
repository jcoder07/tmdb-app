//
//  MovieModels.swift
//  tmdb-app
//

import Foundation

struct PopularMovie: Decodable, Identifiable {
    let id: Int
    let title: String
    let posterPath: String?
    let voteAverage: Double
    let releaseDate: String?
}

struct PopularMoviesResponse: Decodable {
    let results: [PopularMovie]
    let page: Int
    let totalPages: Int
}
