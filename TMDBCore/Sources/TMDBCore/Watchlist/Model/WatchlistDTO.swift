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
    let page: Int
    let results: [T]
    let totalPages: Int
}
