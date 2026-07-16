import Foundation

struct PopularSeriesDTO: Decodable {
    let id: Int
    let name: String
    let posterPath: String?
    let voteAverage: Double
    let firstAirDate: String?
}

struct PopularSeriesResponseDTO: Decodable {
    let results: [PopularSeriesDTO]
    let page: Int
    let totalPages: Int
}
