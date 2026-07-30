import Foundation

struct MultiSearchResponseDTO: Decodable {
    let results: [MultiSearchItemDTO]
    let page: Int
    let totalPages: Int
}

struct MultiSearchItemDTO: Decodable {
    let id: Int
    let mediaType: String
    // Movie fields
    let title: String?
    let releaseDate: String?
    // TV fields
    let name: String?
    let firstAirDate: String?
    // Person fields
    let profilePath: String?
    let knownFor: [KnownForItemDTO]?
    // Shared
    let posterPath: String?
    let voteAverage: Double?
}

struct KnownForItemDTO: Decodable {
    let id: Int
    let mediaType: String
    let title: String?
    let name: String?
}

struct PopularPeopleResponseDTO: Decodable {
    let results: [PopularPersonDTO]
    let page: Int
    let totalPages: Int
}

struct PopularPersonDTO: Decodable {
    let id: Int
    let name: String
    let profilePath: String?
    let knownFor: [KnownForItemDTO]
}
