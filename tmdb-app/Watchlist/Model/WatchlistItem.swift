//
//  WatchlistItem.swift
//  tmdb-app
//

import Foundation

struct WatchlistMovie: Identifiable {
    let id: Int
    let title: String
    let overview: String
    let posterURL: URL?
    let voteAverage: Double
    let releaseDate: String?
}

extension WatchlistMovie {
    init(_ dto: WatchlistMovieDTO) {
        id = dto.id
        title = dto.title
        overview = dto.overview
        posterURL = dto.posterPath.flatMap { Constants.Urls.poster(path: $0) }
        voteAverage = dto.voteAverage
        releaseDate = dto.releaseDate
    }
}

struct WatchlistTVShow: Identifiable {
    let id: Int
    let name: String
    let overview: String
    let posterURL: URL?
    let voteAverage: Double
    let firstAirDate: String?
}

extension WatchlistTVShow {
    init(_ dto: WatchlistTVShowDTO) {
        id = dto.id
        name = dto.name
        overview = dto.overview
        posterURL = dto.posterPath.flatMap { Constants.Urls.poster(path: $0) }
        voteAverage = dto.voteAverage
        firstAirDate = dto.firstAirDate
    }
}
