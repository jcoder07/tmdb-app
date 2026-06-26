import Foundation

public struct WatchlistMovieDTO: Decodable {
    public let id: Int
    public let title: String
    public let overview: String
    public let posterPath: String?
    public let voteAverage: Double
    public let releaseDate: String?
}

public struct WatchlistTVShowDTO: Decodable {
    public let id: Int
    public let name: String
    public let overview: String
    public let posterPath: String?
    public let voteAverage: Double
    public let firstAirDate: String?
}

public struct WatchlistResponseDTO<T: Decodable>: Decodable {
    public let results: [T]
}

public struct AccountDetailsDTO: Decodable {
    public let id: Int
}
