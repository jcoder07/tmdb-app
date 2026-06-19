//
//  WatchlistItem.swift
//  tmdb-app
//

import Foundation

struct WatchlistMovie: Identifiable, Decodable {
    let id: Int
    let title: String
    let overview: String
    let posterPath: String?
    let voteAverage: Double
    let releaseDate: String?

    var posterURL: URL? {
        guard let posterPath else { return nil }
        return Constants.Urls.poster(path: posterPath)
    }
}

struct WatchlistTVShow: Identifiable, Decodable {
    let id: Int
    let name: String
    let overview: String
    let posterPath: String?
    let voteAverage: Double
    let firstAirDate: String?

    var posterURL: URL? {
        guard let posterPath else { return nil }
        return Constants.Urls.poster(path: posterPath)
    }
}

struct WatchlistResponse<T: Decodable>: Decodable {
    let results: [T]
}

struct AccountDetails: Decodable {
    let id: Int
}
