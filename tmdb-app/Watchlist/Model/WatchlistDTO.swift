//
//  WatchlistDTO.swift
//  tmdb-app
//

import Foundation

struct WatchlistMovieDTO: Decodable {
    let id: Int
    let title: String
    let overview: String
    let posterPath: String?
    let voteAverage: Double
    let releaseDate: String?
}

struct WatchlistTVShowDTO: Decodable {
    let id: Int
    let name: String
    let overview: String
    let posterPath: String?
    let voteAverage: Double
    let firstAirDate: String?
}

struct WatchlistResponseDTO<T: Decodable>: Decodable {
    let results: [T]
}

struct AccountDetailsDTO: Decodable {
    let id: Int
}
