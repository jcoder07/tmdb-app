import Foundation

struct FavoriteMovieDTO: Decodable {
    let id: Int
    let title: String
    let overview: String
    let posterPath: String?
    let voteAverage: Double
    let releaseDate: String?
}

struct FavoriteTVShowDTO: Decodable {
    let id: Int
    let name: String
    let overview: String
    let posterPath: String?
    let voteAverage: Double
    let firstAirDate: String?
}
