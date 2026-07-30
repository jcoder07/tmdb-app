import Foundation

struct PersonDetailDTO: Decodable {
    let id: Int
    let name: String
    let biography: String
    let profilePath: String?
    let birthday: String?
    let placeOfBirth: String?
    let knownForDepartment: String?
}

struct CombinedCreditsResponseDTO: Decodable {
    let cast: [CombinedCreditItemDTO]
}

struct CombinedCreditItemDTO: Decodable {
    let id: Int
    let mediaType: String
    // Movie
    let title: String?
    let releaseDate: String?
    // TV
    let name: String?
    let firstAirDate: String?
    // Shared
    let posterPath: String?
    let voteAverage: Double
}
