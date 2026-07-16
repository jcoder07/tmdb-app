import Foundation

struct SeriesDetailDTO: Decodable {
    let id: Int
    let name: String
    let overview: String
    let backdropPath: String?
    let posterPath: String?
    let firstAirDate: String?
    let voteAverage: Double
    let voteCount: Int
    let numberOfSeasons: Int
    let numberOfEpisodes: Int
    let genres: [MovieGenreDTO]
    let tagline: String?
    let status: String?
}
